import { createFileRoute } from "@tanstack/react-router"
import { Check, FileText, Upload, X } from "lucide-react"
import { useRef, useState } from "react"
import { toast } from "sonner"

import type { StatementTab } from "@/components/statements/store"
import type { Account, StatementMatchResult } from "@/types"
import { useSaveAmounts } from "@/api/mutations"
import { EurField } from "@/components/list/EurField"
import { GroupSeparator } from "@/components/list/GroupSeparator"
import { Amount, EurValue, Row, RowAction, Swatch } from "@/components/list/Row"
import { SaveBar } from "@/components/shell/SaveBar"
import {
  EmptyState,
  ListHeader,
  Rows,
  Workspace,
} from "@/components/shell/Workspace"
import { SidebarHeader } from "@/components/sidebar/AccountFilter"
import {
  amountsToSave,
  reviewGroups,
  useStatements,
} from "@/components/statements/store"
import { useAccounts } from "@/components/transactions/useOwnAccounts"
import { Button } from "@/components/ui/button"
import { Chip } from "@/components/ui/chip"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectPositioner,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { deviationLabel, hasLargeDeviation } from "@/lib/derive"
import { formatAmount, formatUsd } from "@/lib/money"
import { cn } from "@/lib/utils"

export const Route = createFileRoute("/statements")({
  component: StatementsPage,
})

const percent = (confidence: number) =>
  `${Math.round(confidence * 100)} % match`

function TabChip({ tab }: { tab: StatementTab }) {
  if (tab.status === "loading") return <Chip state="accent">loading</Chip>
  if (tab.status === "saved") return <Chip state="success">saved</Chip>
  if (tab.status === "error") return <Chip state="warning">failed</Chip>
  const { review, ready } = reviewGroups(tab)
  const total = review.length + ready.length
  return review.length > 0 ? (
    <Chip state="warning">
      {ready.length} of {total}
    </Chip>
  ) : (
    <Chip>{total}</Chip>
  )
}

function Uploader({ accounts }: { accounts: Array<Account> }) {
  const tabs = useStatements(state => state.tabs)
  const upload = useStatements(state => state.upload)
  const input = useRef<HTMLInputElement>(null)
  const [dragging, setDragging] = useState(false)
  const [chosen, setChosen] = useState<number | null>(null)

  const busy = new Set(
    tabs.filter(tab => tab.status !== "saved").map(tab => tab.accountId),
  )
  const free = accounts.filter(account => !busy.has(account.id))
  const accountId =
    chosen != null && !busy.has(chosen) ? chosen : (free[0]?.id ?? null)

  function accept(file: File | undefined) {
    if (!file) return
    if (
      file.type !== "application/pdf" &&
      !file.name.toLowerCase().endsWith(".pdf")
    ) {
      toast.error("Only PDF statements can be matched")
      return
    }
    if (accountId == null) {
      toast.error("Every account already has an open statement")
      return
    }
    upload(accountId, file)
  }

  return (
    <div className="flex flex-col gap-2">
      <Select
        value={accountId}
        onValueChange={value => setChosen(value as number)}
        items={accounts.map(account => ({
          value: account.id,
          label: account.name,
        }))}
      >
        <SelectTrigger aria-label="Account of the statement">
          <SelectValue placeholder="Choose an account…" />
        </SelectTrigger>
        <SelectPositioner>
          <SelectContent>
            {accounts.map(account => (
              <SelectItem
                key={account.id}
                value={account.id}
                disabled={busy.has(account.id)}
              >
                <Swatch account={account} />
                {account.name}
              </SelectItem>
            ))}
          </SelectContent>
        </SelectPositioner>
      </Select>
      <button
        type="button"
        onClick={() => input.current?.click()}
        onDragOver={event => {
          event.preventDefault()
          setDragging(true)
        }}
        onDragLeave={() => setDragging(false)}
        onDrop={event => {
          event.preventDefault()
          setDragging(false)
          accept(event.dataTransfer.files[0])
        }}
        className={cn(
          "flex flex-col items-center gap-1 rounded-2xl border border-dashed px-4 py-5 text-center transition-colors hover:bg-muted",
          dragging && "border-accent bg-accent-soft",
        )}
      >
        <Upload className="mb-1 size-5" />
        <span className="text-[13px] leading-[19px] font-medium">
          Drop a statement PDF
        </span>
        <span className="text-xs leading-[17px] text-muted-foreground">
          Matched against unpaid transactions
        </span>
      </button>
      <input
        ref={input}
        type="file"
        accept="application/pdf,.pdf"
        className="hidden"
        onChange={event => {
          accept(event.target.files?.[0])
          event.target.value = ""
        }}
      />
    </div>
  )
}

