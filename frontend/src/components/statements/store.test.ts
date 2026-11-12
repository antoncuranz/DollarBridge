import { describe, expect, it } from "vitest"
import { amountsToSave, reviewGroups } from "./store"
import type { StatementTab } from "./store"
import type { StatementMatchResult } from "@/types"

const row = (id: number, confidence: number): StatementMatchResult => ({
  transaction_id: id,
  date: "2026-11-11",
  amount_usd: 1000,
  amount_eur: 900,
  guessed_amount_eur: 900,
  counterparty: "Shop",
  description: "",
  matched: true,
  confidence,
  statement_excerpt: null,
  reason: "",
})

const tab = (overrides: Partial<StatementTab> = {}): StatementTab => ({
  id: "1-1",
  accountId: 1,
  fileName: "Nov.pdf",
  status: "ready",
  rows: [row(1, 0.98), row(2, 0.87), row(3, 0.95)],
  amounts: { 1: 900, 2: 900, 3: 900 },
  accepted: [],
  skipped: [],
  ...overrides,
})

const ids = (rows: Array<StatementMatchResult>) =>
  rows.map(r => r.transaction_id)

describe("statement review", () => {
  it("only saves confident matches", () => {
    const groups = reviewGroups(tab())
    expect(ids(groups.review)).toEqual([2])
    expect(ids(groups.ready)).toEqual([1, 3])
    expect(amountsToSave(tab())).toEqual({ 1: 900, 3: 900 })
  })

  it("saves accepted matches and leaves out skipped ones", () => {
    const reviewed = tab({ accepted: [2], skipped: [3] })
    expect(amountsToSave(reviewed)).toEqual({ 1: 900, 2: 900 })
    expect(ids(reviewGroups(reviewed).skipped)).toEqual([3])
  })

  it("sends an edited amount with a large deviation back to review", () => {
    const edited = tab({ amounts: { 1: 2000, 2: 900, 3: 900 } })
    expect(ids(reviewGroups(edited).review)).toEqual([1, 2])
  })

  it("does not save a cleared amount", () => {
    expect(amountsToSave(tab({ amounts: { 1: null, 3: 900 } }))).toEqual({
      3: 900,
    })
  })
})
