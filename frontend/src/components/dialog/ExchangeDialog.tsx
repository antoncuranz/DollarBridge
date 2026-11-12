import { format } from "date-fns"
import { Check } from "lucide-react"
import { useId, useState } from "react"

import { AmountField, ComputedField, Dialog, Field, FieldRow } from "./Dialog"
import { useCreateExchange } from "@/api/mutations"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { exchangeAmountEur } from "@/lib/derive"
import { formatAmount, formatGrouped } from "@/lib/money"

/** Adds a USD exchange. EUR amount and fees are derived and shown read-only. */
export function ExchangeDialog({ onClose }: { onClose: () => void }) {
  const dateId = useId()
  const [date, setDate] = useState(() => format(new Date(), "yyyy-MM-dd"))
  const [amountUsd, setAmountUsd] = useState<number | null>(null)
  const [rate, setRate] = useState<number | null>(null)
  const [paidEur, setPaidEur] = useState<number | null>(null)

  const amountEur =
    amountUsd != null && rate ? exchangeAmountEur(amountUsd, rate) : null
  const fees = amountEur != null && paidEur != null ? paidEur - amountEur : null
  const complete =
    date !== "" &&
    amountUsd != null &&
    amountUsd > 0 &&
    !!rate &&
    paidEur != null

  const mutation = useCreateExchange()

  function save() {
    if (!complete) return
    mutation.mutate(
      { date, amount_usd: amountUsd, paid_eur: paidEur, exchange_rate: rate },
      { onSuccess: onClose },
    )
  }

  return (
    <Dialog
      open
      onClose={onClose}
      title="Add exchange"
      footer={
        <Button
          size="lg"
          className="flex-1 rounded-full"
          disabled={!complete || mutation.isPending}
          onClick={save}
        >
          <Check />
          {mutation.isPending ? "Saving…" : "Save"}
        </Button>
      }
    >
      <FieldRow>
        <Field label="Date" htmlFor={dateId}>
          <Input
            id={dateId}
            type="date"
            value={date}
            onChange={event => setDate(event.target.value)}
          />
        </Field>
        <AmountField
          label="Amount (USD)"
          format="usd"
          autoFocus
          value={amountUsd}
          onChange={setAmountUsd}
        />
      </FieldRow>
      <FieldRow>
        <AmountField
          label="Exchange rate (IBKR)"
          format="rate"
          placeholder="1.0820"
          value={rate}
          onChange={setRate}
        />
        <ComputedField
          label="Amount (EUR)"
          prefix="€"
          hint={
            amountUsd != null && rate
              ? `= ${formatGrouped(amountUsd)} ÷ ${(rate / 1e7).toString()}`
              : "= Amount (USD) ÷ rate"
          }
        >
          {amountEur != null ? formatAmount(amountEur) : "–"}
        </ComputedField>
      </FieldRow>
      <FieldRow>
        <AmountField
          label="Paid (EUR)"
          format="eur"
          value={paidEur}
          onChange={setPaidEur}
        />
        <ComputedField label="Fees (EUR)" prefix="€" hint="= Paid − Amount">
          {fees != null ? formatAmount(fees) : "–"}
        </ComputedField>
      </FieldRow>
    </Dialog>
  )
}