function TabList({ byId }: { byId: Map<number, Account> }) {
  const tabs = useStatements(state => state.tabs)
  const activeId = useStatements(state => state.activeId)
  const setActive = useStatements(state => state.setActive)
  const close = useStatements(state => state.close)

  return (
    <>
      {tabs.map(tab => (
        <div
          key={tab.id}
          className={cn(
            "group flex h-10 shrink-0 items-center gap-1 rounded-row pr-2.5 pl-2.5 transition-colors hover:bg-muted",
            tab.id === activeId && "bg-muted",
          )}
        >
          <button
            type="button"
            className="flex min-w-0 flex-1 items-center gap-2 text-left"
            onClick={() => setActive(tab.id)}
          >
            <FileText className="size-4 shrink-0 text-muted-foreground" />
            <span className="truncate text-sm leading-5 font-medium">
              {byId.get(tab.accountId)?.name ?? "Account"} · {tab.fileName}
            </span>
          </button>
          <TabChip tab={tab} />
          <button
            type="button"
            aria-label="Close statement"
            className="rounded-field p-0.5 text-muted-foreground hover:text-foreground md:hidden md:group-hover:block"
            onClick={() => close(tab.id)}
          >
            <X className="size-4" />
          </button>
        </div>
      ))}
    </>
  )
}

