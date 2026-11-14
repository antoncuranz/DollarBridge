import { cn } from "@/lib/utils"
import type { Account } from "@/types"
import type { ReactNode } from "react"

/** The small card-shaped colour chip that identifies an account. */
export function Swatch({
  account,
  color,
  className,
}: {
  account?: Account
  color?: string | null
  className?: string
}) {
  const background = color ?? account?.color
  return (
    <span
      title={account?.name}
      className={cn("h-3.5 w-5 shrink-0 rounded-[3px] bg-border", className)}
      style={background ? { backgroundColor: background } : undefined}
    />
  )
}

export type RowTone = "default" | "selectable" | "selected" | "warning"

const tones: Record<RowTone, string> = {
  default: "border bg-card",
  selectable: "border border-dashed border-accent bg-accent-soft",
  selected: "border-2 border-accent bg-card",
  warning: "border border-warning bg-card",
}

/**
 * One list row. Desktop: a single 40px line (title, description, right-hand
 * columns). Mobile: two lines, with `meta` appended to the description and
 * only `field` (or `value`) on the right.
 */
export function Row({
  swatch,
  title,
  description,
  meta,
  columns,
  field,
  action,
  tone = "default",
  pending,
  dimmed,
  struck,
  expanded,
  className,
  onContextMenu,
}: {
  swatch?: ReactNode
  title: ReactNode
  description?: ReactNode
  /** shown after the description on mobile, where `columns` are hidden */
  meta?: ReactNode
  /** right-aligned read-only columns, desktop only */
  columns?: ReactNode
  /** EUR field or the main value, always visible */
  field?: ReactNode
  action?: ReactNode
  tone?: RowTone
  /** dashed outline for pending items */
  pending?: boolean
  dimmed?: boolean
  struck?: boolean
  /** content shown below the row line (accordion) */
  expanded?: ReactNode
  className?: string
  onContextMenu?: React.MouseEventHandler
}) {
  return (
    <div
      onContextMenu={onContextMenu}
      className={cn(
        "redactable shrink-0 rounded-2xl md:rounded-row",
        !(pending && tone === "default") && "shadow-row",
        tones[tone],
        pending && tone === "default" && "border-dashed",
        dimmed && "opacity-50",
        className,
      )}
    >
      <div
        className={cn(
          "flex h-[50px] items-center gap-2.5 pr-2 pl-3 md:h-[38px] md:pr-1.5",
          tone === "selected" && "h-12 pr-[7px] pl-[11px] md:h-9 md:pr-[5px]",
        )}
      >
        {swatch}
        <div
          className={cn(
            "flex min-w-0 flex-1 flex-col whitespace-nowrap md:flex-row md:items-baseline md:gap-2.5",
            struck && "line-through",
          )}
        >
          <p className="truncate text-sm leading-5 font-medium md:shrink-0 md:overflow-visible">
            {title}
          </p>
          <p className="truncate text-[13px] leading-[19px] text-muted-foreground md:flex-1 md:text-sm md:leading-5">
            {description}
            {meta != null && (
              <span className="md:hidden">
                {description ? " · " : ""}
                {meta}
              </span>
            )}
          </p>
        </div>
        {columns != null && (
          <div className="hidden shrink-0 items-center gap-2.5 md:flex">
            {columns}
          </div>
        )}
        {field}
        {action}
      </div>
      {expanded}
    </div>
  )
}

/** A right-aligned amount column inside a row. */
export function Amount({
  children,
  className,
  struck,
}: {
  children: ReactNode
  className?: string
  struck?: boolean
}) {
  return (
    <span
      className={cn(
        "tabular shrink-0 text-right text-sm leading-5 whitespace-nowrap text-muted-foreground",
        struck && "line-through",
        className,
      )}
    >
      {children}
    </span>
  )
}

/** Read-only value in the place of the EUR field: "€ 92,42". */
export function EurValue({
  amount,
  approximate,
  className,
}: {
  amount: ReactNode
  approximate?: boolean
  className?: string
}) {
  return (
    <span
      className={cn(
        "tabular flex h-8 shrink-0 items-center gap-2 pr-1 pl-2 md:h-7 md:w-[108px] md:gap-1 md:pr-2.5",
        className,
      )}
    >
      <span className="text-[13px] leading-[19px] text-muted-foreground">
        €
      </span>
      <span
        className={cn(
          "flex-1 text-right text-sm leading-5",
          approximate && "text-muted-foreground",
        )}
      >
        {approximate ? "≈ " : ""}
        {amount}
      </span>
    </span>
  )
}

/** Icon-sized action at the end of a row. */
export function RowAction({
  label,
  onClick,
  disabled,
  active,
  children,
}: {
  label: string
  onClick?: () => void
  disabled?: boolean
  active?: boolean
  children: ReactNode
}) {
  return (
    <button
      type="button"
      aria-label={label}
      title={label}
      disabled={disabled}
      onClick={onClick}
      className={cn(
        "flex h-7 shrink-0 items-center rounded-field px-1.5 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground disabled:pointer-events-none disabled:opacity-40 [&_svg]:size-4",
        active && "text-accent",
      )}
    >
      {children}
    </button>
  )
}
