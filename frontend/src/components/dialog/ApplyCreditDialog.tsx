import { Check, Link as LinkIcon } from "lucide-react"
import { useState } from "react"

import { AmountField, ContextBox, ContextLine, Dialog } from "./Dialog"
import type { Account, Credit, Transaction } from "@/types"
import { useApplyCredit } from "@/api/mutations"
import { Swatch } from "@/components/list/Row"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { formatShortDay } from "@/lib/dates"
import {
  appliedCredits,
  creditRemainder,
  suggestedAmountAfterCredit,
} from "@/lib/derive"
import { formatAmount, formatUsd } from "@/lib/money"

/** Applies (part of) a credit to a transaction. */
export function ApplyCreditDialog({
  credit,
  transaction,
  account,
  onClose,
}: {
  credit: Credit
  transaction: Transaction
  account?: Account
  onClose: () => void
}) {
  const existing =
    transaction.credits.find(ct => ct.credit_id === credit.id)?.amount ?? 0
  // what this credit and this transaction can still take, not counting the
  // part of this credit that is already on this transaction
  const creditLeft = creditRemainder(credit) + existing
  const transactionOpen =
    transaction.amount_usd - appliedCredits(transaction) + existing
  const maximum = Math.max(Math.min(creditLeft, transactionOpen), 0)

  const [amount, setAmount] = useState<number | null>(
    existing > 0 ? existing : maximum,
  )
  const [adjust, setAdjust] = useState(true)
  const [adjustedOverride, setAdjustedOverride] = useState<
    number | null | undefined
  >(undefined)

  const applied = amount ?? 0
  const suggestion = suggestedAmountAfterCredit(transaction, applied - existing)
  const adjusted =
    adjustedOverride !== undefined ? adjustedOverride : suggestion
  const tooMuch = applied > maximum || applied < 0

  const mutation = useApplyCredit()

  function save() {
    mutation.mutate(
      {
        creditId: credit.id,
        transactionId: transaction.id,
        amount: applied,
        adjustedAmountEur: adjust ? adjusted : undefined,
      },
      { onSuccess: onClose },
    )
  }

  const before = transaction.amount_eur ?? transaction.guessed_amount_eur

  return (
    <Dialog
      open
      onClose={onClose}
      title="Apply credit"
      footer={
        <Button
          size="lg"
          className="flex-1 rounded-full"
          disabled={tooMuch || mutation.isPending}
          onClick={save}
        >
          <Check />
          {mutation.isPending ? "Saving…" : "Save"}
        </Button>
      }
    >
      <ContextBox>
        <ContextLine
          leading={<Swatch account={account} />}
          title={credit.counterparty}
          detail={`credit · ${formatUsd(creditLeft)} left`}
        />
        <ContextLine
          leading={
            <LinkIcon className="size-4 shrink-0 text-muted-foreground" />
          }
          title={transaction.counterparty}
          detail={[
            formatUsd(transaction.amount_usd),
            account?.name,
            formatShortDay(transaction.date),
          ]
            .filter(Boolean)
            .join(" · ")}
        />
      </ContextBox>

      <AmountField
        label="Credit applied"
        format="usd"
        autoFocus
        value={amount}
        onChange={value => {
          setAmount(value)
          setAdjustedOverride(undefined)
        }}
        hint={
          tooMuch ? (
            <span className="text-destructive">
              At most {formatUsd(maximum)} can be applied here
            </span>
          ) : (
            `Up to ${formatUsd(creditLeft)} (remaining credit) and ${formatUsd(transactionOpen)} (transaction)`
          )
        }
      />

      <label className="flex items-center gap-2 text-[13px] leading-[19px] font-medium">
        <Switch checked={adjust} onCheckedChange={setAdjust} />
        Adjust EUR amount of the transaction
      </label>

      {adjust && (
        <AmountField
          label="Amount (EUR)"
          format="eur"
          value={adjusted}
          onChange={setAdjustedOverride}
          hint={
            before != null
              ? `Was ${formatAmount(before)} · suggested from the remaining ${formatUsd(Math.max(transactionOpen - applied, 0))} at the ${transaction.amount_eur != null ? "current" : "estimate"} rate`
              : "No estimate available for this transaction"
          }
        />
      )}

      <p className="text-[13px] leading-[17px] text-muted-foreground">
        {applied === 0 && existing > 0
          ? "This removes the credit from the transaction."
          : `The credit keeps ${formatUsd(Math.max(creditLeft - applied, 0))} after this.`}
      </p>
    </Dialog>
  )
}
