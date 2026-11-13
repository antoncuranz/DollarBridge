import { useQuery } from "@tanstack/react-query"
import { Outlet, createRootRouteWithContext } from "@tanstack/react-router"

import { userQuery } from "@/api/queries"
import { ListSkeleton } from "@/components/list/ListSkeleton"
import { Header } from "@/components/shell/Header"
import { ListHeader, Workspace } from "@/components/shell/Workspace"
import { SidebarItemsSkeleton } from "@/components/sidebar/SidebarSkeleton"
import { Skeleton } from "@/components/ui/skeleton"
import { Toaster } from "@/components/ui/sonner"
import { cn } from "@/lib/utils"
import { usePreferences } from "@/store"
import type { QueryClient } from "@tanstack/react-query"

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
      ) : error ? (
        <div className="flex flex-1 items-center justify-center text-sm text-muted-foreground">
          Could not load your user: {error.message}
        </div>
      ) : (
        <Workspace
          sidebar={<SidebarItemsSkeleton count={6} />}
          header={<ListHeader title={<Skeleton className="h-5 w-40" />} />}
        >
          <ListSkeleton />
        </Workspace>
      )}
      <Toaster />
    </div>
  )
}
