import assert from "node:assert/strict";
import test from "node:test";
import {
  parseTranslationTokenRequest,
  RequestValidationError,
} from "../src/domain.js";

test("accepts a bounded whitelisted request", () => {
  assert.deepEqual(
    parseTranslationTokenRequest({
      noiseReduction: "far_field",
      deviceId: "installation-123456",
    }),
    {
      noiseReduction: "far_field",
      deviceId: "installation-123456",
    },
  );
});

test("rejects an unsupported noise-reduction value", () => {
  assert.throws(
    () => parseTranslationTokenRequest({
      noiseReduction: "disabled",
      deviceId: "installation-123456",
    }),
    RequestValidationError,
  );
});

test("rejects unknown fields", () => {
  assert.throws(
    () => parseTranslationTokenRequest({
      noiseReduction: "far_field",
      deviceId: "installation-123456",
      model: "arbitrary-model",
    }),
    RequestValidationError,
  );
});

