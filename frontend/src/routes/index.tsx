import { useQuery } from "@tanstack/react-query"
import { createFileRoute } from "@tanstack/react-router"
import { Check, CloudUpload, Download, Link as LinkIcon } from "lucide-react"
import { useEffect, useMemo, useState } from "react"

import type { Transaction } from "@/types"
import { useActualExport, useImport, useSaveAmounts } from "@/api/mutations"
import {
  bankAccountsQuery,
  openTransactionsQuery,
  usableCreditsQuery,
} from "@/api/queries"
import { useUser } from "@/api/useUser"
import { ApplyCreditDialog } from "@/components/dialog/ApplyCreditDialog"
import { GroupSeparator } from "@/components/list/GroupSeparator"
import { ListSkeleton } from "@/components/list/ListSkeleton"
import { SaveBar } from "@/components/shell/SaveBar"
import {
  EmptyState,
  ListHeader,
  MobileActions,
  Rows,
  Workspace,
} from "@/components/shell/Workspace"
import {
  AccountCards,
  AccountFilter,
  BankAccountItems,
  SidebarDivider,
  SidebarHeader,
  totalPosted,
} from "@/components/sidebar/AccountFilter"
import { DueCalendar, DueCalendarCard } from "@/components/sidebar/DueCalendar"
import {
  AccountCardsSkeleton,
  SidebarItemsSkeleton,
} from "@/components/sidebar/SidebarSkeleton"
import { CreditRow } from "@/components/transactions/CreditRow"
import { TransactionRow } from "@/components/transactions/TransactionRow"
import { useAccounts } from "@/components/transactions/useOwnAccounts"
import { Button } from "@/components/ui/button"
import { Switch } from "@/components/ui/switch"
import { formatDay } from "@/lib/dates"
import { creditRemainder, groupBy } from "@/lib/derive"
import { formatUsd } from "@/lib/money"
import { useStore } from "@/store"
import { Status } from "@/types"

type Search = { account?: number }

export const Route = createFileRoute("/")({
  validateSearch: (search: Record<string, unknown>): Search => {
    const account = Number(search.account)
    return Number.isInteger(account) && account > 0 ? { account } : {}
  },
  component: TransactionsPage,
})

