import { useQuery } from "@tanstack/react-query"
import { createFileRoute } from "@tanstack/react-router"
import { Cable, Landmark, MoreHorizontal, Pencil, Plus } from "lucide-react"
import { useState } from "react"

import { useDeleteConnection, useDiscoverPlaidAccounts } from "@/api/mutations"
import {
  bankAccountsQuery,
  connectionsQuery,
  queryFailure,
} from "@/api/queries"
import { useUser } from "@/api/useUser"
import { PlaidLink } from "@/components/accounts/PlaidLink"
import { BankAccountDialog } from "@/components/dialog/BankAccountDialog"
import { CreditCardDialog } from "@/components/dialog/CreditCardDialog"
import { GroupSeparator } from "@/components/list/GroupSeparator"
import { ListSkeleton } from "@/components/list/ListSkeleton"
import { RowAction, Swatch } from "@/components/list/Row"
import {
  ErrorState,
  ListHeader,
  Rows,
  Workspace,
} from "@/components/shell/Workspace"
import { SidebarHeader } from "@/components/sidebar/AccountFilter"
import { SidebarItemsSkeleton } from "@/components/sidebar/SidebarSkeleton"
import { useAccounts } from "@/components/transactions/useOwnAccounts"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuPositioner,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { ordinal, updateAge } from "@/lib/dates"
import { formatEur, formatGrouped, formatUsd } from "@/lib/money"
import { cn, possessive } from "@/lib/utils"
import type { Account, BankAccount, PlaidConnection } from "@/types"
import type { ReactNode } from "react"

export const Route = createFileRoute("/accounts")({
  component: AccountsPage,
})

function Updated({
  timestamp,
  prefix,
}: {
  timestamp: string | null | undefined
  prefix?: string
}) {
  const age = updateAge(timestamp)
  if (!age) return <>{prefix ? prefix + " · " : ""}never updated</>
  return (
    <span className={age.stale ? "text-warning" : undefined}>
      {prefix ? `${prefix} · updated ` : "Updated "}
      {age.label}
    </span>
  )
}

/** Two-line row: everything about an account on one muted line. */
function AccountRow({
  swatch,
  name,
  details,
  value,
  status,
  inactive,
  onEdit,
}: {
  swatch: ReactNode
  name: string
  details: Array<string | null | undefined | false>
  value: string
  status: ReactNode
  inactive?: boolean
  onEdit: () => void
}) {
  return (
    <div
      className={cn(
        "redactable flex min-h-14 shrink-0 items-center gap-3 rounded-2xl border bg-card py-2 pr-2 pl-3.5 shadow-row md:rounded-row",
        inactive && "opacity-50",
      )}
    >
      {swatch}
      <div className="flex min-w-0 flex-1 flex-col">
        <p className="truncate text-sm leading-5 font-medium">{name}</p>
        <p className="truncate text-[13px] leading-[19px] text-muted-foreground">
          {details.filter(Boolean).join(" · ")}
        </p>
      </div>
      <div className="tabular flex shrink-0 flex-col items-end whitespace-nowrap">
        <p className="text-sm leading-5 font-medium">{value}</p>
        <p className="text-[13px] leading-[19px] text-muted-foreground max-md:hidden">
          {status}
        </p>
      </div>
      <RowAction label={`Edit ${name}`} onClick={onEdit}>
        <Pencil />
      </RowAction>
    </div>
  )
}

function Connections({
  connections,
  lastUpdate,
  onRepair,
}: {
  connections: Array<PlaidConnection>
  lastUpdate: (connection: PlaidConnection) => string | null
  onRepair: (connectionId: number) => void
}) {
  const user = useUser()
  const discover = useDiscoverPlaidAccounts()
  const remove = useDeleteConnection()

  return (
    <>
      {connections.map(connection => {
        const count = connection.plaid_accounts.length
        const age = updateAge(lastUpdate(connection))
        return (
          <div
            key={connection.id}
            className="flex h-14 shrink-0 items-center gap-2.5 rounded-row pr-1 pl-2.5"
          >
            <Cable className="size-4 shrink-0 text-muted-foreground" />
            <div className="flex min-w-0 flex-1 flex-col">
              <p className="truncate text-sm leading-5 font-medium">
                {connection.user.id !== user.id &&
                  possessive(connection.user.name)}
                {connection.name ?? connection.plaid_item_id}
              </p>
              <p className="truncate text-xs leading-4 text-muted-foreground">
                {count} {count === 1 ? "account" : "accounts"}
                {age && (
                  <span className={age.stale ? "text-warning" : undefined}>
                    {" "}
                    · updated {age.label}
                  </span>
                )}
              </p>
            </div>
            <DropdownMenu>
              <DropdownMenuTrigger
                render={
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    aria-label="Connection actions"
                  />
                }
              >
                <MoreHorizontal />
              </DropdownMenuTrigger>
              <DropdownMenuPositioner align="end">
                <DropdownMenuContent>
                  <DropdownMenuItem
                    disabled={discover.isPending}
                    onClick={() => discover.mutate(connection.id)}
                  >
                    Look for new accounts
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={() => onRepair(connection.id)}>
                    Repair connection
                  </DropdownMenuItem>
                  <DropdownMenuItem
                    variant="destructive"
                    disabled={remove.isPending}
                    onClick={() => remove.mutate(connection.id)}
                  >
                    Delete connection
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenuPositioner>
            </DropdownMenu>
          </div>
        )
      })}
    </>
  )
}

