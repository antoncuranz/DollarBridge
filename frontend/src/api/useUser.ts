import { useSuspenseQuery } from "@tanstack/react-query"
import { userQuery } from "./queries"
import type { User } from "@/types"

/** The root route only renders pages once the user is loaded. */
export function useUser(): User {
  return useSuspenseQuery(userQuery).data
}