function TransactionsPage() {
  const user = useUser()
  const navigate = Route.useNavigate()
  const { account: accountParam } = Route.useSearch()
  const {
    byId,
    own,
    others,
    balances,
    isPending: accountsPending,
  } = useAccounts()

  const { data: transactions = [], isPending } = useQuery(openTransactionsQuery)
  const { data: credits = [], isPending: creditsPending } =
    useQuery(usableCreditsQuery)
  const { data: bankAccounts = [] } = useQuery(bankAccountsQuery)
  // credits and transactions form one list: show it only when both are there
  const loading = isPending || creditsPending || accountsPending

  const drafts = useStore(state => state.drafts)
  const clearDrafts = useStore(state => state.clearDrafts)
  const missingEurOnly = useStore(state => state.missingEurOnly)
  const setMissingEurOnly = useStore(state => state.setMissingEurOnly)
  const creditSelection = useStore(state => state.creditSelection)
  const setCreditSelection = useStore(state => state.setCreditSelection)

  const [applyTo, setApplyTo] = useState<Transaction | null>(null)

  const activeIds = useMemo(() => new Set(own.map(a => a.id)), [own])
  const selectedCredit =
    credits.find(credit => credit.id === creditSelection) ?? null
  // apply mode shows the credit's account, whatever the filter says
  const accountId = selectedCredit?.account_id ?? accountParam ?? null
  const account = accountId != null ? byId.get(accountId) : undefined

  const selectAccount = (id: number | null) =>
    void navigate({ search: id == null ? {} : { account: id }, replace: true })

  // leave apply mode when the credit is used up or gone
  useEffect(() => {
    if (creditSelection != null && !isPending && !selectedCredit) {
      setCreditSelection(null)
    }
  }, [creditSelection, selectedCredit, isPending, setCreditSelection])

  const open = transactions.filter(
    tx => tx.status !== Status.PAID && activeIds.has(tx.account_id),
  )
  const inAccount = open.filter(
    tx => accountId == null || tx.account_id === accountId,
  )
  const isMissing = (tx: Transaction) =>
    tx.amount_eur == null && !(tx.id in drafts)
  const visible = inAccount.filter(
    tx => selectedCredit != null || !missingEurOnly || tx.amount_eur == null,
  )
  const missingCount = inAccount.filter(isMissing).length
  const days = groupBy(visible, tx => tx.date)

  const visibleCredits = credits.filter(
    credit =>
      activeIds.has(credit.account_id) &&
      (selectedCredit
        ? credit.id === selectedCredit.id
        : accountId == null || credit.account_id === accountId),
  )
  const creditTotal = visibleCredits.reduce(
    (total, credit) => total + creditRemainder(credit),
    0,
  )

  const draftCount = Object.keys(drafts).length
  const save = useSaveAmounts(clearDrafts)
  const importData = useImport()
  const actualExport = useActualExport()

  const saveAll = () => {
    if (draftCount > 0 && !save.isPending) save.mutate(drafts)
  }

  // ⌘↵ / Ctrl+↵ saves all edits; the focused field commits on blur first
  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.key !== "Enter" || !(event.metaKey || event.ctrlKey)) return
      event.preventDefault()
      if (document.activeElement instanceof HTMLElement) {
        document.activeElement.blur()
      }
      requestAnimationFrame(() => {
        const current = useStore.getState().drafts
        if (Object.keys(current).length > 0 && !save.isPending) {
          save.mutate(current)
        }
      })
    }
    window.addEventListener("keydown", onKeyDown)
    return () => window.removeEventListener("keydown", onKeyDown)
  }, [save])

  const accountActions = account && !selectedCredit && (
    <>
      <Button
        variant="secondary"
        size="icon"
        aria-label="Import data"
        title="Import data for this account"
        disabled={importData.isPending}
        onClick={() => importData.mutate(account.id)}
      >
        <Download className={importData.isPending ? "animate-pulse" : ""} />
      </Button>
      <Button
        variant="secondary"
        size="icon"
        aria-label="Export to Actual"
        title="Export this account to Actual"
        disabled={actualExport.isPending}
        onClick={() => actualExport.mutate(account.id)}
      >
        <CloudUpload
          className={actualExport.isPending ? "animate-pulse" : ""}
        />
      </Button>
    </>
  )

  const missingSwitch = !selectedCredit && (
    <label className="flex items-center gap-2 pr-2 text-[13px] leading-[19px] font-medium whitespace-nowrap">
      <Switch checked={missingEurOnly} onCheckedChange={setMissingEurOnly} />
      Missing EUR only
    </label>
  )

  const header = selectedCredit ? (
    <ListHeader
      leading={
        <span className="flex size-10 items-center justify-center rounded-full bg-accent text-accent-foreground">
          <LinkIcon className="size-5" />
        </span>
      }
      title={`Apply “${selectedCredit.counterparty}”`}
      subtitle={`${formatUsd(creditRemainder(selectedCredit))} left · select ${account?.name ?? ""} transactions to cover`}
    >
      <Button
        className="rounded-full"
        size="lg"
        onClick={() => setCreditSelection(null)}
      >
        <Check />
        Done
      </Button>
    </ListHeader>
  ) : (
    <ListHeader
      title={account?.name ?? "All accounts"}
      subtitle={
        loading
          ? undefined
          : missingCount === 1
            ? "1 missing EUR amount"
            : `${missingCount} missing EUR amounts`
      }
    >
      {missingSwitch}
      {accountActions}
    </ListHeader>
  )

  const sidebar = (
    <>
      <DueCalendar />
      <SidebarDivider />
      <SidebarHeader
        title="Accounts"
        info={
          accountsPending ? undefined : formatUsd(totalPosted(own, balances))
        }
      />
      {accountsPending ? (
        <SidebarItemsSkeleton count={5} />
      ) : (
        <AccountFilter
          accounts={own}
          balances={balances}
          selectedId={accountId}
          onSelect={selectedCredit ? undefined : selectAccount}
        />
      )}
      {bankAccounts.some(b => b.user.id === user.id) && (
        <>
          <SidebarHeader title="Bank accounts" />
          <BankAccountItems
            bankAccounts={bankAccounts.filter(b => b.user.id === user.id)}
          />
        </>
      )}
      {user.super_user && others.length > 0 && (
        <>
          <SidebarHeader
            title="Other accounts"
            info={formatUsd(totalPosted(others, balances))}
          />
          <AccountFilter
            showOwner
            accounts={others}
            balances={balances}
            selectedId={null}
          />
          <BankAccountItems
            showOwner
            bankAccounts={bankAccounts.filter(b => b.user.id !== user.id)}
          />
        </>
      )}
    </>
  )

  const mobileTop = (
    <>
      {accountsPending ? (
        <AccountCardsSkeleton />
      ) : (
        <AccountCards
          accounts={own}
          balances={balances}
          selectedId={accountId}
          onSelect={selectedCredit ? () => {} : selectAccount}
          allLines={[
            `${open.filter(isMissing).length} missing EUR`,
            own.length === 1 ? "1 card" : `${own.length} cards`,
          ]}
        />
      )}
      <DueCalendarCard />
      {!selectedCredit && <MobileActions>{missingSwitch}</MobileActions>}
    </>
  )

  return (
    <Workspace
      sidebar={sidebar}
      mobileTop={mobileTop}
      header={header}
      thumb={
        selectedCredit ? (
          <Button
            size="fab"
            aria-label="Done applying credit"
            onClick={() => setCreditSelection(null)}
          >
            <Check />
          </Button>
        ) : (
          account && (
            <>
              <Button
                variant="secondary"
                size="fab"
                aria-label="Export to Actual"
                disabled={actualExport.isPending}
                onClick={() => actualExport.mutate(account.id)}
              >
                <CloudUpload
                  className={actualExport.isPending ? "animate-pulse" : ""}
                />
              </Button>
              <Button
                variant="secondary"
                size="fab"
                aria-label="Import data"
                disabled={importData.isPending}
                onClick={() => importData.mutate(account.id)}
              >
                <Download
                  className={importData.isPending ? "animate-pulse" : ""}
                />
              </Button>
            </>
          )
        )
      }
      thumbRaised={draftCount > 0 && !selectedCredit}
      footer={
        !selectedCredit && (
          <SaveBar
            count={draftCount}
            label={
              draftCount === 1
                ? "1 amount edited"
                : `${draftCount} amounts edited`
            }
            hint="Tab → next field · ⌘↵ saves all"
            saving={save.isPending}
            onSave={saveAll}
            onDiscard={clearDrafts}
          />
        )
      }
    >
      {loading && <ListSkeleton />}

      {!loading && visibleCredits.length > 0 && (
        <>
          <GroupSeparator
            first
            label="Open credits"
            info={
              selectedCredit ? undefined : `${formatUsd(creditTotal)} to apply`
            }
          />
          <Rows>
            {visibleCredits.map(credit => (
              <CreditRow
                key={credit.id}
                credit={credit}
                account={byId.get(credit.account_id)}
                selected={credit.id === creditSelection}
                onToggle={() =>
                  setCreditSelection(
                    credit.id === creditSelection ? null : credit.id,
                  )
                }
              />
            ))}
          </Rows>
        </>
      )}

      {!loading &&
        days.map((day, index) => {
          return (
            <div key={day.key} className="flex flex-col">
              <GroupSeparator
                first={index === 0 && visibleCredits.length === 0}
                label={formatDay(day.key)}
              />
              <Rows>
                {day.items.map(tx => (
                  <TransactionRow
                    key={tx.id}
                    transaction={tx}
                    account={byId.get(tx.account_id)}
                    superUser={user.super_user}
                    onApplyCredit={
                      selectedCredit ? () => setApplyTo(tx) : undefined
                    }
                    creditApplied={
                      selectedCredit != null &&
                      tx.credits.some(ct => ct.credit_id === selectedCredit.id)
                    }
                  />
                ))}
              </Rows>
            </div>
          )
        })}

      {!loading && visible.length === 0 && (
        <EmptyState>
          {missingEurOnly && inAccount.length > 0
            ? "Every transaction has an EUR amount."
            : "No open transactions."}
        </EmptyState>
      )}

      {selectedCredit && applyTo && (
        <ApplyCreditDialog
          credit={selectedCredit}
          transaction={applyTo}
          account={byId.get(applyTo.account_id)}
          onClose={() => setApplyTo(null)}
        />
      )}
    </Workspace>
  )
}
