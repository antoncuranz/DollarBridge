import { Status } from "@/types"
import type {
  Account,
  Credit,
  Exchange,
  Payment,
  StatementMatchResult,
  Transaction,
  TransactionAmountMap,
} from "@/types"

const sum = (values: Array<number>) => values.reduce((a, b) => a + b, 0)

/** True when the value differs from the estimate by more than 2 %. */
export function hasLargeDeviation(
  baseline: number | null | undefined,
  value: number | null,
): boolean {
  if (baseline == null || baseline === 0 || value == null) return false
  return Math.abs(baseline - value) / baseline > 0.02
}

/** "8 % above estimate" */
export function deviationLabel(
  baseline: number | null | undefined,
  value: number | null,
): string | null {
  if (!hasLargeDeviation(baseline, value)) return null
  const percent = Math.round((Math.abs(value! - baseline!) / baseline!) * 100)
  return `${percent} % ${value! > baseline! ? "above" : "below"} estimate`
}

export function creditRemainder(credit: Credit): number {
  return credit.amount_usd - sum(credit.transactions.map(ct => ct.amount))
}

export function appliedCredits(transaction: Transaction): number {
  return sum(transaction.credits.map(ct => ct.amount))
}

export function exchangeRemainder(exchange: Exchange): number {
  return exchange.amount_usd - sum(exchange.payments.map(ep => ep.amount))
}

export function paymentRemainder(payment: Payment): number {
  return payment.amount_usd - sum(payment.exchanges.map(ep => ep.amount))
}

/** A payment can be processed once it is posted and fully covered by exchanges. */
export function canProcessPayment(payment: Payment): boolean {
  return payment.status === Status.POSTED && paymentRemainder(payment) === 0
}

export function canMarkCashback(transaction: Transaction): boolean {
  return (
    transaction.cashback_exchange_id == null &&
    transaction.status === Status.POSTED &&
    transaction.amount_usd > 0
  )
}

/** EUR value of an exchange: USD amount divided by the rate (rate has 7 decimals). */
export function exchangeAmountEur(amountUsd: number, rate: number): number {
  if (rate === 0) return 0
  return parseInt((amountUsd / (rate / 1e7)).toFixed(2))
}

/** Estimated EUR share when a credit reduces a transaction's USD amount. */
export function suggestedAmountAfterCredit(
  transaction: Transaction,
  creditAmount: number,
): number | null {
  const base = transaction.amount_eur ?? transaction.guessed_amount_eur
  if (base == null || transaction.amount_usd === 0) return null
  const remaining = transaction.amount_usd - appliedCredits(transaction)
  if (remaining <= 0) return null
  return Math.round((base * Math.max(remaining - creditAmount, 0)) / remaining)
}

export function groupBy<T, TKey extends string | number>(
  items: Array<T>,
  key: (item: T) => TKey,
): Array<{ key: TKey; items: Array<T> }> {
  const groups = new Map<TKey, Array<T>>()
  for (const item of items) {
    const k = key(item)
    const group = groups.get(k)
    if (group) group.push(item)
    else groups.set(k, [item])
  }
  return [...groups.entries()].map(([k, groupItems]) => ({
    key: k,
    items: groupItems,
  }))
}

export function accountById(accounts: Array<Account>): Map<number, Account> {
  return new Map(accounts.map(account => [account.id, account]))
}

/* ---- statement match ---- */

/** Below this confidence a match is shown under "Needs a look". */
export const CONFIDENCE_THRESHOLD = 0.9

export function matchedRows(
  results: Array<StatementMatchResult>,
): Array<StatementMatchResult> {
  return results.filter(result => result.matched)
}

export function needsReview(
  row: StatementMatchResult,
  amount: number | null | undefined,
): boolean {
  return (
    row.confidence < CONFIDENCE_THRESHOLD ||
    hasLargeDeviation(row.guessed_amount_eur, amount ?? null)
  )
}

export function draftAmountsFromRows(
  rows: Array<StatementMatchResult>,
): TransactionAmountMap {
  return Object.fromEntries(
    rows
      .filter(row => row.amount_eur != null)
      .map(row => [row.transaction_id, row.amount_eur]),
  )
}

/** EUR value of a USD part of an exchange, at the exchange's own rate. */
export function exchangeAmountEurShare(
  exchange: Exchange,
  amountUsd: number,
): number | null {
  if (exchange.amount_eur == null || exchange.amount_usd === 0) return null
  return Math.round((exchange.amount_eur * amountUsd) / exchange.amount_usd)
}