type Editing =
  | { kind: "card"; account?: Account }
  | { kind: "bank"; bankAccount?: BankAccount }
  | null

function AccountsPage() {
  const user = useUser()
  const {
    accounts,
    balances,
    isPending: accountsPending,
    accountsResult,
  } = useAccounts()
  const bankAccountsResult = useQuery(bankAccountsQuery)
  const { data: bankAccounts = [], isPending: bankAccountsPending } =
    bankAccountsResult
  const { data: connections = [], isPending: connectionsPending } =
    useQuery(connectionsQuery)
  const failure = queryFailure(accountsResult, bankAccountsResult)
  const loading = !failure && (accountsPending || bankAccountsPending)

  const [editing, setEditing] = useState<Editing>(null)
  /** undefined: closed, null: new connection, number: repair that connection */
  const [plaid, setPlaid] = useState<number | null | undefined>(undefined)

  const sorted = [...accounts].sort(
    (a, b) => Number(b.active) - Number(a.active),
  )
  const active = accounts.filter(account => account.active)
  const bankById = new Map(bankAccounts.map(b => [b.id, b]))
  const owner = (entity: { user: { id: number; name: string } }) =>
    entity.user.id !== user.id ? possessive(entity.user.name) : ""

  const plaidLabel = (plaidAccountId: number | null) => {
    if (plaidAccountId == null) return null
    const connection = connections.find(c =>
      c.plaid_accounts.some(a => a.id === plaidAccountId),
    )
    return connection ? `Plaid: ${connection.name ?? "connected"}` : null
  }

  // a connection is as fresh as the most recently updated account that uses it
  const lastUpdate = (connection: PlaidConnection): string | null => {
    const ids = new Set(connection.plaid_accounts.map(a => a.id))
    const stamps = [
      ...accounts
        .filter(a => a.plaid_account_id != null && ids.has(a.plaid_account_id))
        .map(a => balances?.[a.id]?.last_successful_update),
      ...bankAccounts
        .filter(b => b.plaid_account_id != null && ids.has(b.plaid_account_id))
        .map(b => b.last_successful_update),
    ].filter((stamp): stamp is string => stamp != null)
    return stamps.sort().at(-1) ?? null
  }

  const connectButton = (
    <Button
      variant="secondary"
      className="w-full"
      disabled={plaid !== undefined}
      onClick={() => setPlaid(null)}
    >
      <Plus />
      Connect bank via Plaid
    </Button>
  )

  const connectionList = (
    <>
      <Connections
        connections={connections}
        lastUpdate={lastUpdate}
        onRepair={setPlaid}
      />
      {connectionsPending && <SidebarItemsSkeleton count={4} />}
      {!connectionsPending && connections.length === 0 && (
        <p className="px-1 pb-2 text-sm text-muted-foreground">
          No bank is connected yet.
        </p>
      )}
      {connectButton}
    </>
  )

  const addButtons = (
    <>
      <Button
        variant="secondary"
        size="lg"
        className="rounded-full"
        onClick={() => setEditing({ kind: "bank" })}
      >
        <Landmark />
        Add bank account
      </Button>
      <Button
        size="lg"
        className="rounded-full"
        onClick={() => setEditing({ kind: "card" })}
      >
        <Plus />
        Add credit card
      </Button>
    </>
  )

  return (
    <Workspace
      sidebar={
        <>
          <SidebarHeader title="Connections" />
          {connectionList}
        </>
      }
      thumb={
        <>
          <Button
            size="fab"
            aria-label="Add credit card"
            onClick={() => setEditing({ kind: "card" })}
          >
            <Plus />
          </Button>
          <Button
            variant="secondary"
            size="fab"
            aria-label="Add bank account"
            onClick={() => setEditing({ kind: "bank" })}
          >
            <Landmark />
          </Button>
        </>
      }
      header={
        <ListHeader
          title="Accounts"
          subtitle={
            loading || failure
              ? undefined
              : `${active.length} credit ${active.length === 1 ? "card" : "cards"} · ${bankAccounts.length} bank ${bankAccounts.length === 1 ? "account" : "accounts"}`
          }
        >
          {addButtons}
        </ListHeader>
      }
    >
      {failure ? (
        <ErrorState error={failure.error} onRetry={failure.retry} />
      ) : loading ? (
        <ListSkeleton tall groups={[5, 2]} />
      ) : (
        <>
          <GroupSeparator
            first
            label="Credit cards"
            info={
              <span className="redactable">
                Total{" "}
                {formatUsd(
                  active.reduce(
                    (total, a) => total + (balances?.[a.id]?.posted ?? 0),
                    0,
                  ),
                )}
              </span>
            }
          />
          <Rows>
            {sorted.map(account => {
              const balance = balances?.[account.id]
              const bank =
                account.bank_account_id != null
                  ? bankById.get(account.bank_account_id)
                  : undefined
              const spent = balance
                ? balance.total_spent - balance.total_credits
                : null
              return (
                <AccountRow
                  key={account.id}
                  swatch={
                    <Swatch
                      account={account}
                      className="h-5 w-7 rounded-[4px]"
                    />
                  }
                  name={
                    owner(account) +
                    account.name +
                    (account.active ? "" : " (inactive)")
                  }
                  inactive={!account.active}
                  details={
                    account.active
                      ? [
                          account.institution,
                          account.due_day != null &&
                            `due ${ordinal(account.due_day)}`,
                          account.autopay_offset != null &&
                            `autopay ${account.autopay_offset} ${account.autopay_offset === 1 ? "day" : "days"} before`,
                          bank && `from ${bank.name}`,
                          account.target_spend != null &&
                            `${spent != null ? `$ ${formatGrouped(spent)} of ` : ""}target $ ${account.target_spend.toLocaleString("en-US")}`,
                        ]
                      : [
                          account.institution,
                          "hidden from transactions and archive",
                        ]
                  }
                  value={formatUsd(balance?.posted ?? 0)}
                  status={
                    !account.active ? (
                      "Inactive"
                    ) : (
                      <Updated
                        timestamp={balance?.last_successful_update}
                        prefix={
                          balance && balance.pending !== 0
                            ? `+${formatGrouped(balance.pending)} pending`
                            : undefined
                        }
                      />
                    )
                  }
                  onEdit={() => setEditing({ kind: "card", account })}
                />
              )
            })}
          </Rows>

          <GroupSeparator
            label="Bank accounts"
            info={
              <span className="redactable">
                Total{" "}
                {formatEur(
                  bankAccounts.reduce((total, b) => total + b.balance, 0),
                )}
              </span>
            }
          />
          <Rows>
            {bankAccounts.map(bankAccount => {
              const pays = active
                .filter(a => a.bank_account_id === bankAccount.id)
                .map(a => a.name)
              return (
                <AccountRow
                  key={bankAccount.id}
                  swatch={
                    <Swatch
                      color="var(--muted)"
                      className="h-5 w-7 rounded-[4px]"
                    />
                  }
                  name={owner(bankAccount) + bankAccount.name}
                  details={[
                    bankAccount.institution,
                    plaidLabel(bankAccount.plaid_account_id),
                    pays.length > 0 && `pays ${pays.join(", ")}`,
                  ]}
                  value={formatEur(bankAccount.balance)}
                  status={
                    <Updated timestamp={bankAccount.last_successful_update} />
                  }
                  onEdit={() => setEditing({ kind: "bank", bankAccount })}
                />
              )
            })}
          </Rows>
        </>
      )}

      <div className="md:hidden">
        <GroupSeparator label="Connections" info={connections.length} />
        <div className="flex flex-col px-5">{connectionList}</div>
      </div>

      {editing?.kind === "card" && (
        <CreditCardDialog
          account={editing.account}
          bankAccounts={bankAccounts}
          connections={connections}
          onClose={() => setEditing(null)}
        />
      )}
      {editing?.kind === "bank" && (
        <BankAccountDialog
          bankAccount={editing.bankAccount}
          connections={connections}
          onClose={() => setEditing(null)}
        />
      )}
      {plaid !== undefined && (
        <PlaidLink
          key={plaid ?? "new"}
          updateId={plaid ?? undefined}
          onDone={() => setPlaid(undefined)}
        />
      )}
    </Workspace>
  )
}
