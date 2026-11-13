import { Rows } from "@/components/shell/Workspace"
import { Skeleton } from "@/components/ui/skeleton"
import { cn } from "@/lib/utils"

// widths of title and description, varied so the rows do not look stamped
const shapes = [
  ["w-24", "w-40"],
  ["w-32", "w-28"],
  ["w-20", "w-52"],
  ["w-28", "w-36"],
  ["w-36", "w-24"],
  ["w-24", "w-44"],
] as const

function RowSkeleton({ index, tall }: { index: number; tall?: boolean }) {
  const [title, description] = shapes[index % shapes.length] ?? shapes[0]
  return (
    <div
      className={cn(
        "flex shrink-0 items-center gap-2.5 rounded-2xl border pr-2 pl-3 md:rounded-row md:pr-1.5",
        tall ? "h-14 md:h-14" : "h-[52px] md:h-10",
      )}
    >
      <Skeleton className="h-3.5 w-5 shrink-0 rounded-[3px]" />
      <div
        className={cn(
          "flex min-w-0 flex-1 flex-col gap-2",
          !tall && "md:flex-row md:items-center md:gap-2.5",
        )}
      >
        <Skeleton className={cn("h-3.5 max-w-full", title)} />
        <Skeleton className={cn("h-3 max-w-full", description)} />
      </div>
      <Skeleton className="hidden h-3.5 w-14 md:block" />
      <Skeleton className="h-8 w-[100px] rounded-field md:h-7 md:w-[108px]" />
    </div>
  )
}

/**
 * Stand-in for a grouped list while it loads: the same separators and row
 * heights as the real list, so nothing jumps when the data arrives.
 */
export function ListSkeleton({
  groups = [2, 4, 3],
  tall,
}: {
  /** number of rows per group */
  groups?: Array<number>
  /** two-line rows, as on the Accounts page */
  tall?: boolean
}) {
  let index = 0
  return (
    <div role="status" aria-label="Loading">
      {groups.map((count, group) => (
        <div key={group} className="flex flex-col">
          <div
            className={cn(
              "flex shrink-0 flex-col gap-2",
              group === 0 ? "pt-1 pb-4" : "py-4",
            )}
          >
            {group > 0 && <div className="h-px w-full bg-border" />}
            <div className="flex h-5 items-center justify-between px-5 md:h-[19px] md:pr-6">
              <Skeleton className="h-3 w-36" />
              <Skeleton className="h-3 w-16" />
            </div>
          </div>
          <Rows>
            {Array.from({ length: count }, () => {
              index += 1
              return <RowSkeleton key={index} index={index} tall={tall} />
            })}
          </Rows>
        </div>
      ))}
    </div>
  )
}
