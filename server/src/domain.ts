export const noiseReductionValues = ["near_field", "far_field"] as const;

export type NoiseReduction = (typeof noiseReductionValues)[number];

export interface TranslationTokenRequest {
  noiseReduction: NoiseReduction;
  deviceId: string;
}

export interface TranslationTokenResponse {
  clientSecret: string;
  expiresAt: number;
}

export class RequestValidationError extends Error {}

export function parseTranslationTokenRequest(
  value: unknown,
): TranslationTokenRequest {
  if (!isRecord(value)) {
    throw new RequestValidationError("Request body must be a JSON object.");
  }

  const allowedKeys = new Set(["noiseReduction", "deviceId"]);
  for (const key of Object.keys(value)) {
    if (!allowedKeys.has(key)) {
      throw new RequestValidationError(`Unsupported request field: ${key}`);
    }
  }

  const { noiseReduction, deviceId } = value;
  if (
    noiseReduction !== "near_field" &&
    noiseReduction !== "far_field"
  ) {
    throw new RequestValidationError(
      "noiseReduction must be near_field or far_field.",
    );
  }

  if (
    typeof deviceId !== "string" ||
    deviceId.length < 16 ||
    deviceId.length > 128 ||
    !/^[A-Za-z0-9._-]+$/.test(deviceId)
  ) {
    throw new RequestValidationError(
      "deviceId must be 16-128 URL-safe characters.",
    );
  }

  return { noiseReduction, deviceId };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

