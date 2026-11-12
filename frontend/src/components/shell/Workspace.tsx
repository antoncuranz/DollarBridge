import type { ReactNode } from "react"

import { cn } from "@/lib/utils"

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
  children,
}: {
  sidebar: ReactNode
  mobileTop?: ReactNode
  header: ReactNode
  /** floats at the bottom of the list pane (save bar, FAB) */
  footer?: ReactNode
  children: ReactNode
}) {
  return (
    <div className="flex min-h-0 flex-1 overflow-clip bg-card md:rounded-pane md:border md:shadow-pane">
      <aside className="no-scrollbar hidden w-80 shrink-0 flex-col gap-1.5 overflow-y-auto border-r px-3 pt-2 pb-4 md:flex">
        {sidebar}
      </aside>
      <section className="relative flex min-w-0 flex-1 flex-col">
        <div className="no-scrollbar flex flex-1 flex-col overflow-y-auto pb-28 md:pt-14 md:pb-24">
          {mobileTop && (
            <div className="flex flex-col gap-3 pt-4 pb-1 md:hidden">
              {mobileTop}
            </div>
          )}
          {children}
        </div>
        {header}
        {footer}
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
    <div className="list-header-fade pointer-events-none absolute inset-x-0 top-0 hidden h-14 items-center gap-2.5 py-2 pr-2 pl-5 md:flex">
      {leading && <div className="pointer-events-auto -ml-3">{leading}</div>}
      <div className="flex min-w-0 flex-1 items-baseline gap-2 whitespace-nowrap">
        <h2 className="truncate text-lg leading-[26px] font-semibold">
          {title}
        </h2>
        {subtitle && (
          <p className="truncate text-sm leading-5 text-muted-foreground">
            {subtitle}
          </p>
        )}
      </div>
      <div className="pointer-events-auto flex shrink-0 items-center gap-2">
        {children}
      </div>
    </div>
  )
}

/** Actions that have no room in the mobile layout's missing list header. */
export function MobileActions({ children }: { children: ReactNode }) {
  return (
    <div className="flex items-center justify-end gap-2 px-6 md:hidden">
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
      className={cn("flex flex-col gap-1.5 px-6 md:gap-1 md:px-4", className)}
    >
      {children}
    </div>
  )
}

export function EmptyState({ children }: { children: ReactNode }) {
  return (
    <div className="px-6 py-12 text-center text-sm text-muted-foreground">
      {children}
    </div>
  )
}
