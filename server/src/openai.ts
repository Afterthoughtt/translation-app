import { createHash } from "node:crypto";
import type {
  TranslationTokenRequest,
  TranslationTokenResponse,
} from "./domain.js";

const clientSecretEndpoint =
  "https://api.openai.com/v1/realtime/translations/client_secrets";

export class UpstreamServiceError extends Error {
  constructor(
    message: string,
    readonly statusCode: number,
  ) {
    super(message);
  }
}

export async function createTranslationToken(
  request: TranslationTokenRequest,
  openAIAPIKey: string,
): Promise<TranslationTokenResponse> {
  const response = await fetch(clientSecretEndpoint, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${openAIAPIKey}`,
      "Content-Type": "application/json",
      "OpenAI-Safety-Identifier": hashDeviceId(request.deviceId),
    },
    body: JSON.stringify(buildClientSecretRequestBody(request)),
    signal: AbortSignal.timeout(10_000),
  });

  if (!response.ok) {
    throw new UpstreamServiceError(
      "OpenAI did not create a translation client secret.",
      response.status,
    );
  }

  const value: unknown = await response.json();
  if (!isClientSecretResponse(value)) {
    throw new UpstreamServiceError(
      "OpenAI returned an invalid client-secret response.",
      502,
    );
  }

  return {
    clientSecret: value.value,
    expiresAt: value.expires_at,
  };
}

export function buildClientSecretRequestBody(
  request: TranslationTokenRequest,
): object {
  return {
    session: {
      model: "gpt-realtime-translate",
      audio: {
        input: {
          noise_reduction: { type: request.noiseReduction },
        },
        output: { language: "en" },
      },
    },
    expires_after: {
      anchor: "created_at",
      seconds: 600,
    },
  };
}

export function hashDeviceId(deviceId: string): string {
  return createHash("sha256").update(deviceId).digest("hex");
}

function isClientSecretResponse(
  value: unknown,
): value is { value: string; expires_at: number } {
  if (typeof value !== "object" || value === null) {
    return false;
  }
  const candidate = value as Record<string, unknown>;
  return (
    typeof candidate.value === "string" &&
    candidate.value.startsWith("ek_") &&
    typeof candidate.expires_at === "number"
  );
}
