import type { ReactNode } from "react"

/** Quiet summary tile: label, one big value and a line of explanation. */
export function StatTile({
  label,
  value,
  children,
}: {
  label: ReactNode
  value: ReactNode
  children?: ReactNode
}) {
  return (
    <div className="redactable flex shrink-0 flex-col gap-0.5 rounded-2xl border px-3.5 py-3">
      <p className="text-[13px] leading-[19px] font-medium text-muted-foreground">
        {label}
      </p>
      <p className="tabular text-2xl leading-[34px] font-semibold">{value}</p>
      {children != null && (
        <p className="text-[13px] leading-[21px] text-muted-foreground">
          {children}
        </p>
      )}
    </div>
  )
}

/** Mobile: tiles swipe sideways above the list. */
export function StatTileStrip({ children }: { children: ReactNode }) {
  return (
    <div className="no-scrollbar flex gap-2 overflow-x-auto px-5 pb-1 [&>*]:min-w-[220px]">
      {children}
    </div>
  )
}
