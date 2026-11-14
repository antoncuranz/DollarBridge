import { describeError } from "@/api/client"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"
import type { ReactNode } from "react"

/**
 * The page body. Desktop: one card with a sidebar and the list pane, whose
 * header floats over the scrolling rows. Mobile: `mobileTop` replaces the
 * sidebar and scrolls away with the list.
 */
export function Workspace({
  sidebar,
  mobileTop,
  header,
  footer,
  thumb,
  thumbRaised,
  children,
}: {
  sidebar: ReactNode
  mobileTop?: ReactNode
  header: ReactNode
  /** floats at the bottom of the list pane (save bar, FAB) */
  footer?: ReactNode
  /** mobile: round buttons in thumb reach, replacing the header actions */
  thumb?: ReactNode
  /** leaves room below the thumb buttons for the save button */
  thumbRaised?: boolean
  children: ReactNode
}) {
  return (
    <div className="flex flex-1 bg-card md:min-h-0 md:overflow-clip md:rounded-[1.75rem] md:border md:shadow-pane">
      <aside className="no-scrollbar hidden w-80 shrink-0 flex-col gap-1.5 overflow-y-auto border-r px-3 pt-2 pb-4 md:flex">
        {sidebar}
      </aside>
      <section className="relative flex min-w-0 flex-1 flex-col">
        <div className="no-scrollbar flex flex-1 flex-col pt-3 md:overflow-y-auto pb-28 md:pt-18 md:pb-24">
          {mobileTop && (
            <div className="flex flex-col gap-3 pt-1 pb-1 md:hidden">
              {mobileTop}
            </div>
          )}
          {children}
        </div>
        {header}
        {footer}
        {thumb && (
          <div
            className={cn(
              "fixed right-5 z-30 flex flex-col-reverse items-center gap-3 md:hidden",
              thumbRaised ? "bottom-22" : "bottom-6",
            )}
          >
            {thumb}
          </div>
        )}
      </section>
    </div>
  )
}

export function ListHeader({
  title,
  subtitle,
  leading,
  children,
}: {
  title: ReactNode
  subtitle?: ReactNode
  leading?: ReactNode
  /** actions on the right */
  children?: ReactNode
}) {
  return (
    <div className="absolute top-0 right-0 left-0 z-20 hidden md:block">
      <div className="pane-header-blur" />
      <div className="relative flex flex-row items-center gap-2 p-2">
        {leading}
        <div
          className={cn(
            "flex min-w-0 grow items-baseline gap-2 whitespace-nowrap",
            !leading && "ml-3",
          )}
        >
          <h2 className="truncate text-lg leading-10 font-semibold">{title}</h2>
          {subtitle && (
            <p className="truncate text-sm leading-5 text-muted-foreground">
              {subtitle}
            </p>
          )}
        </div>
        <div className="flex shrink-0 items-center gap-2">{children}</div>
      </div>
    </div>
  )
}

/** Actions that have no room in the mobile layout's missing list header. */
export function MobileActions({ children }: { children: ReactNode }) {
  return (
    <div className="flex items-center justify-end gap-2 px-5 md:hidden">
      {children}
    </div>
  )
}

export function Rows({
  className,
  children,
}: {
  className?: string
  children: ReactNode
}) {
  return (
    <div
      className={cn("flex flex-col gap-1.5 px-5 md:gap-1 md:px-4", className)}
    >
      {children}
    </div>
  )
}

/** Shown instead of a list whose data could not be loaded. */
export function ErrorState({
  error,
  onRetry,
}: {
  error: unknown
  onRetry: () => void
}) {
  return (
    <div
      role="alert"
      className="flex flex-col items-center gap-3 px-5 py-12 text-center text-sm"
    >
      <div>
        <p className="font-medium text-destructive">Could not load the data</p>
        <p className="text-muted-foreground">{describeError(error)}</p>
      </div>
      <Button variant="secondary" onClick={onRetry}>
        Try again
      </Button>
    </div>
  )
}

export function EmptyState({ children }: { children: ReactNode }) {
  return (
    <div className="px-5 py-12 text-center text-sm text-muted-foreground">
      {children}
    </div>
  )
}
