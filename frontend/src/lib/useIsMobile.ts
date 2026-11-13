import { useSyncExternalStore } from "react"

const query = "(max-width: 767px)"

function subscribe(callback: () => void) {
  const media = window.matchMedia(query)
  media.addEventListener("change", callback)
  return () => media.removeEventListener("change", callback)
}

/** below Tailwind's `md` breakpoint */
export function useIsMobile(): boolean {
  return useSyncExternalStore(
    subscribe,
    () => window.matchMedia(query).matches,
    () => false,
  )
}
