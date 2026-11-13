import { CircleAlert } from "lucide-react"
import { useEffect, useState } from "react"
import { toast } from "sonner"

import { formatAmount, parseAmount } from "@/lib/money"
import { cn } from "@/lib/utils"

/**
 * Inline EUR amount of a row.
 *
 * - no value: the estimate is shown as placeholder
 * - saved value: plain text until focused
 * - draft (unsaved): tinted
 * - warning: value deviates a lot from the estimate
 */
export function EurField({
  value,
  estimate,
  draft,
  warning,
  disabled,
  label,
  onChange,
}: {
  value: number | null
  estimate?: number | null
  draft?: boolean
  warning?: boolean
  disabled?: boolean
  label: string
  onChange: (value: number | null) => void
}) {
  const [text, setText] = useState(formatAmount(value))
  const [focused, setFocused] = useState(false)

  useEffect(() => {
    if (!focused) setText(formatAmount(value))
  }, [value, focused])

  function commit() {
    const parsed = parseAmount(text)
    if (parsed === undefined) {
      toast.error("Unable to parse amount", { description: text })
      setText(formatAmount(value))
      return
    }
    setText(formatAmount(parsed))
    if (parsed !== value) onChange(parsed)
  }

  const empty = value == null

  return (
    <label
      className={cn(
        "tabular flex h-8 w-[100px] shrink-0 cursor-text items-center gap-1 rounded-field border pr-2.5 pl-2 transition-[background-color,border-color,box-shadow] md:h-7 md:w-[108px]",
        focused
          ? "border-accent bg-card shadow-focus ring-1 ring-accent"
          : warning && !empty
            ? "border-warning bg-warning-soft"
            : draft
              ? "border-accent bg-accent-soft"
              : empty
                ? "bg-field"
                : "border-transparent hover:border-border hover:bg-field",
        disabled && "pointer-events-none opacity-60",
      )}
    >
      {warning && !empty && !focused ? (
        <CircleAlert className="size-3.5 shrink-0 text-warning" />
      ) : (
        <span className="text-[13px] leading-[19px] text-muted-foreground">
          €
        </span>
      )}
      <input
        aria-label={label}
        data-eur-field
        data-empty={empty && text === "" ? "true" : undefined}
        inputMode="decimal"
        autoComplete="off"
        disabled={disabled}
        value={text}
        placeholder={formatAmount(estimate ?? null)}
        onChange={event => setText(event.target.value)}
        onFocus={event => {
          setFocused(true)
          event.target.select()
        }}
        onBlur={() => {
          setFocused(false)
          commit()
        }}
        onKeyDown={event => {
          if (event.key === "Enter" && !event.metaKey && !event.ctrlKey) {
            event.currentTarget.blur()
          } else if (event.key === "Escape") {
            setText(formatAmount(value))
            requestAnimationFrame(() => event.currentTarget.blur())
          } else if (event.key === "Tab" && !event.shiftKey) {
            // Tab jumps to the next field that still needs an amount
            const next = nextEmptyField(event.currentTarget)
            if (next) {
              event.preventDefault()
              next.focus()
            }
          }
        }}
        className={cn(
          "w-full min-w-0 flex-1 bg-transparent text-right text-sm leading-5 outline-none placeholder:text-placeholder",
          draft && !focused && "font-semibold",
        )}
      />
    </label>
  )
}

function nextEmptyField(current: HTMLInputElement): HTMLInputElement | null {
  const fields = Array.from(
    document.querySelectorAll<HTMLInputElement>("input[data-eur-field]"),
  )
  const index = fields.indexOf(current)
  return (
    fields.slice(index + 1).find(field => field.dataset.empty === "true") ??
    null
  )
}
