import { useQueries, useQuery } from "@tanstack/react-query"
import {
  addMonths,
  eachDayOfInterval,
  endOfMonth,
  endOfWeek,
  format,
  isSameDay,
  isSameMonth,
  parseISO,
  startOfDay,
  startOfMonth,
  startOfWeek,
} from "date-fns"
import { ChevronDown, ChevronLeft, ChevronRight } from "lucide-react"
import { useState } from "react"

import { accountsQuery, datesQuery } from "@/api/queries"
import { Button } from "@/components/ui/button"
import { formatMonth } from "@/lib/dates"
import { cn } from "@/lib/utils"
import { usePreferences } from "@/store"
import type { AccountDatesMap } from "@/types"
import type { CSSProperties } from "react"

const WEEKDAYS = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

type Marks = {
  /** account colours, by ISO date */
  due: Map<string, Array<string>>
  statement: Map<string, Array<string>>
}

function collectMarks(maps: Array<AccountDatesMap | undefined>): Marks {
  const marks: Marks = { due: new Map(), statement: new Map() }
  const seen = new Set<string>()
  for (const map of maps) {
    for (const [accountId, dates] of Object.entries(map ?? {})) {
      if (!dates) continue
      for (const kind of ["due", "statement"] as const) {
        for (const date of dates[kind]) {
          const key = `${kind}:${accountId}:${date}`
          if (seen.has(key)) continue
          seen.add(key)
          const colors = marks[kind].get(date) ?? []
          colors.push(dates.color)
          marks[kind].set(date, colors)
        }
      }
    }
  }
  return marks
}

/** true if white text is readable on the colour */
function isDarkColor(color: string): boolean {
  const hex = /^#([0-9a-f]{6})$/i.exec(color)?.[1]
  if (!hex) return true
  const channel = (start: number) => parseInt(hex.slice(start, start + 2), 16)
  return 0.299 * channel(0) + 0.587 * channel(2) + 0.114 * channel(4) < 170
}

function gradient(colors: Array<string>): string {
  const [only, ...rest] = colors
  return only != null && rest.length === 0
    ? only
    : `linear-gradient(135deg, ${colors.join(", ")})`
}

function Day({
  date,
  marks,
  muted,
  large,
}: {
  date: Date
  marks: Marks
  muted?: boolean
  large?: boolean
}) {
  const iso = format(date, "yyyy-MM-dd")
  const due = marks.due.get(iso)
  const statement = marks.statement.get(iso)
  const today = isSameDay(date, new Date())

  let style: CSSProperties | undefined
  let textClass = muted ? "text-placeholder" : "text-foreground"
  if (due) {
    style = { background: gradient(due) }
    textClass = due.every(isDarkColor) ? "text-white" : "text-[#09090b]"
  } else if (statement) {
    style =
      statement.length === 1
        ? { borderColor: statement[0] }
        : {
            borderColor: "transparent",
            background: `linear-gradient(var(--surface) 0 0) padding-box, ${gradient(statement)} border-box`,
          }
  }

  return (
    <div
      title={due ? "Payment due" : statement ? "Statement closes" : undefined}
      style={style}
      className={cn(
        "tabular flex items-center justify-center",
        large
          ? "h-9 w-10 rounded-row text-sm leading-5"
          : "h-8 w-9 rounded-day text-[13px] leading-[19px]",
        statement && !due && "border-2",
        textClass,
        today ? "font-bold" : due ? "font-medium" : "font-normal",
      )}
    >
      {date.getDate()}
    </div>
  )
}

function Weekdays({ large }: { large?: boolean }) {
  return (
    <div className="flex justify-between">
      {WEEKDAYS.map(day => (
        <div
          key={day}
          className={cn(
            "flex items-center justify-center text-xs leading-[17px] text-muted-foreground",
            large ? "h-[22px] w-10" : "h-6 w-9",
          )}
        >
          {day}
        </div>
      ))}
    </div>
  )
}

function weeksOf(month: Date): Array<Array<Date>> {
  const days = eachDayOfInterval({
    start: startOfWeek(startOfMonth(month)),
    end: endOfWeek(endOfMonth(month)),
  })
  const weeks: Array<Array<Date>> = []
  for (let i = 0; i < days.length; i += 7) weeks.push(days.slice(i, i + 7))
  return weeks
}

function MonthGrid({
  month,
  marks,
  large,
}: {
  month: Date
  marks: Marks
  large?: boolean
}) {
  return (
    <>
      <Weekdays large={large} />
      {weeksOf(month).map(week => (
        <div key={week[0]?.toISOString()} className="flex justify-between">
          {week.map(day =>
            isSameMonth(day, month) ? (
              <Day
                key={day.toISOString()}
                date={day}
                marks={marks}
                large={large}
              />
            ) : (
              <div
                key={day.toISOString()}
                className={large ? "h-9 w-10" : "h-8 w-9"}
              />
            ),
          )}
        </div>
      ))}
    </>
  )
}