function StatementsPage() {
  const { byId, own } = useAccounts()
  const tabs = useStatements(state => state.tabs)
  const activeId = useStatements(state => state.activeId)
  const update = useStatements(state => state.update)
  const close = useStatements(state => state.close)
  const [expanded, setExpanded] = useState<number | null>(null)

  const tab = tabs.find(t => t.id === activeId) ?? null
  const account = tab ? byId.get(tab.accountId) : undefined
  const groups = tab ? reviewGroups(tab) : null
  const toSave = tab && tab.status === "ready" ? amountsToSave(tab) : {}
  const saveCount = Object.keys(toSave).length

  const save = useSaveAmounts(() => {
    if (tab) update(tab.id, t => ({ ...t, status: "saved" }))
  })

  const picker = (
    <>
      <TabList byId={byId} />
      <Uploader accounts={own} />
    </>
  )

  function setAmount(row: StatementMatchResult, amount: number | null) {
    if (!tab) return
    update(tab.id, t => ({
      ...t,
      amounts: { ...t.amounts, [row.transaction_id]: amount },
    }))
  }

  function move(
    row: StatementMatchResult,
    target: "accepted" | "skipped" | null,
  ) {
    if (!tab) return
    const id = row.transaction_id
    update(tab.id, t => ({
      ...t,
      accepted:
        target === "accepted"
          ? [...t.accepted, id]
          : t.accepted.filter(x => x !== id),
      skipped:
        target === "skipped"
          ? [...t.skipped, id]
          : t.skipped.filter(x => x !== id),
    }))
  }

  function matchRow(
    row: StatementMatchResult,
    kind: "review" | "ready" | "skipped",
  ) {
    if (!tab) return null
    const amount = tab.amounts[row.transaction_id] ?? null
    const readonly = tab.status === "saved" || kind === "skipped"
    const deviation = deviationLabel(row.guessed_amount_eur, amount)
    const open =
      kind === "review" &&
      (expanded ?? groups?.review[0]?.transaction_id) === row.transaction_id

    return (
      <Row
        key={row.transaction_id}
        swatch={<Swatch account={account} />}
        tone={kind === "review" ? "warning" : "default"}
        dimmed={kind === "skipped"}
        title={row.counterparty}
        description={
          tab.status === "saved"
            ? "EUR amount saved"
            : [
                percent(row.confidence),
                deviation && "amount differs from estimate",
              ]
                .filter(Boolean)
                .join(" · ")
        }
        meta={formatUsd(row.amount_usd)}
        columns={
          <Amount className="min-w-[76px]">{formatUsd(row.amount_usd)}</Amount>
        }
        field={
          readonly ? (
            <EurValue amount={formatAmount(amount) || "–"} />
          ) : (
            <EurField
              label={`EUR amount for ${row.counterparty}`}
              value={amount}
              estimate={row.guessed_amount_eur}
              draft={kind === "ready"}
              warning={
                kind === "review" ||
                hasLargeDeviation(row.guessed_amount_eur, amount)
              }
              onChange={value => setAmount(row, value)}
            />
          )
        }
        action={
          kind === "skipped" ? (
            <Button variant="ghost" size="sm" onClick={() => move(row, null)}>
              Restore
            </Button>
          ) : kind === "review" && !open ? (
            <RowAction
              label="Show details"
              onClick={() => setExpanded(row.transaction_id)}
            >
              <FileText />
            </RowAction>
          ) : undefined
        }
        expanded={
          open && (
            <div className="flex flex-col gap-3 px-3 pb-2.5 md:flex-row md:items-center md:pl-[42px]">
              <div className="rounded-field bg-field px-3 py-1.5">
                <p className="text-xs leading-[17px] text-muted-foreground">
                  Statement excerpt
                </p>
                <p className="text-[13px] leading-[19px] font-medium">
                  {row.statement_excerpt ?? "–"}
                </p>
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-xs leading-[17px] text-muted-foreground">
                  Why this match
                </p>
                <p className="text-[13px] leading-[19px]">{row.reason}</p>
              </div>
              <div className="flex shrink-0 items-center gap-1">
                <Button variant="ghost" onClick={() => move(row, "skipped")}>
                  Skip
                </Button>
                <Button onClick={() => move(row, "accepted")}>
                  <Check />
                  Accept
                </Button>
              </div>
            </div>
          )
        }
      />
    )
  }

  return (
    <Workspace
      sidebar={
        <>
          <SidebarHeader title="Statements" />
          {picker}
        </>
      }
      mobileTop={<div className="flex flex-col gap-1.5 px-6">{picker}</div>}
      header={
        <ListHeader
          title={
            tab
              ? `${account?.name ?? "Account"} · ${tab.fileName}`
              : "Statements"
          }
          subtitle={
            tab?.status === "ready" && groups
              ? `${groups.ready.length} matched · ${groups.review.length} to check`
              : tab?.status === "loading"
                ? "Matching…"
                : tab?.status === "saved"
                  ? "Saved"
                  : undefined
          }
        />
      }
      footer={
        tab?.status === "ready" && (
          <SaveBar
            count={saveCount}
            label={
              saveCount === 1 ? "1 amount ready" : `${saveCount} amounts ready`
            }
            hint={
              groups && groups.review.length > 0
                ? `${groups.review.length} ${groups.review.length === 1 ? "match still needs" : "matches still need"} a look`
                : undefined
            }
            saveLabel={
              saveCount === 1 ? "Save 1 amount" : `Save ${saveCount} amounts`
            }
            saving={save.isPending}
            onSave={() => save.mutate(toSave)}
            onDiscard={() => close(tab.id)}
          />
        )
      }
    >
      {!tab && (
        <EmptyState>
          Upload a card statement to fill in the EUR amounts of its unpaid
          transactions.
        </EmptyState>
      )}
      {tab?.status === "loading" && (
        <EmptyState>
          Reading {tab.fileName} and matching it against open transactions…
        </EmptyState>
      )}
      {tab?.status === "error" && (
        <EmptyState>
          <span className="text-destructive">
            The statement could not be matched: {tab.error}
          </span>
        </EmptyState>
      )}
      {tab && groups && (tab.status === "ready" || tab.status === "saved") && (
        <>
          {tab.rows.length === 0 && (
            <EmptyState>
              No open transaction of this account appears in the statement.
            </EmptyState>
          )}
          {groups.review.length > 0 && tab.status === "ready" && (
            <>
              <GroupSeparator
                first
                label="Needs a look"
                info={groups.review.length}
              />
              <Rows>{groups.review.map(row => matchRow(row, "review"))}</Rows>
            </>
          )}
          {groups.ready.length > 0 && (
            <>
              <GroupSeparator
                first={groups.review.length === 0 || tab.status === "saved"}
                label={tab.status === "saved" ? "Already saved" : "Matched"}
                info={
                  tab.status === "saved"
                    ? groups.ready.length
                    : `${groups.ready.length} · will be saved`
                }
              />
              <Rows>{groups.ready.map(row => matchRow(row, "ready"))}</Rows>
            </>
          )}
          {groups.skipped.length > 0 && tab.status === "ready" && (
            <>
              <GroupSeparator label="Skipped" info={groups.skipped.length} />
              <Rows>{groups.skipped.map(row => matchRow(row, "skipped"))}</Rows>
            </>
          )}
        </>
      )}
    </Workspace>
  )
}
