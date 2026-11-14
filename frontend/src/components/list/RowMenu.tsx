import { ContextMenu } from "@base-ui/react/context-menu"
import { cn } from "@/lib/utils"
import type { ReactNode } from "react"

export type RowMenuItem = {
  label: string
  onSelect: () => void
  destructive?: boolean
  disabled?: boolean
}

/** Right-click (long-press on touch) menu for secondary row actions. */
export function RowMenu({
  items,
  children,
}: {
  items: Array<RowMenuItem>
  children: ReactNode
}) {
  if (items.length === 0) return <>{children}</>

  return (
    <ContextMenu.Root>
      <ContextMenu.Trigger className="contents">{children}</ContextMenu.Trigger>
      <ContextMenu.Portal>
        <ContextMenu.Positioner className="z-50 outline-none">
          <ContextMenu.Popup className="min-w-40 rounded-row border bg-popover p-1 text-popover-foreground shadow-lg outline-none">
            {items.map(item => (
              <ContextMenu.Item
                key={item.label}
                disabled={item.disabled}
                onClick={item.onSelect}
                className={cn(
                  "flex cursor-pointer items-center rounded-field px-2 py-1.5 text-sm outline-none select-none data-[disabled]:pointer-events-none data-[disabled]:opacity-50 data-[highlighted]:bg-muted",
                  item.destructive && "text-destructive",
                )}
              >
                {item.label}
              </ContextMenu.Item>
            ))}
          </ContextMenu.Popup>
        </ContextMenu.Positioner>
      </ContextMenu.Portal>
    </ContextMenu.Root>
  )
}