function Legend() {
  return (
    <div className="flex gap-3.5 pt-1.5 pl-1 text-xs leading-[17px] text-muted-foreground">
      <span className="flex items-center gap-1.5">
        <span className="size-3 rounded-[4px] bg-muted-foreground" />
        Payment due
      </span>
      <span className="flex items-center gap-1.5">
        <span className="size-3 rounded-[4px] border-[1.5px] border-muted-foreground" />
        Statement closes
      </span>
    </div>
  )
}

function useMonthState() {
  const [month, setMonth] = useState(() => startOfMonth(new Date()))
  const { data } = useQuery(
    datesQuery(month.getFullYear(), month.getMonth() + 1),
  )
  return { month, setMonth, marks: collectMarks([data]) }
}

function MonthNavigation({
  month,
  setMonth,
}: {
  month: Date
  setMonth: (month: Date) => void
}) {
  return (
    <>
      <Button
        variant="ghost"
        size="icon-sm"
        aria-label="Previous month"
        onClick={() => setMonth(addMonths(month, -1))}
      >
        <ChevronLeft />
      </Button>
      <Button
        variant="ghost"
        size="icon-sm"
        aria-label="Next month"
        onClick={() => setMonth(addMonths(month, 1))}
      >
        <ChevronRight />
      </Button>
    </>
  )
}

/** Desktop sidebar calendar: one month with due and statement dates. */
export function DueCalendar() {
  const { month, setMonth, marks } = useMonthState()

  return (
    <div className="flex shrink-0 flex-col gap-0.5">
      <div className="flex h-10 items-center gap-1 pl-1">
        <p className="flex-1 text-lg leading-[26px] font-semibold">
          {formatMonth(month)}
        </p>
        <MonthNavigation month={month} setMonth={setMonth} />
      </div>
      <MonthGrid month={month} marks={marks} />
      <Legend />
    </div>
  )
}

/** Mobile: the current week and the next due date; expands to the month. */
export function DueCalendarCard() {
  const expanded = usePreferences(state => state.calendarExpanded)
  const setExpanded = usePreferences(state => state.setCalendarExpanded)
  const { month, setMonth, marks: monthMarks } = useMonthState()

  const today = startOfDay(new Date())
  const weekStart = startOfWeek(today)
  const weekEnd = endOfWeek(today)
  const nextMonth = addMonths(startOfMonth(today), 1)

  // the week can span two months, and the next due date may be next month
  const months = [startOfMonth(weekStart), startOfMonth(today), nextMonth]
  const results = useQueries({
    queries: months.map(m => datesQuery(m.getFullYear(), m.getMonth() + 1)),
  })
  const marks = collectMarks(results.map(result => result.data))
  const { data: accounts } = useQuery(accountsQuery)

  const nextDue = results
    .flatMap(result => Object.entries(result.data ?? {}))
    .flatMap(([accountId, dates]) =>
      (dates?.due ?? []).map(due => ({ accountId, due: parseISO(due) })),
    )
    .filter(entry => entry.due >= today)
    .sort((a, b) => a.due.getTime() - b.due.getTime())[0]
  const nextDueAccount = accounts?.find(
    account => String(account.id) === nextDue?.accountId,
  )

  return (
    <div className="mx-5 flex flex-col gap-0.5 rounded-2xl border bg-card px-2.5 pt-1.5 pb-2.5 shadow-[0_2px_2px_0_rgb(0_0_0/0.04)]">
      <div className="flex h-10 items-center gap-2 pr-1 pl-1.5">
        <p className="flex-1 text-base leading-[23px] font-semibold">
          {expanded ? formatMonth(month) : "This week"}
        </p>
        {expanded ? (
          <MonthNavigation month={month} setMonth={setMonth} />
        ) : (
          <button
            type="button"
            className="flex items-center gap-2 text-[13px] leading-[19px] text-muted-foreground"
            onClick={() => setExpanded(true)}
          >
            {nextDue
              ? `Next due: ${nextDueAccount?.name ?? "payment"}, ${format(nextDue.due, "EEE d")}`
              : "Show month"}
            <ChevronDown className="size-4" />
          </button>
        )}
      </div>
      {expanded ? (
        <>
          <MonthGrid month={month} marks={monthMarks} large />
          <div className="flex items-center justify-between">
            <Legend />
            <button
              type="button"
              className="pt-1.5 pr-1 text-[13px] leading-[19px] font-medium text-accent"
              onClick={() => {
                setExpanded(false)
                setMonth(startOfMonth(new Date()))
              }}
            >
              Show less
            </button>
          </div>
        </>
      ) : (
        <>
          <Weekdays large />
          <div className="flex justify-between">
            {eachDayOfInterval({ start: weekStart, end: weekEnd }).map(day => (
              <Day key={day.toISOString()} date={day} marks={marks} large />
            ))}
          </div>
        </>
      )}
    </div>
  )
}
