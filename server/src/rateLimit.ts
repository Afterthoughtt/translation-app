interface WindowEntry {
  count: number;
  resetsAt: number;
}

export class FixedWindowRateLimiter {
  private readonly entries = new Map<string, WindowEntry>();

  constructor(
    private readonly limit: number,
    private readonly windowMilliseconds = 60_000,
  ) {}

  consume(identifier: string, now = Date.now()): boolean {
    const existing = this.entries.get(identifier);
    if (!existing || existing.resetsAt <= now) {
      this.entries.set(identifier, {
        count: 1,
        resetsAt: now + this.windowMilliseconds,
      });
      return true;
    }

    if (existing.count >= this.limit) {
      return false;
    }

    existing.count += 1;
    return true;
  }
}

