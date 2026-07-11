export interface Config {
  openAIAPIKey: string;
  appAccessToken: string;
  port: number;
  tokenRequestsPerMinute: number;
}

export function loadConfig(environment = process.env): Config {
  const openAIAPIKey = requireValue(environment.OPENAI_API_KEY, "OPENAI_API_KEY");
  const appAccessToken = requireValue(
    environment.APP_ACCESS_TOKEN,
    "APP_ACCESS_TOKEN",
  );

  if (appAccessToken.length < 32) {
    throw new Error("APP_ACCESS_TOKEN must contain at least 32 characters.");
  }

  return {
    openAIAPIKey,
    appAccessToken,
    port: parseInteger(environment.PORT, 8787, 1, 65_535),
    tokenRequestsPerMinute: parseInteger(
      environment.TOKEN_REQUESTS_PER_MINUTE,
      10,
      1,
      100,
    ),
  };
}

function requireValue(value: string | undefined, name: string): string {
  if (!value) {
    throw new Error(`${name} is required.`);
  }
  return value;
}

function parseInteger(
  value: string | undefined,
  fallback: number,
  minimum: number,
  maximum: number,
): number {
  if (value === undefined) {
    return fallback;
  }

  const parsed = Number.parseInt(value, 10);
  if (!Number.isInteger(parsed) || parsed < minimum || parsed > maximum) {
    throw new Error(`Expected an integer from ${minimum} through ${maximum}.`);
  }
  return parsed;
}

