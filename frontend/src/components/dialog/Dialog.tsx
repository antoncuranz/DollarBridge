import { format, parseISO } from "date-fns"
import { ChevronDown } from "lucide-react"
import { useCallback, useEffect, useId, useRef, useState } from "react"
import type { ReactNode } from "react"

import {
  DialogContent,
  DialogDescription,
  DialogHeader,
  Dialog as DialogRoot,
  DialogTitle,
} from "@/components/ui/dialog"
import { Calendar } from "@/components/ui/calendar"
import { fieldClassName } from "@/components/ui/input"
import {
  Popover,
  PopoverContent,
  PopoverPositioner,
  PopoverTrigger,
} from "@/components/ui/popover"
import { formatAmount, formatGrouped, parseAmount } from "@/lib/money"
import { cn } from "@/lib/utils"

/** Dialog frame: title, scrolling body and a footer with the main action. */
export function Dialog({
  open,
  onClose,
  title,
  description,
  footer,
  className,
  children,
}: {
  open: boolean
  onClose: () => void
  title: string
  description?: string
  footer?: ReactNode
  className?: string
  children: ReactNode
}) {
  return (
    <DialogRoot open={open} onOpenChange={next => next || onClose()}>
      <DialogContent className={className}>
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {description && <DialogDescription>{description}</DialogDescription>}
        </DialogHeader>
        <div className="flex min-h-0 flex-col gap-3 overflow-y-auto px-3 pb-1">
          {children}
        </div>
        {footer && <div className="flex gap-2">{footer}</div>}
      </DialogContent>
    </DialogRoot>
  )
}

/** Grey box that restates what the dialog acts on. */
export function ContextBox({ children }: { children: ReactNode }) {
  return (
    <div className="flex flex-col gap-1.5 rounded-[14px] bg-field px-3.5 py-3">
      {children}
    </div>
  )
}

export function ContextLine({
  leading,
  title,
  detail,
}: {
  leading: ReactNode
  title: ReactNode
  detail?: ReactNode
}) {
  return (
    <div className="redactable flex items-center gap-2.5 text-sm leading-5 whitespace-nowrap">
      {leading}
      <span className="shrink-0 font-medium">{title}</span>
      <span className="truncate text-muted-foreground">{detail}</span>
    </div>
  )
}

export function Field({
  label,
  hint,
  error,
  htmlFor,
  className,
  children,
}: {
  label: string
  hint?: ReactNode
  error?: string
  htmlFor?: string
  className?: string
  children: ReactNode
}) {
  return (
    <div className={cn("flex min-w-0 flex-col gap-2", className)}>
      <label htmlFor={htmlFor} className="text-sm leading-5 font-medium">
        {label}
      </label>
      {children}
      {error ? (
        <p className="text-xs leading-[17px] text-destructive">{error}</p>
      ) : (
        hint && (
          <p className="text-xs leading-[17px] text-muted-foreground">{hint}</p>
        )
      )}
    </div>
  )
}

export function FieldRow({ children }: { children: ReactNode }) {
  return <div className="grid grid-cols-2 gap-3">{children}</div>
}

type AmountFormat = "usd" | "eur" | "plain" | "rate"

const formats: Record<
  AmountFormat,
  { prefix?: string; decimals: number; format: (value: number) => string }
> = {
  usd: { prefix: "$", decimals: 2, format: formatGrouped },
  eur: { prefix: "€", decimals: 2, format: value => formatAmount(value) },
  plain: { decimals: 0, format: value => formatAmount(value, 0) },
  rate: { decimals: 7, format: value => (value / 1e7).toString() },
}

/**
 * Tracks which AmountFields of a dialog hold text that is not a valid amount,
 * so the dialog can refuse to save the stale value behind them.
 */
export function useInvalidFields() {
  const [invalid, setInvalid] = useState<ReadonlySet<string>>(new Set())
  const callbacks = useRef(new Map<string, (isInvalid: boolean) => void>())

  const track = useCallback((name: string) => {
    let callback = callbacks.current.get(name)
    if (!callback) {
      callback = (isInvalid: boolean) =>
        setInvalid(current => {
          if (current.has(name) === isInvalid) return current
          const next = new Set(current)
          if (isInvalid) next.add(name)
          else next.delete(name)
          return next
        })
      callbacks.current.set(name, callback)
    }
    return callback
  }, [])

  return { anyInvalid: invalid.size > 0, track }
}

