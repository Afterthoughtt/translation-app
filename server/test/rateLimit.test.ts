import assert from "node:assert/strict";
import test from "node:test";
import { FixedWindowRateLimiter } from "../src/rateLimit.js";

test("limits requests within a fixed window", () => {
  const limiter = new FixedWindowRateLimiter(2, 1_000);

  assert.equal(limiter.consume("device", 0), true);
  assert.equal(limiter.consume("device", 1), true);
  assert.equal(limiter.consume("device", 2), false);
  assert.equal(limiter.consume("device", 1_001), true);
});
