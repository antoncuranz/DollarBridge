import {
  differenceInCalendarDays,
  differenceInHours,
  differenceInMinutes,
  endOfMonth,
  format,
  parseISO,
} from "date-fns"

export function formatDay(date: string): string {
  return format(parseISO(date), "EEEE, d MMMM")
}

export function formatShortDay(date: string): string {
  return format(parseISO(date), "d MMM")
}

export function formatMonth(month: Date): string {
  return format(month, "MMMM yyyy")
}

/** "2026-11" */
export function monthKey(month: Date): string {
  return format(month, "yyyy-MM")
}

export function parseMonthKey(key: string | undefined): Date {
  if (key && /^\d{4}-\d{2}$/.test(key)) return parseISO(key + "-01")
  const now = new Date()
  return new Date(now.getFullYear(), now.getMonth(), 1)
}

export function monthRange(month: Date): { from: string; to: string } {
  return {
    from: format(month, "yyyy-MM-01"),
    to: format(endOfMonth(month), "yyyy-MM-dd"),
  }
}

export function ordinal(day: number): string {
  const rest = day % 100
  if (rest >= 11 && rest <= 13) return day + "th"
  return day + (["th", "st", "nd", "rd"][day % 10] ?? "th")
}

/** Imports run a few times a day; anything older than this is shown amber. */
const STALE_AFTER_HOURS = 36

export type UpdateAge = { label: string; stale: boolean }

export function updateAge(
  timestamp: string | null | undefined,
  now = new Date(),
): UpdateAge | null {
  if (!timestamp) return null
  const date = parseISO(timestamp)
  const minutes = Math.max(0, differenceInMinutes(now, date))
  const hours = differenceInHours(now, date)
  const days = differenceInCalendarDays(now, date)

  let label: string
  if (minutes < 60) label = `${minutes} min ago`
  else if (hours < 24) label = `${hours} h ago`
  else label = `${days} ${days === 1 ? "day" : "days"} ago`

  return { label, stale: hours >= STALE_AFTER_HOURS }
}
