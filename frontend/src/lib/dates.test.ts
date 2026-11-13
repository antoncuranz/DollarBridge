import { describe, expect, it } from "vitest"
import { monthRange, ordinal, parseMonthKey, updateAge } from "./dates"

describe("updateAge", () => {
  const now = new Date("2026-11-12T12:00:00Z")

  it("uses minutes, hours and days", () => {
    expect(updateAge("2026-11-12T11:41:00Z", now)).toEqual({
      label: "19 min ago",
      stale: false,
    })
    expect(updateAge("2026-11-12T10:00:00Z", now)?.label).toBe("2 h ago")
    expect(updateAge("2026-11-09T12:00:00Z", now)).toEqual({
      label: "3 days ago",
      stale: true,
    })
  })

  it("returns null without a timestamp", () => {
    expect(updateAge(null, now)).toBeNull()
  })
})

describe("months", () => {
  it("builds the first and last day", () => {
    expect(monthRange(parseMonthKey("2026-02"))).toEqual({
      from: "2026-02-01",
      to: "2026-02-28",
    })
  })

  it("falls back to the current month", () => {
    const now = new Date()
    expect(parseMonthKey("nonsense").getMonth()).toBe(now.getMonth())
  })
})

describe("ordinal", () => {
  it("handles the teens", () => {
    expect([1, 2, 3, 4, 11, 12, 13, 21, 22, 23, 24].map(ordinal)).toEqual([
      "1st",
      "2nd",
      "3rd",
      "4th",
      "11th",
      "12th",
      "13th",
      "21st",
      "22nd",
      "23rd",
      "24th",
    ])
  })
})
