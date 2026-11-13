import { useMutation, useQueryClient } from "@tanstack/react-query"
import { toast } from "sonner"

import { api, describeError } from "./client"
import { keys } from "./queries"
import type {
  Issuer,
  TransactionAmountMap,
  TransactionAmountsResult,
} from "@/types"

type Options<TVariables, TData> = {
  mutationFn: (variables: TVariables) => Promise<TData>
  /** query keys that are refetched after success */
  invalidates: ReadonlyArray<ReadonlyArray<unknown>>
  /** toast title on failure */
  errorTitle: string
  onSuccess?: (data: TData, variables: TVariables) => void
}

/** Mutation that toasts failures and refreshes the affected queries. */
export function useApiMutation<TVariables = void, TData = void>({
  mutationFn,
  invalidates,
  errorTitle,
  onSuccess,
}: Options<TVariables, TData>) {
  const queryClient = useQueryClient()
  return useMutation({
    mutationFn,
    onError: error => {
      toast.error(errorTitle, { description: describeError(error) })
    },
    onSuccess: (data, variables) => {
      onSuccess?.(data, variables)
    },
    onSettled: () =>
      Promise.all(
        invalidates.map(queryKey =>
          queryClient.invalidateQueries({ queryKey }),
        ),
      ),
  })
}

/** everything that depends on transaction amounts */
const amountDependents = [keys.transactions, keys.payments, keys.allBalances]

export function useSaveAmounts(
  onSaved?: (saved: TransactionAmountMap) => void,
) {
  return useApiMutation({
    mutationFn: (amounts: TransactionAmountMap) =>
      api.put<TransactionAmountsResult>("/api/transactions/amounts", {
        json: Object.entries(amounts).map(([id, amount_eur]) => ({
          id: Number(id),
          amount_eur,
        })),
      }),
    invalidates: amountDependents,
    errorTitle: "Amounts were not saved",
    onSuccess: (result, amounts) => {
      if (result.actual_failed.length > 0) {
        toast.warning("Saved, but not everything reached Actual", {
          description: `${result.actual_failed.length} of ${result.saved.length} transactions could not be updated in Actual. Run the Actual export to retry.`,
        })
      } else {
        toast.success(
          result.saved.length === 1
            ? "1 amount saved"
            : `${result.saved.length} amounts saved`,
        )
      }
      onSaved?.(amounts)
    },
  })
}

export function useCashback() {
  return useApiMutation({
    mutationFn: ({ id, undo }: { id: number; undo: boolean }) =>
      api.post(
        `/api/transactions/${id}/${undo ? "undo-cashback" : "cashback"}`,
      ),
    invalidates: [...amountDependents, keys.exchanges],
    errorTitle: "Could not change cashback",
    onSuccess: (_, { undo }) =>
      toast.success(
        undo ? "Cashback undone" : "Transaction marked as cashback",
      ),
  })
}

export function useApplyCredit() {
  return useApiMutation({
    mutationFn: async ({
      creditId,
      transactionId,
      amount,
      adjustedAmountEur,
    }: {
      creditId: number
      transactionId: number
      amount: number
      /** undefined: leave the transaction's EUR amount as it is */
      adjustedAmountEur?: number
    }) => {
      await api.put(`/api/credits/${creditId}`, {
        params: { amount, transaction: transactionId },
      })
      if (adjustedAmountEur !== undefined) {
        await api.put(`/api/transactions/${transactionId}`, {
          params: { amount_eur: adjustedAmountEur },
        })
      }
    },
    invalidates: [...amountDependents, keys.credits],
    errorTitle: "Could not apply credit",
  })
}

export function useImport() {
  return useApiMutation({
    mutationFn: (accountId: number) => api.post(`/api/import/${accountId}`),
    invalidates: [
      keys.transactions,
      keys.credits,
      keys.payments,
      keys.allBalances,
      keys.bankAccounts,
    ],
    errorTitle: "Import failed",
    onSuccess: () => toast.success("Import finished"),
  })
}

export function useActualExport() {
  return useApiMutation({
    mutationFn: (accountId: number) =>
      api.post(`/api/export/actual/${accountId}`),
    invalidates: [keys.transactions],
    errorTitle: "Actual export failed",
    onSuccess: () => toast.success("Exported to Actual"),
  })
}

