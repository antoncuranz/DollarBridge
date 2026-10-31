"use client"

import {Account, Payment} from "@/types.ts";
import PaymentRow from "@/components/table/PaymentRow.tsx";
import ExchangePaymentDialog from "@/components/dialog/ExchangePaymentDialog.tsx";
import {useState} from "react";
import {useToast} from "@/components/ui/use-toast.ts";
import {useRouter} from "next/navigation";
import {useStore} from "@/store.ts";

export default function PaymentTable({
  payments, accounts
}: {
  payments: Payment[],
  accounts: Account[]
}) {
  const [paymentSelection, setPaymentSelection] = useState<Payment>()
  const [epDialogOpen, setEpDialogOpen] = useState(false)
  const [linkingCashback, setLinkingCashback] = useState(false)

  const { exchangeSelection, setExchangeSelection } = useStore()
  const { toast } = useToast();
  const router = useRouter();

  async function selectPayment(payment: Payment) {
    if (exchangeSelection == null || linkingCashback)
      return

    if (exchangeSelection.cashback_transaction_id == null) {
      setPaymentSelection(payment)
      setEpDialogOpen(true)
      return
    }

    setLinkingCashback(true)
    try {
      const response = await fetch(
        `/api/exchanges/${exchangeSelection.id}?amount=${exchangeSelection.amount_usd}&payment=${payment.id}`,
        {method: "PUT"}
      )
      if (!response.ok) {
        const body = await response.json().catch(() => null)
        toast({title: "Could not link cashback", description: body?.detail || response.statusText})
        return
      }

      setExchangeSelection(null)
      router.refresh()
    } catch (error) {
      toast({title: "Could not link cashback", description: error instanceof Error ? error.message : "Please try again."})
    } finally {
      setLinkingCashback(false)
    }
  }

  function onEpDialogClose(needsUpdate: boolean) {
    setEpDialogOpen(false)

    if (needsUpdate)
      router.refresh()
  }

  async function mutatePayment(url: string, method: "POST" | "DELETE", title: string, description?: string) {
    try {
      const response = await fetch(url, {method})

      if (!response.ok)
        toast({
          title,
          description: description || await response.text() || response.statusText
        })

      if (response.ok)
        router.refresh()
    } catch (error) {
      toast({
        title,
        description: error instanceof Error ? error.message : "Please try again."
      })
    }
  }

  async function processPayment(payment: Payment) {
    await mutatePayment(
      "/api/payments/" + payment.id + "/process",
      "POST",
      "Payment processing failed",
      "Changes were not saved and were reverted."
    )
  }

  async function unprocessPayment(payment: Payment) {
    await mutatePayment("/api/payments/" + payment.id + "/unprocess", "POST", "Error unprocessing payment")
  }

  async function deletePayment(payment: Payment) {
    await mutatePayment("/api/payments/" + payment.id, "DELETE", "Error deleting payment")
  }

  return (
    <>
      <div className="w-full relative">
        {payments.map(payment =>
          <PaymentRow key={payment.id} payment={payment} account={accounts.find(acct => acct.id == payment.account_id)}
                                        selectable={exchangeSelection != null}
                                        onProcessPaymentClick={() => processPayment(payment)}
                                        onUnprocessPaymentClick={() => unprocessPayment(payment)}
                                        onDeletePaymentClick={() => deletePayment(payment)}
                                        onClick={() => void selectPayment(payment)}/>
        )}
      </div>
      {exchangeSelection != null && paymentSelection != null &&
        <ExchangePaymentDialog open={epDialogOpen} onClose={onEpDialogClose} exchange={exchangeSelection.id}
                               payment={paymentSelection}/>}
    </>
  )
}
