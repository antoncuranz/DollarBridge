import { queryOptions } from "@tanstack/react-query"
import { api } from "./client"
import type {
  Account,
  AccountBalances,
  AccountDatesMap,
  Balances,
  BankAccount,
  Credit,
  Exchange,
  FeeSummary,
  Payment,
  PlaidConnection,
  Transaction,
  User,
} from "@/types"

type Range = { from: string; to: string }

export const keys = {
  user: ["user"] as const,
  accounts: ["accounts"] as const,
  bankAccounts: ["bank-accounts"] as const,
  /** prefix of every balance query: total, per account and fees */
  allBalances: ["balances"] as const,
  accountBalances: ["balances", "accounts"] as const,
  balances: ["balances", "total"] as const,
  fees: ["balances", "fees"] as const,
  transactions: ["transactions"] as const,
  credits: ["credits"] as const,
  exchanges: ["exchanges"] as const,
  payments: ["payments"] as const,
  dates: ["dates"] as const,
  connections: ["plaid-connections"] as const,
}

export const userQuery = queryOptions({
  queryKey: keys.user,
  queryFn: () => api.get<User>("/api/user"),
  staleTime: Infinity,
})

export const accountsQuery = queryOptions({
  queryKey: keys.accounts,
  queryFn: () => api.get<Array<Account>>("/api/accounts"),
})

export const bankAccountsQuery = queryOptions({
  queryKey: keys.bankAccounts,
  queryFn: () => api.get<Array<BankAccount>>("/api/bank_accounts"),
})

export const accountBalancesQuery = queryOptions({
  queryKey: keys.accountBalances,
  queryFn: () => api.get<AccountBalances>("/api/balance/accounts"),
})

/** super user only */
export const balancesQuery = queryOptions({
  queryKey: keys.balances,
  queryFn: () => api.get<Balances>("/api/balance"),
})

/** super user only */
export const feesQuery = (range: Range) =>
  queryOptions({
    queryKey: [...keys.fees, range],
    queryFn: () => api.get<FeeSummary>("/api/balance/fees", range),
  })

export const openTransactionsQuery = queryOptions({
  queryKey: [...keys.transactions, "open"],
  queryFn: () =>
    api.get<Array<Transaction>>("/api/transactions", { paid: false }),
})

export const paidTransactionsQuery = (range: Range) =>
  queryOptions({
    queryKey: [...keys.transactions, "paid", range],
    queryFn: () =>
      api.get<Array<Transaction>>("/api/transactions", {
        paid: true,
        ...range,
      }),
  })

export const usableCreditsQuery = queryOptions({
  queryKey: [...keys.credits, "usable"],
  queryFn: () => api.get<Array<Credit>>("/api/credits", { usable: true }),
})

/** super user only */
export const usableExchangesQuery = queryOptions({
  queryKey: [...keys.exchanges, "usable"],
  queryFn: () => api.get<Array<Exchange>>("/api/exchanges", { usable: true }),
})

export const openPaymentsQuery = queryOptions({
  queryKey: [...keys.payments, "open"],
  queryFn: () => api.get<Array<Payment>>("/api/payments", { processed: false }),
})

export const processedPaymentsQuery = (range: Range) =>
  queryOptions({
    queryKey: [...keys.payments, "processed", range],
    queryFn: () =>
      api.get<Array<Payment>>("/api/payments", { processed: true, ...range }),
  })

export const datesQuery = (year: number, month: number) =>
  queryOptions({
    queryKey: [...keys.dates, year, month],
    queryFn: () => api.get<AccountDatesMap>(`/api/dates/${year}/${month}`),
    staleTime: 60 * 60 * 1000,
  })

export const connectionsQuery = queryOptions({
  queryKey: keys.connections,
  queryFn: () =>
    api.get<Array<PlaidConnection>>("/api/import/plaid/connections"),
})

type Loadable = { data: unknown; error: unknown; refetch: () => unknown }

/**
 * The failure of the first query that has no data because it failed, so a
 * page can show an error instead of an empty list. A failed background
 * refetch keeps the data it had and is not reported.
 */
export function queryFailure(...queries: Array<Loadable>) {
  const failed = queries.filter(
    query => query.error != null && query.data === undefined,
  )
  const first = failed[0]
  if (!first) return null
  return {
    error: first.error,
    retry: () => failed.forEach(query => void query.refetch()),
  }
}
