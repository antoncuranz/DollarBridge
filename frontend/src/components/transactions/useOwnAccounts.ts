import { useQuery } from "@tanstack/react-query"
import { useMemo } from "react"

import { accountBalancesQuery, accountsQuery } from "@/api/queries"
import { useUser } from "@/api/useUser"
import { accountById } from "@/lib/derive"

/** Accounts split into the user's own active cards and other users' cards. */
export function useAccounts() {
  const user = useUser()
  const { data: accounts = [], isPending } = useQuery(accountsQuery)
  const { data: balances } = useQuery(accountBalancesQuery)

  return useMemo(() => {
    const active = accounts.filter(account => account.active)
    return {
      /** the accounts are still loading */
      isPending,
      accounts,
      balances,
      byId: accountById(accounts),
      own: active.filter(account => account.user.id === user.id),
      others: active.filter(account => account.user.id !== user.id),
    }
  }, [accounts, balances, isPending, user.id])
}
