import assert from "node:assert/strict";
import test from "node:test";
import { buildClientSecretRequestBody } from "../src/openai.js";

test("source transcription is disabled in the default translation session", () => {
  const body = buildClientSecretRequestBody({
    noiseReduction: "far_field",
    deviceId: "device-identifier-123",
  });

  assert.deepEqual(body, {
    session: {
      model: "gpt-realtime-translate",
      audio: {
        input: {
          noise_reduction: { type: "far_field" },
        },
        output: { language: "en" },
      },
    },
    expires_after: {
      anchor: "created_at",
      seconds: 600,
    },
  });
});
