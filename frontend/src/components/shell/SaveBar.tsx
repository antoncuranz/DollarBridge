import { Save } from "lucide-react"
import type { ReactNode } from "react"

/**
 * Floating bar for unsaved edits. Desktop: a dark bar at the bottom of the
 * list. Mobile: a round button with the number of pending edits.
 */
export function SaveBar({
  count,
  label,
  hint,
  saveLabel = "Save amounts",
  saving,
  onSave,
  onDiscard,
}: {
  count: number
  label: ReactNode
  hint?: ReactNode
  saveLabel?: string
  saving?: boolean
  onSave: () => void
  onDiscard: () => void
}) {
  if (count === 0) return null

  return (
    <>
      <div className="pointer-events-none absolute inset-x-0 bottom-0 hidden justify-center pt-2 pb-4 md:flex">
        <div className="pointer-events-auto flex items-center gap-3.5 rounded-bar bg-primary py-1.5 pr-1.5 pl-4 shadow-bar">
          <p className="text-sm leading-5 font-medium whitespace-nowrap text-primary-foreground">
            {label}
          </p>
          {hint && (
            <p className="text-[13px] leading-[19px] whitespace-nowrap text-primary-muted">
              {hint}
            </p>
          )}
          <button
            type="button"
            className="flex h-8 items-center px-2.5 text-sm font-medium text-primary-muted transition-colors hover:text-primary-foreground"
            disabled={saving}
            onClick={onDiscard}
          >
            Discard
          </button>
          <button
            type="button"
            className="flex h-8 items-center gap-1.5 rounded-[10px] bg-card pr-3.5 pl-3 text-sm font-medium text-foreground transition-transform active:scale-[0.98] disabled:opacity-60"
            disabled={saving}
            onClick={onSave}
          >
            <Save className="size-4" />
            {saving ? "Saving…" : saveLabel}
          </button>
        </div>
      </div>
      <button
        type="button"
        aria-label={saveLabel}
        className="absolute right-6 bottom-8 flex size-[60px] items-center justify-center rounded-full bg-primary text-primary-foreground drop-shadow-[0_8px_10px_rgb(0_0_0/0.22)] transition-transform active:scale-95 disabled:opacity-60 md:hidden"
        disabled={saving}
        onClick={onSave}
      >
        <Save className="size-6" />
        <span className="absolute -top-1 left-10 flex h-[22px] items-center justify-center rounded-full border-2 border-card bg-accent px-1.5 text-xs leading-[17px] font-semibold text-accent-foreground">
          {count}
        </span>
      </button>
    </>
  )
}
