
import { Swatch } from "@/components/list/Row"
import { updateAge } from "@/lib/dates"
import { formatEur, formatGrouped, formatUsd } from "@/lib/money"
import { cn, possessive } from "@/lib/utils"
import type { Account, AccountBalances, BankAccount } from "@/types"
import type { ReactNode } from "react"

export function SidebarHeader({
  title,
  info,
}: {
  title: ReactNode
  info?: ReactNode
}) {
  return (
    <div className="flex h-10 shrink-0 items-center gap-2 pl-1">
      <p className="flex-1 text-base leading-[23px] font-semibold">{title}</p>
      {info != null && (
        <p className="redactable text-sm leading-5 text-muted-foreground">
          {info}
        </p>
      )}
    </div>
  )
}

export function SidebarDivider() {
  return <div className="-mx-3 my-1 h-px shrink-0 bg-border" />
}

function UpdatedLine({
  timestamp,
  connected,
}: {
  timestamp: string | null | undefined
  connected: boolean
}) {
  const age = updateAge(timestamp)
  if (!age) return <>{connected ? "Not updated yet" : "Not connected"}</>
  return (
    <span className={age.stale ? "text-warning" : undefined}>
      Updated {age.label}
    </span>
  )
}

/** A sidebar line: swatch, name with a sub line, and a value with a sub line. */
export function SidebarItem({
  swatch,
  name,
  sub,
  value,
  valueSub,
  selected,
  onClick,
}: {
  swatch?: ReactNode
  name: ReactNode
  sub?: ReactNode
  value?: ReactNode
  valueSub?: ReactNode
  selected?: boolean
  onClick?: () => void
}) {
  const Element = onClick ? "button" : "div"
  return (
    <Element
      type={onClick ? "button" : undefined}
      aria-pressed={onClick ? selected : undefined}
      onClick={onClick}
      className={cn(
        "redactable flex h-12 w-full shrink-0 items-center gap-2.5 rounded-row px-2.5 text-left transition-colors",
        onClick && "hover:bg-muted",
        selected && "bg-muted",
      )}
    >
      {swatch}
      <span className="flex min-w-0 flex-1 flex-col whitespace-nowrap">
        <span className="truncate text-sm leading-5 font-medium">{name}</span>
        {sub != null && (
          <span className="truncate text-xs leading-4 text-muted-foreground">
            {sub}
          </span>
        )}
      </span>
      <span className="tabular flex shrink-0 flex-col items-end whitespace-nowrap">
        <span className="text-sm leading-5 font-medium">{value}</span>
        {valueSub != null && (
          <span className="text-xs leading-4 text-muted-foreground">
            {valueSub}
          </span>
        )}
      </span>
    </Element>
  )
}

export function totalPosted(
  accounts: Array<Account>,
  balances: AccountBalances | undefined,
): number {
  return accounts.reduce(
    (total, account) => total + (balances?.[account.id]?.posted ?? 0),
    0,
  )
}

/** Credit cards with balance, pending and last update; doubles as the filter. */
export function AccountFilter({
  accounts,
  balances,
  selectedId,
  onSelect,
  showOwner,
}: {
  accounts: Array<Account>
  balances: AccountBalances | undefined
  selectedId: number | null
  onSelect?: (accountId: number | null) => void
  /** prefix the name with the owner, for other users' accounts */
  showOwner?: boolean
}) {
  return (
    <>
      {accounts.map(account => {
        const balance = balances?.[account.id]
        return (
          <SidebarItem
            key={account.id}
            swatch={<Swatch account={account} />}
            name={
              (showOwner ? possessive(account.user.name) : "") + account.name
            }
            sub={
              <UpdatedLine
                timestamp={balance?.last_successful_update}
                connected={account.plaid_account_id != null}
              />
            }
            value={balance ? formatGrouped(balance.posted) : "–"}
            valueSub={
              balance && balance.pending !== 0
                ? `+${formatGrouped(balance.pending)} pending`
                : undefined
            }
            selected={account.id === selectedId}
            onClick={
              onSelect
                ? () => onSelect(account.id === selectedId ? null : account.id)
                : undefined
            }
          />
        )
      })}
    </>
  )
}

export function BankAccountItems({
  bankAccounts,
  showOwner,
}: {
  bankAccounts: Array<BankAccount>
  showOwner?: boolean
}) {
  return (
    <>
      {bankAccounts.map(bankAccount => (
        <SidebarItem
          key={bankAccount.id}
          swatch={<Swatch color="var(--muted)" />}
          name={
            (showOwner ? possessive(bankAccount.user.name) : "") +
            bankAccount.name
          }
          sub={
            <UpdatedLine
              timestamp={bankAccount.last_successful_update}
              connected={bankAccount.plaid_account_id != null}
            />
          }
          value={formatEur(bankAccount.balance)}
        />
      ))}
    </>
  )
}

function AccountCard({
  selected,
  onClick,
  swatch,
  name,
  value,
  lines,
}: {
  selected: boolean
  onClick: () => void
  swatch?: ReactNode
  name: string
  value: string
  lines: Array<ReactNode>
}) {
  return (
    <button
      type="button"
      aria-pressed={selected}
      onClick={onClick}
      className={cn(
        "redactable flex w-[148px] shrink-0 flex-col gap-0.5 rounded-2xl border bg-card px-3 py-2.5 text-left drop-shadow-[0_2px_1px_rgb(0_0_0/0.04)]",
        selected && "border-accent shadow-[inset_0_0_0_1px_var(--accent)]",
      )}
    >
      <span className="flex w-full items-center gap-2">
        {swatch}
        <span className="truncate text-[13px] leading-[19px] font-medium">
          {name}
        </span>
      </span>
      <span className="tabular text-lg leading-[26px] font-semibold">
        {value}
      </span>
      {lines.map((line, index) => (
        <span
          key={index}
          className="text-xs leading-[17px] whitespace-nowrap text-muted-foreground"
        >
          {line}
        </span>
      ))}
    </button>
  )
}

/** Mobile: account cards swipe sideways and act as the filter. */
export function AccountCards({
  accounts,
  balances,
  selectedId,
  onSelect,
  allLines,
}: {
  accounts: Array<Account>
  balances: AccountBalances | undefined
  selectedId: number | null
  onSelect: (accountId: number | null) => void
  /** the two detail lines of the "All accounts" card */
  allLines: Array<ReactNode>
}) {
  return (
    <div className="no-scrollbar flex gap-2 overflow-x-auto px-5 pb-1">
      <AccountCard
        selected={selectedId == null}
        onClick={() => onSelect(null)}
        name="All accounts"
        value={formatUsd(totalPosted(accounts, balances))}
        lines={allLines}
      />
      {accounts.map(account => {
        const balance = balances?.[account.id]
        return (
          <AccountCard
            key={account.id}
            selected={account.id === selectedId}
            onClick={() =>
              onSelect(account.id === selectedId ? null : account.id)
            }
            swatch={<Swatch account={account} />}
            name={account.name}
            value={balance ? formatGrouped(balance.posted) : "–"}
            lines={[
              balance && balance.pending !== 0
                ? `+${formatGrouped(balance.pending)} pending`
                : "No pending",
              <UpdatedLine
                key="updated"
                timestamp={balance?.last_successful_update}
                connected={account.plaid_account_id != null}
              />,
            ]}
          />
        )
      })}
    </div>
  )
}
