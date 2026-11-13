import { useQuery } from "@tanstack/react-query"
import { createFileRoute } from "@tanstack/react-router"
import { addMonths } from "date-fns"
import { ChevronLeft, ChevronRight, Undo2 } from "lucide-react"

import type { Transaction } from "@/types"
import { useUnprocessPayment } from "@/api/mutations"
import {
  feesQuery,
  paidTransactionsQuery,
  processedPaymentsQuery,
  queryFailure,
} from "@/api/queries"
import { useUser } from "@/api/useUser"
import { GroupSeparator } from "@/components/list/GroupSeparator"
import { ListSkeleton } from "@/components/list/ListSkeleton"
import { Amount, EurValue, Row, Swatch } from "@/components/list/Row"
import {
  EmptyState,
  ErrorState,
  ListHeader,
  MobileActions,
  Rows,
  Workspace,
} from "@/components/shell/Workspace"
import { SidebarHeader, SidebarItem } from "@/components/sidebar/AccountFilter"
import {
  SidebarItemsSkeleton,
  StatTileSkeleton,
} from "@/components/sidebar/SidebarSkeleton"
import { StatTile } from "@/components/sidebar/StatTile"
import { useAccounts } from "@/components/transactions/useOwnAccounts"
import { Button } from "@/components/ui/button"
import { Chip } from "@/components/ui/chip"
import {
  formatDay,
  formatMonth,
  monthKey,
  monthRange,
  parseMonthKey,
} from "@/lib/dates"
import { groupBy } from "@/lib/derive"
import { formatAmount, formatEur, formatSigned, formatUsd } from "@/lib/money"
import { cn } from "@/lib/utils"
import { Status } from "@/types"

type Search = { month?: string; account?: number }

export const Route = createFileRoute("/archive")({
  validateSearch: (search: Record<string, unknown>): Search => {
    const account = Number(search.account)
    return {
      ...(typeof search.month === "string" && /^\d{4}-\d{2}$/.test(search.month)
        ? { month: search.month }
        : {}),
      ...(Number.isInteger(account) && account > 0 ? { account } : {}),
    }
  },
  component: ArchivePage,
})

const sumFees = (transactions: Array<Transaction>) =>
  transactions.reduce((total, tx) => total + (tx.fees_and_risk_eur ?? 0), 0)

function Fee({ amount }: { amount: number | null }) {
  if (amount == null) return <Amount className="w-14">–</Amount>
  return (
    <Amount className={cn("w-14", amount < 0 && "text-success")}>
      {formatSigned(amount)}
    </Amount>
  )
}

