import { useQuery } from "@tanstack/react-query"
import { createFileRoute } from "@tanstack/react-router"
import { Check, Link as LinkIcon, Plus } from "lucide-react"
import { useEffect, useState } from "react"
import { toast } from "sonner"

import type { Exchange, Payment } from "@/types"
import {
  useApplyExchange,
  useDeleteExchange,
  useDeletePayment,
  useProcessPayment,
} from "@/api/mutations"
import {
  balancesQuery,
  openPaymentsQuery,
  usableExchangesQuery,
} from "@/api/queries"
import { useUser } from "@/api/useUser"
import { ExchangeDialog } from "@/components/dialog/ExchangeDialog"
import { ExchangePaymentDialog } from "@/components/dialog/ExchangePaymentDialog"
import { GroupSeparator } from "@/components/list/GroupSeparator"
import { Amount, EurValue, Row, RowAction, Swatch } from "@/components/list/Row"
import { RowMenu } from "@/components/list/RowMenu"
import {
  EmptyState,
  ListHeader,
  MobileActions,
  Rows,
  Workspace,
} from "@/components/shell/Workspace"
import { SidebarHeader } from "@/components/sidebar/AccountFilter"
import { StatTile, StatTileStrip } from "@/components/sidebar/StatTile"
import { useAccounts } from "@/components/transactions/useOwnAccounts"
import { Button } from "@/components/ui/button"
import { formatShortDay } from "@/lib/dates"
import {
  canProcessPayment,
  exchangeRemainder,
  paymentRemainder,
} from "@/lib/derive"
import {
  formatAmount,
  formatEur,
  formatGrouped,
  formatRate,
  formatUsd,
} from "@/lib/money"
import { useStore } from "@/store"
import { Status } from "@/types"

export const Route = createFileRoute("/exchanges")({
  component: ExchangesPage,
})

function UsdColumns({
  total,
  remainder,
}: {
  total: number
  remainder: number
}) {
  return remainder !== total ? (
    <>
      <Amount struck>{formatUsd(total)}</Amount>
      <Amount className="text-success">{formatUsd(remainder)}</Amount>
    </>
  ) : (
    <Amount className="min-w-[76px]">{formatUsd(total)}</Amount>
  )
}

function Summary() {
  const { data: balances } = useQuery(balancesQuery)
  if (!balances) return null
  const virtual = Number(balances.virtual_account)

  return (
    <>
      <StatTile label="Still to exchange" value={formatUsd(balances.total)}>
        {formatGrouped(balances.posted)} posted +{" "}
        {formatGrouped(balances.pending)} pending
        <br />− {formatGrouped(balances.credits)} credits · −{" "}
        {formatGrouped(balances.exchanged)} exchanged
      </StatTile>
      <StatTile
        label="Virtual account"
        value={Number.isFinite(virtual) ? formatEur(virtual) : "negative"}
      >
        Exchanged but not yet paid out
      </StatTile>
      <StatTile
        label="Average rate"
        value={formatRate(balances.avg_exchange_rate)}
      >
        of unpaid transactions
      </StatTile>
    </>
  )
}

