import { describe, expect, it } from "vitest"
import {
  canMarkCashback,
  canProcessPayment,
  creditRemainder,
  deviationLabel,
  draftAmountsFromRows,
  exchangeAmountEur,
  groupBy,
  hasLargeDeviation,
  matchedRows,
  needsReview,
  paymentRemainder,
  suggestedAmountAfterCredit,
} from "./derive"
import type {
  Credit,
  Payment,
  StatementMatchResult,
  Transaction,
} from "@/types"

const transaction = (overrides: Partial<Transaction> = {}): Transaction => ({
  id: 1,
  account_id: 1,
  import_id: "tx",
  actual_id: null,
  date: "2026-11-11",
  counterparty: "Northstar Market",
  description: "Groceries",
  category: "",
  amount_usd: 4280,
  amount_eur: null,
  guessed_amount_eur: 3968,
  status: 2,
  payment_id: null,
  fees_and_risk_eur: null,
  credits: [],
  ignore: false,
  exchange_rate: null,
  cashback_exchange_id: null,
  ...overrides,
})

const payment = (overrides: Partial<Payment> = {}): Payment => ({
  id: 1,
  account_id: 1,
  import_id: "pm",
  actual_id: null,
  date: "2026-11-17",
  counterparty: "Autopay",
  description: "",
  category: "",
  amount_usd: 10000,
  amount_eur_with_fx: null,
  amount_eur_without_fx: null,
  status: 2,
  exchanges: [],
  ...overrides,
})

const match = (
  overrides: Partial<StatementMatchResult> = {},
): StatementMatchResult => ({
  transaction_id: 1,
  date: "2026-11-11",
  amount_usd: 4280,
  amount_eur: 3974,
  guessed_amount_eur: 3968,
  counterparty: "Northstar Market",
  description: "",
  matched: true,
  confidence: 0.98,
  statement_excerpt: null,
  reason: "",
  ...overrides,
})

describe("deviation from the estimate", () => {
  it("flags more than 2 %", () => {
    expect(hasLargeDeviation(1000, 1020)).toBe(false)
    expect(hasLargeDeviation(1000, 1021)).toBe(true)
    expect(hasLargeDeviation(1000, 979)).toBe(true)
  })

  it("ignores missing or zero baselines and missing values", () => {
    expect(hasLargeDeviation(null, 100)).toBe(false)
    expect(hasLargeDeviation(0, 100)).toBe(false)
    expect(hasLargeDeviation(1000, null)).toBe(false)
  })

  it("describes the direction", () => {
    expect(deviationLabel(11944, 12900)).toBe("8 % above estimate")
    expect(deviationLabel(1000, 500)).toBe("50 % below estimate")
    expect(deviationLabel(1000, 1000)).toBeNull()
  })
})

describe("remainders", () => {
  it("subtracts applied amounts", () => {
    const credit = {
      amount_usd: 2500,
      transactions: [{ amount: 700, credit_id: 1, transaction_id: 1 }],
    } as Credit
    expect(creditRemainder(credit)).toBe(1800)
    expect(
      paymentRemainder(
        payment({
          exchanges: [{ amount: 4000, exchange_id: 1, payment_id: 1 }],
        }),
      ),
    ).toBe(6000)
  })
})

describe("canProcessPayment", () => {
  const covered = [{ amount: 10000, exchange_id: 1, payment_id: 1 }]

  it("needs a posted, fully covered payment", () => {
    expect(canProcessPayment(payment({ exchanges: covered }))).toBe(true)
    expect(canProcessPayment(payment())).toBe(false)
    expect(canProcessPayment(payment({ exchanges: covered, status: 1 }))).toBe(
      false,
    )
  })
})

describe("canMarkCashback", () => {
  it("only for posted, positive transactions without cashback", () => {
    expect(canMarkCashback(transaction())).toBe(true)
    expect(canMarkCashback(transaction({ status: 1 }))).toBe(false)
    expect(canMarkCashback(transaction({ amount_usd: 0 }))).toBe(false)
    expect(canMarkCashback(transaction({ cashback_exchange_id: 4 }))).toBe(
      false,
    )
  })
})

describe("exchange maths", () => {
  it("divides USD by the rate", () => {
    expect(exchangeAmountEur(10000, 10820000)).toBe(9242)
    expect(exchangeAmountEur(10000, 0)).toBe(0)
  })
})

describe("suggestedAmountAfterCredit", () => {
  it("scales the EUR amount with the remaining USD", () => {
    // $ 42.80 at 39,68 with $ 25.00 credit leaves $ 17.80
    expect(suggestedAmountAfterCredit(transaction(), 2500)).toBe(1650)
  })

  it("prefers the saved amount and handles full coverage", () => {
    expect(
      suggestedAmountAfterCredit(transaction({ amount_eur: 4000 }), 2140),
    ).toBe(2000)
    expect(suggestedAmountAfterCredit(transaction(), 4280)).toBe(0)
    expect(
      suggestedAmountAfterCredit(
        transaction({ guessed_amount_eur: null }),
        100,
      ),
    ).toBeNull()
  })
})

describe("groupBy", () => {
  it("keeps the order of first appearance", () => {
    const groups = groupBy([{ d: "b" }, { d: "a" }, { d: "b" }], item => item.d)
    expect(groups.map(g => [g.key, g.items.length])).toEqual([
      ["b", 2],
      ["a", 1],
    ])
  })
})

describe("statement matches", () => {
  it("keeps matched rows and seeds drafts from the statement amounts", () => {
    const rows = [
      match(),
      match({ transaction_id: 2, matched: false }),
      match({ transaction_id: 3, amount_eur: null }),
    ]
    expect(matchedRows(rows).map(r => r.transaction_id)).toEqual([1, 3])
    expect(draftAmountsFromRows(matchedRows(rows))).toEqual({ 1: 3974 })
  })

  it("asks for a look at low confidence or a large deviation", () => {
    expect(needsReview(match(), 3974)).toBe(false)
    expect(needsReview(match({ confidence: 0.87 }), 3974)).toBe(true)
    expect(needsReview(match(), 5000)).toBe(true)
  })
})