const exchangeDependents = [keys.exchanges, keys.payments, keys.allBalances]

export function useCreateExchange() {
  return useApiMutation({
    mutationFn: (exchange: {
      date: string
      amount_usd: number
      paid_eur: number
      /** rate × 10⁷ */
      exchange_rate: number
    }) => api.post("/api/exchanges", { json: exchange }),
    invalidates: exchangeDependents,
    errorTitle: "Could not add exchange",
  })
}

export function useDeleteExchange() {
  return useApiMutation({
    mutationFn: (exchangeId: number) =>
      api.delete(`/api/exchanges/${exchangeId}`),
    invalidates: exchangeDependents,
    errorTitle: "Could not delete exchange",
  })
}

export function useApplyExchange() {
  return useApiMutation({
    mutationFn: ({
      exchangeId,
      paymentId,
      amount,
    }: {
      exchangeId: number
      paymentId: number
      amount: number
    }) =>
      api.put(`/api/exchanges/${exchangeId}`, {
        params: { amount, payment: paymentId },
      }),
    invalidates: exchangeDependents,
    errorTitle: "Could not apply exchange",
  })
}

const paymentDependents = [
  keys.payments,
  keys.transactions,
  keys.exchanges,
  keys.allBalances,
  keys.credits,
]

export function useProcessPayment() {
  return useApiMutation({
    mutationFn: (paymentId: number) =>
      api.post(`/api/payments/${paymentId}/process`),
    invalidates: paymentDependents,
    errorTitle: "Payment processing failed",
    onSuccess: () => toast.success("Payment processed"),
  })
}

export function useUnprocessPayment() {
  return useApiMutation({
    mutationFn: (paymentId: number) =>
      api.post(`/api/payments/${paymentId}/unprocess`),
    invalidates: paymentDependents,
    errorTitle: "Could not unprocess payment",
    onSuccess: () => toast.success("Payment is open again"),
  })
}

export function useDeletePayment() {
  return useApiMutation({
    mutationFn: (paymentId: number) => api.delete(`/api/payments/${paymentId}`),
    invalidates: paymentDependents,
    errorTitle: "Could not delete payment",
  })
}

export type AccountInput = {
  name: string
  institution: string
  issuer: Issuer | null
  due_day: number | null
  autopay_offset: number | null
  color: string | null
  target_spend: number | null
  bank_account_id: number | null
  plaid_account_id: number | null
  actual_id: string | null
  active: boolean
}

const accountDependents = [
  keys.accounts,
  keys.bankAccounts,
  keys.allBalances,
  keys.dates,
]

export function useSaveAccount(accountId: number | undefined) {
  return useApiMutation({
    mutationFn: (account: AccountInput) =>
      accountId == null
        ? api.post<unknown>("/api/accounts", { json: account })
        : api.put<unknown>(`/api/accounts/${accountId}`, { json: account }),
    invalidates: accountDependents,
    errorTitle: "Could not save credit card",
  })
}

export type BankAccountInput = {
  name: string
  institution: string
  plaid_account_id: number | null
}

export function useSaveBankAccount(bankAccountId: number | undefined) {
  return useApiMutation({
    mutationFn: (bankAccount: BankAccountInput) =>
      bankAccountId == null
        ? api.post<unknown>("/api/bank_accounts", { json: bankAccount })
        : api.put<unknown>(`/api/bank_accounts/${bankAccountId}`, {
            json: bankAccount,
          }),
    invalidates: accountDependents,
    errorTitle: "Could not save bank account",
  })
}

export function useDiscoverPlaidAccounts() {
  return useApiMutation({
    mutationFn: (connectionId: number) =>
      api.post(`/api/import/plaid/connections/${connectionId}/discover`),
    invalidates: [keys.connections],
    errorTitle: "Could not look for new accounts",
    onSuccess: () => toast.success("Accounts of the connection updated"),
  })
}

export function useDeleteConnection() {
  return useApiMutation({
    mutationFn: (connectionId: number) =>
      api.delete(`/api/import/plaid/connections/${connectionId}`),
    invalidates: [keys.connections, ...accountDependents],
    errorTitle: "Could not delete connection",
  })
}
