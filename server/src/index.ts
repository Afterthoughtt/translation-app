import { timingSafeEqual } from "node:crypto";
import { createServer, type IncomingMessage, type ServerResponse } from "node:http";
import { loadConfig } from "./config.js";
import {
  parseTranslationTokenRequest,
  RequestValidationError,
} from "./domain.js";
import {
  createTranslationToken,
  UpstreamServiceError,
} from "./openai.js";
import { FixedWindowRateLimiter } from "./rateLimit.js";

const maximumRequestBytes = 2_048;
const config = loadConfig();
const rateLimiter = new FixedWindowRateLimiter(config.tokenRequestsPerMinute);

const server = createServer(async (request, response) => {
  try {
    if (request.method === "GET" && request.url === "/health") {
      sendJSON(response, 200, { status: "ok" });
      return;
    }

    if (request.method !== "POST" || request.url !== "/api/translation-token") {
      sendJSON(response, 404, { error: "not_found" });
      return;
    }

    if (!hasValidBearerToken(request, config.appAccessToken)) {
      sendJSON(response, 401, { error: "unauthorized" });
      return;
    }

    const remoteAddress = request.socket.remoteAddress ?? "unknown";
    if (!rateLimiter.consume(remoteAddress)) {
      sendJSON(response, 429, { error: "rate_limited" });
      return;
    }

    const body = await readJSONBody(request);
    const tokenRequest = parseTranslationTokenRequest(body);
    const token = await createTranslationToken(tokenRequest, config.openAIAPIKey);
    sendJSON(response, 200, token);
  } catch (error) {
    if (error instanceof RequestValidationError || error instanceof SyntaxError) {
      sendJSON(response, 400, { error: "invalid_request" });
      return;
    }
    if (error instanceof RequestTooLargeError) {
      sendJSON(response, 413, { error: "request_too_large" });
      return;
    }
    if (error instanceof UpstreamServiceError) {
      console.error(JSON.stringify({
        category: "openai",
        message: error.message,
        upstreamStatus: error.statusCode,
      }));
      sendJSON(response, 502, { error: "translation_token_unavailable" });
      return;
    }

    console.error(JSON.stringify({
      category: "app",
      message: error instanceof Error ? error.message : "Unknown server error",
    }));
    sendJSON(response, 500, { error: "internal_error" });
  }
});

server.listen(config.port, () => {
  console.log(JSON.stringify({
    category: "app",
    message: "Token service listening",
    port: config.port,
  }));
});

class RequestTooLargeError extends Error {}

async function readJSONBody(request: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  let receivedBytes = 0;

  for await (const chunk of request) {
    const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    receivedBytes += buffer.length;
    if (receivedBytes > maximumRequestBytes) {
      throw new RequestTooLargeError();
    }
    chunks.push(buffer);
  }

  return JSON.parse(Buffer.concat(chunks).toString("utf8"));
}

function hasValidBearerToken(
  request: IncomingMessage,
  expectedToken: string,
): boolean {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    return false;
  }

  const received = Buffer.from(authorization.slice("Bearer ".length));
  const expected = Buffer.from(expectedToken);
  return received.length === expected.length && timingSafeEqual(received, expected);
}

function sendJSON(
  response: ServerResponse,
  statusCode: number,
  body: object,
): void {
  const serialized = JSON.stringify(body);
  response.writeHead(statusCode, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(serialized),
    "Cache-Control": "no-store",
  });
  response.end(serialized);
}