function ArchivePage() {
  const user = useUser()
  const navigate = Route.useNavigate()
  const search = Route.useSearch()
  const {
    byId,
    own,
    isPending: accountsPending,
    accountsResult,
  } = useAccounts()

  const month = parseMonthKey(search.month)
  const range = monthRange(month)
  const accountId = search.account ?? null

  const transactionsResult = useQuery(paidTransactionsQuery(range))
  const paymentsResult = useQuery(processedPaymentsQuery(range))
  const { data: transactions = [], isPending } = transactionsResult
  const { data: payments = [] } = paymentsResult
  const { data: fees, isLoading: feesLoading } = useQuery({
    ...feesQuery(range),
    enabled: user.super_user,
  })
  const unprocess = useUnprocessPayment()
  const failure = queryFailure(
    transactionsResult,
    paymentsResult,
    accountsResult,
  )
  const loading = !failure && (isPending || accountsPending)

  const setSearch = (next: Search) =>
    void navigate({ search: { ...search, ...next }, replace: true })
  const goToMonth = (offset: number) =>
    setSearch({ month: monthKey(addMonths(month, offset)) })

  const visible = transactions.filter(
    tx => accountId == null || tx.account_id === accountId,
  )
  const paymentById = new Map(payments.map(payment => [payment.id, payment]))
  const groups = groupBy(visible, tx => tx.payment_id ?? 0)
    .map(group => ({ ...group, payment: paymentById.get(group.key) }))
    .sort((a, b) =>
      (b.payment?.date ?? "").localeCompare(a.payment?.date ?? ""),
    )

  // other users' transactions are not listed, so only the super user's
  // summary comes from the server (it covers everyone)
  const feeTotal = fees?.fees_and_risk_eur ?? sumFees(transactions)
  const paidTotal =
    fees?.paid_eur ??
    transactions.reduce((total, tx) => total + (tx.amount_eur ?? 0), 0)
  const monthName = formatMonth(month).split(" ")[0]

  const summary =
    loading || feesLoading ? (
      <StatTileSkeleton />
    ) : (
      <StatTile
        label={`FX fees & risk · ${monthName}`}
        value={formatEur(feeTotal)}
      >
        on {formatEur(paidTotal)} paid
        {paidTotal > 0 && ` · ${((feeTotal / paidTotal) * 100).toFixed(2)} %`}
      </StatTile>
    )

  const monthNavigation = (
    <div className="flex items-center gap-2">
      <span className="pr-1 text-sm font-medium whitespace-nowrap md:hidden">
        {formatMonth(month)}
      </span>
      <Button
        variant="secondary"
        size="icon"
        aria-label="Previous month"
        onClick={() => goToMonth(-1)}
      >
        <ChevronLeft />
      </Button>
      <Button
        variant="secondary"
        size="icon"
        aria-label="Next month"
        disabled={monthKey(month) >= monthKey(new Date())}
        onClick={() => goToMonth(1)}
      >
        <ChevronRight />
      </Button>
    </div>
  )

  const count = (id: number) =>
    transactions.filter(tx => tx.account_id === id).length
  const listedAccounts = own.filter(
    account => count(account.id) > 0 || account.id === accountId,
  )

  return (
    <Workspace
      sidebar={
        <>
          <SidebarHeader title="Summary" />
          {summary}
          <div className="h-2 shrink-0" />
          <SidebarHeader title="Accounts" />
          {loading && <SidebarItemsSkeleton count={3} />}
          {listedAccounts.map(account => (
            <SidebarItem
              key={account.id}
              swatch={<Swatch account={account} />}
              name={account.name}
              value={
                <span className="font-normal text-muted-foreground">
                  {count(account.id)}
                </span>
              }
              selected={account.id === accountId}
              onClick={() =>
                setSearch({
                  account: account.id === accountId ? undefined : account.id,
                })
              }
            />
          ))}
        </>
      }
      mobileTop={
        <>
          <div className="px-5">{summary}</div>
          <div className="no-scrollbar flex gap-2 overflow-x-auto px-5">
            <button
              type="button"
              onClick={() => setSearch({ account: undefined })}
            >
              <Chip state={accountId == null ? "active" : "default"}>
                All accounts
              </Chip>
            </button>
            {listedAccounts.map(account => (
              <button
                key={account.id}
                type="button"
                onClick={() => setSearch({ account: account.id })}
              >
                <Chip state={account.id === accountId ? "active" : "default"}>
                  <Swatch account={account} />
                  {account.name} · {count(account.id)}
                </Chip>
              </button>
            ))}
          </div>
          <MobileActions>{monthNavigation}</MobileActions>
        </>
      }
      header={
        <ListHeader
          title="Paid transactions"
          subtitle={
            loading || failure
              ? formatMonth(month)
              : `${formatMonth(month)} · ${visible.length} total`
          }
        >
          {monthNavigation}
        </ListHeader>
      }
    >
      {groups.map((group, index) => {
        const payment = group.payment
        const account = payment ? byId.get(payment.account_id) : undefined
        return (
          <div key={group.key} className="flex flex-col">
            <GroupSeparator
              first={index === 0}
              label={
                payment
                  ? `Paid ${formatDay(payment.date)} · ${[account?.name, payment.counterparty].filter(Boolean).join(" · ")}`
                  : "Paid"
              }
              info={
                <span className="redactable">
                  {payment?.amount_eur_with_fx != null &&
                    `${formatEur(payment.amount_eur_with_fx)} · `}
                  FX {formatSigned(sumFees(group.items))}
                </span>
              }
              action={
                payment &&
                user.super_user && (
                  <button
                    type="button"
                    aria-label="Unprocess payment"
                    title="Unprocess payment: its transactions become open again"
                    disabled={unprocess.isPending}
                    onClick={() => unprocess.mutate(payment.id)}
                    className="rounded-field p-0.5 text-muted-foreground hover:bg-muted hover:text-foreground disabled:opacity-40"
                  >
                    <Undo2 className="size-3.5" />
                  </button>
                )
              }
            />
            <Rows>
              {group.items.map(tx => (
                <Row
                  key={tx.id}
                  swatch={<Swatch account={byId.get(tx.account_id)} />}
                  title={tx.counterparty}
                  description={tx.description}
                  meta={formatUsd(tx.amount_usd)}
                  pending={tx.status === Status.PENDING}
                  columns={
                    <Amount className="min-w-[76px]">
                      {formatUsd(tx.amount_usd)}
                    </Amount>
                  }
                  field={
                    <EurValue amount={formatAmount(tx.amount_eur) || "–"} />
                  }
                  action={<Fee amount={tx.fees_and_risk_eur} />}
                />
              ))}
            </Rows>
          </div>
        )
      })}
      {loading && <ListSkeleton groups={[3, 5]} />}
      {failure && <ErrorState error={failure.error} onRetry={failure.retry} />}
      {!loading && !failure && visible.length === 0 && (
        <EmptyState>Nothing was paid in {formatMonth(month)}.</EmptyState>
      )}
    </Workspace>
  )
}