/** Input for an amount in minor units. Commits the parsed value on blur. */
export function AmountField({
  label,
  hint,
  value,
  onChange,
  onInvalidChange,
  allowNegative = false,
  format = "eur",
  placeholder,
  autoFocus,
  disabled,
  className,
}: {
  label: string
  hint?: ReactNode
  value: number | null
  onChange: (value: number | null) => void
  /** told whenever the typed text stops or starts being a valid amount */
  onInvalidChange?: (invalid: boolean) => void
  allowNegative?: boolean
  format?: AmountFormat
  placeholder?: string
  autoFocus?: boolean
  disabled?: boolean
  className?: string
}) {
  const id = useId()
  const { prefix, decimals, format: formatValue } = formats[format]
  const display = (v: number | null) => (v == null ? "" : formatValue(v))
  const [text, setText] = useState(display(value))
  const [invalid, setInvalid] = useState(false)

  useEffect(() => {
    setText(display(value))
    setInvalid(false)
  }, [value])

  useEffect(() => {
    onInvalidChange?.(invalid)
  }, [invalid, onInvalidChange])

  // a field that goes away no longer blocks saving
  useEffect(() => () => onInvalidChange?.(false), [onInvalidChange])

  function commit() {
    // thousands separators of the grouped format are not decimals
    const cleaned = format === "usd" ? text.replace(/,(?=\d{3})/g, "") : text
    const parsed = parseAmount(cleaned, decimals)
    if (
      parsed === undefined ||
      (!allowNegative && parsed != null && parsed < 0)
    ) {
      setInvalid(true)
      return
    }
    setInvalid(false)
    setText(display(parsed))
    if (parsed !== value) onChange(parsed)
  }

  return (
    <Field
      label={label}
      hint={hint}
      error={invalid ? "Not a valid amount" : undefined}
      htmlFor={id}
      className={className}
    >
      <div
        className={cn(
          fieldClassName,
          "tabular focus-within:border-accent focus-within:shadow-focus focus-within:ring-1 focus-within:ring-accent",
          invalid && "border-destructive",
          disabled && "opacity-50",
        )}
      >
        {prefix && <span className="text-muted-foreground">{prefix}</span>}
        <input
          id={id}
          inputMode="decimal"
          autoComplete="off"
          autoFocus={autoFocus}
          disabled={disabled}
          value={text}
          placeholder={placeholder}
          onChange={event => setText(event.target.value)}
          onBlur={commit}
          onKeyDown={event => {
            if (event.key === "Enter") commit()
          }}
          className="w-full min-w-0 flex-1 bg-transparent outline-none placeholder:text-placeholder"
        />
      </div>
    </Field>
  )
}

/** Read-only derived value, shown with the formula that produced it. */
export function ComputedField({
  label,
  hint,
  prefix,
  children,
}: {
  label: string
  hint?: ReactNode
  prefix?: string
  children: ReactNode
}) {
  return (
    <Field label={label} hint={hint}>
      <div className="tabular flex h-10 items-center gap-2 rounded-[14px] bg-field px-3 text-sm text-muted-foreground">
        {prefix && <span>{prefix}</span>}
        <span className="flex-1 truncate">{children}</span>
      </div>
    </Field>
  )
}

/** Date as "yyyy-MM-dd", picked from a calendar popover. */
export function DateField({
  label,
  value,
  onChange,
}: {
  label: string
  value: string
  onChange: (value: string) => void
}) {
  const id = useId()
  const [open, setOpen] = useState(false)
  const date = value ? parseISO(value) : undefined

  return (
    <Field label={label} htmlFor={id}>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger
          id={id}
          className={cn(
            fieldClassName,
            "cursor-pointer justify-between text-left select-none hover:bg-secondary-hover active:scale-[0.98]",
            !date && "text-placeholder",
          )}
        >
          {date ? format(date, "d MMM yyyy") : "Pick a date"}
          <ChevronDown className="size-4 text-muted-foreground" />
        </PopoverTrigger>
        <PopoverPositioner align="start">
          <PopoverContent>
            <Calendar
              mode="single"
              required
              selected={date}
              defaultMonth={date}
              onSelect={selected => {
                onChange(format(selected, "yyyy-MM-dd"))
                setOpen(false)
              }}
            />
          </PopoverContent>
        </PopoverPositioner>
      </Popover>
    </Field>
  )
}
