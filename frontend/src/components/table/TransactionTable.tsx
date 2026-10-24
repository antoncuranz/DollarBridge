"use client"

import {Account, Transaction} from "@/types.ts";
import {useState} from "react";
import {useRouter} from "next/navigation";
import TransactionRow from "@/components/table/TransactionRow.tsx";
import CreditTransactionDialog from "@/components/dialog/CreditTransactionDialog.tsx";
import {useStore} from "@/store.ts";
import {useToast} from "@/components/ui/use-toast.ts";

interface Props {
  transactions: Transaction[],
  accounts: Account[],
  canMarkCashback?: boolean
}

const TransactionTable = ({transactions, accounts, canMarkCashback = false}: Props) => {
  const [transactionSelection, setTransactionSelection] = useState<Transaction|null>()
  const [ctDialogOpen, setCtDialogOpen] = useState(false)

  const { currentAccount, creditSelection, filterMissingAmountEur, clearTransactionAmount } = useStore()
  const { toast } = useToast()

  const router = useRouter();

  function getFilteredTransactions() {
    return transactions.filter(tx =>
      (currentAccount == null || tx.account_id == currentAccount.id) && (!filterMissingAmountEur || tx.amount_eur == null)
    )
  }

  function openCreditTransactionDialog(tx: Transaction) {
    if (creditSelection != null) {
      setTransactionSelection(tx)
      setCtDialogOpen(true)
    }
  }

  function onDialogClose(needsUpdate: boolean) {
    setCtDialogOpen(false)

    if (needsUpdate)
      router.refresh()
  }

  async function markCashback(tx: Transaction) {
    await mutateCashback(tx, "cashback", "Transaction marked as cashback")
  }

  async function undoCashback(tx: Transaction) {
    await mutateCashback(tx, "undo-cashback", "Cashback undone")
  }

  async function mutateCashback(tx: Transaction, action: "cashback" | "undo-cashback", successTitle: string) {
    try {
      const response = await fetch(`/api/transactions/${tx.id}/${action}`, {method: "POST"})
      if (!response.ok) {
        toast({
          title: `Could not ${action == "cashback" ? "mark transaction as cashback" : "undo cashback"}`,
          description: await response.text() || response.statusText,
        })
        return
      }

      clearTransactionAmount(tx.id)
      toast({title: successTitle})
      router.refresh()
    } catch (error) {
      toast({
        title: `Could not ${action == "cashback" ? "mark transaction as cashback" : "undo cashback"}`,
        description: error instanceof Error ? error.message : "Please try again.",
      })
    }
  }

  return (
    <>
      <div className="w-full relative">
        {getFilteredTransactions().map(tx =>
          <TransactionRow key={tx.id} transaction={tx} account={accounts.find(a => a.id == tx.account_id)}
                          readonly={creditSelection != null} selectable={creditSelection != null}
                          canMarkCashback={canMarkCashback} onCashback={markCashback} onUndoCashback={undoCashback}
                          onClick={() => openCreditTransactionDialog(tx)}/>
        )}
      </div>
      <CreditTransactionDialog open={ctDialogOpen} onClose={onDialogClose} credit={creditSelection?.id ?? -1} transaction={transactionSelection!}/>
    </>
  )
}

export default TransactionTable
