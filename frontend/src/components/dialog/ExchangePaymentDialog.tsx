import { ArrowLeftRight, Check } from "lucide-react"
import { useState } from "react"
import { useApplyExchange } from "@/api/mutations"
import { Swatch } from "@/components/list/Row"
import { Button } from "@/components/ui/button"
import { formatShortDay } from "@/lib/dates"
import {
  exchangeAmountEurShare,
  exchangeRemainder,
  paymentRemainder,
} from "@/lib/derive"
import { formatAmount, formatRate, formatUsd } from "@/lib/money"
import {
  AmountField,
  ContextBox,
  ContextLine,
  Dialog,
  useInvalidFields,
} from "./Dialog"
import type { Account, Exchange, Payment } from "@/types"

/** Allocates part of an exchange to a payment. */
export function ExchangePaymentDialog({
  exchange,
  payment,
  account,
  onClose,
}: {
  exchange: Exchange
  payment: Payment
  account?: Account
  onClose: () => void
}) {
  const existing =
    payment.exchanges.find(ep => ep.exchange_id === exchange.id)?.amount ?? 0
  const exchangeLeft = exchangeRemainder(exchange) + existing
  const paymentOpen = paymentRemainder(payment) + existing
  const maximum = Math.max(Math.min(exchangeLeft, paymentOpen), 0)

  const [amount, setAmount] = useState<number | null>(
    existing > 0 ? existing : maximum,
  )
  const applied = amount ?? 0
  const tooMuch = applied > maximum || applied < 0
  const { anyInvalid, track } = useInvalidFields()
  const mutation = useApplyExchange()

  function save() {
    if (tooMuch || anyInvalid) return
    mutation.mutate(
      { exchangeId: exchange.id, paymentId: payment.id, amount: applied },
      { onSuccess: onClose },
    )
  }

  const stillOpen = paymentOpen - applied
  const eurShare = exchangeAmountEurShare(exchange, applied)

  return (
    <Dialog
      open
      onClose={onClose}
      title="Apply exchange to payment"
      footer={
        <>
          {existing > 0 && (
            <Button
              size="lg"
              variant="secondary"
              className="rounded-full"
              disabled={mutation.isPending}
              onClick={() =>
                mutation.mutate(
                  { exchangeId: exchange.id, paymentId: payment.id, amount: 0 },
                  { onSuccess: onClose },
                )
              }
            >
              Clear
            </Button>
          )}
          <Button
            size="lg"
            className="flex-1 rounded-full"
            disabled={tooMuch || anyInvalid || mutation.isPending}
            onClick={save}
          >
            <Check />
            {mutation.isPending ? "Saving…" : "Save"}
          </Button>
        </>
      }
    >
      <ContextBox>
        <ContextLine
          leading={
            <ArrowLeftRight className="size-4 shrink-0 text-muted-foreground" />
          }
          title={`Exchange ${formatShortDay(exchange.date)}`}
          detail={`${formatUsd(exchange.amount_usd)} @ ${formatRate(exchange.exchange_rate)} · ${formatUsd(exchangeLeft)} left`}
        />
        <ContextLine
          leading={<Swatch account={account} />}
          title={[account?.name, payment.counterparty]
            .filter(Boolean)
            .join(" · ")}
          detail={`${formatShortDay(payment.date)} · ${formatUsd(paymentOpen)} open`}
        />
      </ContextBox>

      <AmountField
        label="Amount (USD)"
        format="usd"
        autoFocus
        value={amount}
        onChange={setAmount}
        onInvalidChange={track("amount")}
        hint={
          tooMuch ? (
            <span className="text-destructive">
              At most {formatUsd(maximum)} can be applied here
            </span>
          ) : (
            <span className={stillOpen === 0 ? "text-success" : undefined}>
              {stillOpen === 0
                ? "Covers the payment fully"
                : `${formatUsd(stillOpen)} of the payment stays open`}
              {" · "}
              {formatUsd(exchangeLeft - applied)} of this exchange left
              afterwards
            </span>
          )
        }
      />

      {eurShare != null && (
        <p className="text-[13px] leading-[17px] text-muted-foreground">
          ≈ € {formatAmount(eurShare)} at this exchange’s rate
        </p>
      )}
    </Dialog>
  )
}