function ExchangesPage() {
  const user = useUser()
  const { byId } = useAccounts()
  const { data: exchanges = [] } = useQuery({
    ...usableExchangesQuery,
    enabled: user.super_user,
  })
  const { data: allPayments = [], isPending } = useQuery(openPaymentsQuery)

  const exchangeSelection = useStore(state => state.exchangeSelection)
  const setExchangeSelection = useStore(state => state.setExchangeSelection)
  const selected = exchanges.find(e => e.id === exchangeSelection) ?? null

  const [adding, setAdding] = useState(false)
  const [applyTo, setApplyTo] = useState<Payment | null>(null)

  const deleteExchange = useDeleteExchange()
  const applyExchange = useApplyExchange()
  const processPayment = useProcessPayment()
  const deletePayment = useDeletePayment()

  useEffect(() => {
    if (exchangeSelection != null && exchanges.length > 0 && !selected) {
      setExchangeSelection(null)
    }
  }, [exchangeSelection, exchanges.length, selected, setExchangeSelection])

  const payments = allPayments
    .filter(payment => byId.get(payment.account_id)?.active !== false)
    .sort((a, b) => a.date.localeCompare(b.date))
  const covered = payments.filter(p => paymentRemainder(p) === 0).length

  const month = new Date().toISOString().slice(0, 7)
  const thisMonth = exchanges.filter(e => e.date.startsWith(month)).length

  function selectPayment(payment: Payment) {
    if (!selected) {
      toast.info("Pick an exchange first", {
        description:
          "Use the link icon on an exchange, then choose the payment.",
      })
      return
    }
    if (selected.cashback_transaction_id == null) {
      setApplyTo(payment)
      return
    }
    // a cashback exchange always goes onto one payment in full
    applyExchange.mutate(
      {
        exchangeId: selected.id,
        paymentId: payment.id,
        amount: selected.amount_usd,
      },
      { onSuccess: () => setExchangeSelection(null) },
    )
  }

  function exchangeRow(exchange: Exchange) {
    const isSelected = exchange.id === exchangeSelection
    const isCashback = exchange.cashback_transaction_id != null
    const remainder = exchangeRemainder(exchange)
    const day = formatShortDay(exchange.date)
    const deletable = exchange.payments.length === 0 && !isCashback

    return (
      <RowMenu
        key={exchange.id}
        items={
          deletable
            ? [
                {
                  label: "Delete exchange",
                  destructive: true,
                  disabled: deleteExchange.isPending,
                  onSelect: () => deleteExchange.mutate(exchange.id),
                },
              ]
            : []
        }
      >
        <Row
          tone={isSelected ? "selected" : "default"}
          title={isCashback ? "Cashback" : formatRate(exchange.exchange_rate)}
          description={
            isCashback
              ? `${exchange.cashback_transaction_description ?? "Transaction"} · ${day}`
              : `€ ${formatGrouped(exchange.amount_eur ?? 0)} + € ${formatGrouped(exchange.fees_eur ?? 0)} fees · ${day}`
          }
          meta={formatUsd(remainder)}
          columns={
            <UsdColumns total={exchange.amount_usd} remainder={remainder} />
          }
          field={<EurValue amount={formatAmount(exchange.amount_eur ?? 0)} />}
          action={
            <RowAction
              label={
                isSelected
                  ? "Stop applying this exchange"
                  : "Apply to a payment"
              }
              active={isSelected}
              onClick={() =>
                setExchangeSelection(isSelected ? null : exchange.id)
              }
            >
              <LinkIcon />
            </RowAction>
          }
        />
      </RowMenu>
    )
  }

  function paymentRow(payment: Payment) {
    const account = byId.get(payment.account_id)
    const remainder = paymentRemainder(payment)
    const pending = payment.status === Status.PENDING
    const fullyCovered = remainder === 0
    const eur =
      (fullyCovered ? payment.amount_eur_with_fx : null) ??
      payment.amount_eur_without_fx
    const state = pending
      ? "pending"
      : fullyCovered
        ? "fully covered"
        : remainder === payment.amount_usd
          ? "needs exchange"
          : `${formatUsd(remainder)} still to cover`

    return (
      <RowMenu
        key={payment.id}
        items={
          pending && user.super_user
            ? [
                {
                  label: "Delete payment",
                  destructive: true,
                  disabled: deletePayment.isPending,
                  onSelect: () => deletePayment.mutate(payment.id),
                },
              ]
            : []
        }
      >
        <Row
          swatch={<Swatch account={account} />}
          tone={selected && !fullyCovered ? "selectable" : "default"}
          pending={pending}
          title={payment.counterparty}
          description={`Due ${formatShortDay(payment.date)} · ${state}`}
          meta={formatUsd(remainder === 0 ? payment.amount_usd : remainder)}
          columns={
            <UsdColumns
              total={payment.amount_usd}
              remainder={remainder || payment.amount_usd}
            />
          }
          field={
            eur ? (
              <EurValue
                amount={formatAmount(eur)}
                approximate={
                  !fullyCovered || payment.amount_eur_with_fx == null
                }
              />
            ) : (
              <EurValue amount="–" />
            )
          }
          action={
            !user.super_user ? undefined : selected && !fullyCovered ? (
              <Button
                variant="accent"
                size="sm"
                disabled={applyExchange.isPending}
                onClick={() => selectPayment(payment)}
              >
                <LinkIcon />
                <span className="max-md:sr-only">Apply</span>
              </Button>
            ) : fullyCovered ? (
              <RowAction
                label={
                  canProcessPayment(payment)
                    ? "Process payment"
                    : "Covered, can be processed once posted"
                }
                disabled={
                  !canProcessPayment(payment) ||
                  processPayment.isPending ||
                  selected != null
                }
                onClick={() => processPayment.mutate(payment.id)}
              >
                <Check />
              </RowAction>
            ) : (
              <RowAction
                label="Apply an exchange"
                onClick={() => selectPayment(payment)}
              >
                <LinkIcon />
              </RowAction>
            )
          }
        />
      </RowMenu>
    )
  }

  const addButton = user.super_user && (
    <Button className="rounded-full" size="lg" onClick={() => setAdding(true)}>
      <Plus />
      Add exchange
    </Button>
  )

  return (
    <Workspace
      sidebar={
        <>
          <SidebarHeader title="Summary" />
          {user.super_user ? (
            <div className="flex flex-col gap-3">
              <Summary />
            </div>
          ) : (
            <p className="px-1 text-sm text-muted-foreground">
              Exchanges are managed by the main account holder.
            </p>
          )}
        </>
      }
      mobileTop={
        <>
          {user.super_user && (
            <StatTileStrip>
              <Summary />
            </StatTileStrip>
          )}
          <MobileActions>{addButton}</MobileActions>
        </>
      }
      header={
        selected ? (
          <ListHeader
            leading={
              <span className="flex size-10 items-center justify-center rounded-full bg-accent text-accent-foreground">
                <LinkIcon className="size-5" />
              </span>
            }
            title={
              selected.cashback_transaction_id != null
                ? "Apply cashback"
                : `Apply exchange of ${formatShortDay(selected.date)}`
            }
            subtitle={`${formatUsd(exchangeRemainder(selected))} left · select the payment to cover`}
          >
            <Button
              className="rounded-full"
              size="lg"
              onClick={() => setExchangeSelection(null)}
            >
              <Check />
              Done
            </Button>
          </ListHeader>
        ) : (
          <ListHeader
            title="Exchanges"
            subtitle={user.super_user ? `${thisMonth} this month` : undefined}
          >
            {addButton}
          </ListHeader>
        )
      }
    >
      {user.super_user && (
        <>
          <GroupSeparator
            first
            label="Exchanges"
            info={formatUsd(
              exchanges.reduce((total, e) => total + exchangeRemainder(e), 0),
            )}
          />
          <Rows>{exchanges.map(exchangeRow)}</Rows>
          {exchanges.length === 0 && (
            <EmptyState>No exchange with an open amount.</EmptyState>
          )}
        </>
      )}

      <GroupSeparator
        first={!user.super_user}
        label="Upcoming payments"
        info={`${formatUsd(payments.reduce((total, p) => total + p.amount_usd, 0))} · ${covered} covered`}
      />
      <Rows>{payments.map(paymentRow)}</Rows>
      {!isPending && payments.length === 0 && (
        <EmptyState>No open payments.</EmptyState>
      )}

      {adding && <ExchangeDialog onClose={() => setAdding(false)} />}
      {selected && applyTo && (
        <ExchangePaymentDialog
          exchange={selected}
          payment={applyTo}
          account={byId.get(applyTo.account_id)}
          onClose={() => setApplyTo(null)}
        />
      )}
    </Workspace>
  )
}
