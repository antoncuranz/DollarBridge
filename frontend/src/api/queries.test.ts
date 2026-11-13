import { describe, expect, it, vi } from "vitest"

import { queryFailure } from "./queries"

const ok = { data: [], error: null, refetch: vi.fn() }

describe("queryFailure", () => {
  it("is null when every query has data", () => {
    expect(queryFailure(ok, ok)).toBeNull()
  })

  it("reports a query that failed without data and retries all failed", () => {
    const error = new Error("Internal Server Error")
    const a = { data: undefined, error, refetch: vi.fn() }
    const b = { data: undefined, error: new Error("other"), refetch: vi.fn() }

    const failure = queryFailure(ok, a, b)
    expect(failure?.error).toBe(error)

    failure?.retry()
    expect(a.refetch).toHaveBeenCalled()
    expect(b.refetch).toHaveBeenCalled()
    expect(ok.refetch).not.toHaveBeenCalled()
  })

  it("ignores a failed background refetch that kept its data", () => {
    expect(
      queryFailure({ data: [], error: new Error("x"), refetch: vi.fn() }),
    ).toBeNull()
  })
})
