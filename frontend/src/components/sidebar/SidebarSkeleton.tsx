import { Skeleton } from "@/components/ui/skeleton"

/** Placeholder for sidebar lines (accounts, connections). */
export function SidebarItemsSkeleton({ count = 4 }: { count?: number }) {
  return (
    <>
      {Array.from({ length: count }, (_, index) => (
        <div
          key={index}
          className="flex h-12 shrink-0 items-center gap-2.5 px-2.5"
        >
          <Skeleton className="h-3.5 w-5 shrink-0 rounded-[3px]" />
          <div className="flex flex-1 flex-col gap-1.5">
            <Skeleton className={index % 2 ? "h-3.5 w-32" : "h-3.5 w-24"} />
            <Skeleton className="h-2.5 w-20" />
          </div>
          <Skeleton className="h-3.5 w-12" />
        </div>
      ))}
    </>
  )
}

export function StatTileSkeleton() {
  return (
    <div className="flex shrink-0 flex-col gap-2 rounded-2xl border px-3.5 py-3">
      <Skeleton className="h-3 w-28" />
      <Skeleton className="h-7 w-32" />
      <Skeleton className="h-3 w-40" />
    </div>
  )
}

/** Mobile: placeholder for the swipeable account cards. */
export function AccountCardsSkeleton() {
  return (
    <div className="flex gap-2 overflow-hidden px-5 pb-1">
      {Array.from({ length: 3 }, (_, index) => (
        <div
          key={index}
          className="flex h-[105px] w-[148px] shrink-0 flex-col gap-2 rounded-2xl border px-3 py-2.5"
        >
          <Skeleton className="h-3.5 w-20" />
          <Skeleton className="h-6 w-24" />
          <Skeleton className="h-3 w-16" />
          <Skeleton className="h-3 w-24" />
        </div>
      ))}
    </div>
  )
}
