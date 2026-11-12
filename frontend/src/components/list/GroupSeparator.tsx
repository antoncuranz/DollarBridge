import type { ReactNode } from "react"

import { cn } from "@/lib/utils"

/** Divider line plus a label row that starts a group of rows. */
export function GroupSeparator({
  label,
  info,
  action,
  first,
}: {
  label: ReactNode
  info?: ReactNode
  /** small control after the info text */
  action?: ReactNode
  /** the first group of a list has no divider line */
  first?: boolean
}) {
  return (
    <div
      className={cn(
        "flex shrink-0 flex-col gap-2",
        first ? "pt-1 pb-4" : "py-4",
      )}
    >
      {!first && <div className="h-px w-full bg-border" />}
      <div className="flex items-center justify-between gap-4 px-6 text-[13px] leading-[19px] whitespace-nowrap text-muted-foreground md:pr-6 md:pl-5">
        <p className="truncate font-medium">{label}</p>
        <div className="flex shrink-0 items-center gap-1.5">
          <p>{info}</p>
          {action}
        </div>
      </div>
    </div>
  )
}
