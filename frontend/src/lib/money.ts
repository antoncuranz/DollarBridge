/** All amounts are integer minor units (cents). */

/** "123,45" — the format used in EUR fields and row columns. */
export function formatAmount(amount: number | null, decimals = 2): string {
  if (amount == null) return ""
  const sign = amount < 0 ? "-" : ""
  const factor = Math.pow(10, decimals)
  const abs = Math.abs(amount)
  let result = sign + Math.floor(abs / factor).toString()
  if (decimals !== 0) {
    result += "," + (abs % factor).toString().padStart(decimals, "0")
  }
  return result
}

const grouped = new Intl.NumberFormat("en-US", {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
})

/** "1,274.50" — the format used for USD and for headline totals. */
export function formatGrouped(amount: number): string {
  return grouped.format(amount / 100)
}

export function formatUsd(amount: number): string {
  return "$ " + formatGrouped(amount)
}

export function formatEur(amount: number): string {
  return "€ " + formatGrouped(amount)
}

/** "+0,12" / "−0,21" */
export function formatSigned(amount: number): string {
  return (amount < 0 ? "−" : "+") + formatAmount(Math.abs(amount))
}

/**
 * Parses "12,34", "12.34", "-5" … into minor units. Surplus decimals are cut
 * off. Returns null for an empty string and undefined if it cannot be parsed.
 */
export function parseAmount(
  value: string,
  decimals = 2,
): number | null | undefined {
  const trimmed = value.replace(/\s/g, "")
  if (trimmed === "") return null

  const re = new RegExp(String.raw`^(-)?(\d*)(?:[.,](\d{0,${decimals}}))?\d*$`)
  const match = trimmed.match(re)
  if (!match) return undefined

  const whole = match[2] ?? ""
  const fraction = match[3] ?? ""
  if (whole.length + fraction.length === 0) return undefined

  const sign = match[1] ? -1 : 1
  const units = parseInt(whole) || 0
  const cents = fraction
    ? (parseInt(fraction) || 0) * Math.pow(10, decimals - fraction.length)
    : 0

  return sign * (units * Math.pow(10, decimals) + cents)
}

/** exchange rates are stored with 7 decimals */
export function formatRate(rate: number | string, digits = 4): string {
  return Number(rate).toFixed(digits)
}
