import { useQuery } from "@tanstack/react-query"
import { Outlet, createRootRouteWithContext } from "@tanstack/react-router"
import type { QueryClient } from "@tanstack/react-query"

import { userQuery } from "@/api/queries"
import { Header } from "@/components/shell/Header"
import { Toaster } from "@/components/ui/sonner"
import { cn } from "@/lib/utils"
import { usePreferences } from "@/store"

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()(
  {
    component: Root,
  },
)

function Root() {
  const { data: user, error } = useQuery(userQuery)
  const privacyMode = usePreferences(state => state.privacyMode)

  return (
    <div
      className={cn(
        "root flex h-dvh flex-col bg-card md:bg-background md:px-6 md:pb-4",
        privacyMode && "privacy",
      )}
    >
      <Header />
      {user ? (
        <Outlet />
      ) : (
        <div className="flex flex-1 items-center justify-center text-sm text-muted-foreground">
          {error ? "Could not load your user: " + error.message : null}
        </div>
      )}
      <Toaster />
    </div>
  )
}
