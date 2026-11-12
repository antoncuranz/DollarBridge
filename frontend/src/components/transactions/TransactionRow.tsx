import { Link as LinkIcon } from "lucide-react"

import type { Account, Transaction } from "@/types"
import type { RowMenuItem } from "@/components/list/RowMenu"
import { useCashback } from "@/api/mutations"
import { EurField } from "@/components/list/EurField"
import { Amount, Row, Swatch } from "@/components/list/Row"
import { RowMenu } from "@/components/list/RowMenu"
import { Button } from "@/components/ui/button"
import { Chip } from "@/components/ui/chip"
import {
  appliedCredits,
  canMarkCashback,
  deviationLabel,
  hasLargeDeviation,
} from "@/lib/derive"
import { formatUsd } from "@/lib/money"
import { useStore } from "@/store"
import { Status } from "@/types"

export function TransactionRow({
  transaction,
  account,
  superUser,
  onApplyCredit,
}: {
  transaction: Transaction
  account?: Account
  superUser: boolean
  /** set in apply-credit mode: the row offers the credit instead of the EUR field */
  onApplyCredit?: () => void
}) {
  const hasDraft = useStore(state => transaction.id in state.drafts)
  const draft = useStore(state => state.drafts[transaction.id])
  const setDraft = useStore(state => state.setDraft)
  const clearDraft = useStore(state => state.clearDraft)
  const cashback = useCashback()

  const value = hasDraft ? (draft ?? null) : transaction.amount_eur
  const warning = hasLargeDeviation(transaction.guessed_amount_eur, value)
  const deviation = deviationLabel(transaction.guessed_amount_eur, value)
  const credits = appliedCredits(transaction)
  const isCashback = transaction.cashback_exchange_id != null
  const selectable = onApplyCredit != null

  const menu: Array<RowMenuItem> = []
  if (superUser && !selectable) {
    if (isCashback) {
      menu.push({
        label: "Undo cashback",
        disabled: cashback.isPending,
        onSelect: () => {
          clearDraft(transaction.id)
          cashback.mutate({ id: transaction.id, undo: true })
        },
      })
    } else if (canMarkCashback(transaction)) {
      menu.push({
        label: "Cashback",
        disabled: cashback.isPending,
        onSelect: () => {
          clearDraft(transaction.id)
          cashback.mutate({ id: transaction.id, undo: false })
        },
      })
    }
  }

  const usd =
    credits > 0 ? (
      <>
        <Amount struck>{formatUsd(transaction.amount_usd)}</Amount>
        <Amount className="text-success">
          {formatUsd(transaction.amount_usd - credits)}
        </Amount>
      </>
    ) : (
      <Amount className="min-w-[76px]">
        {formatUsd(transaction.amount_usd)}
      </Amount>
    )

  const description = [transaction.description, deviation]
    .filter(Boolean)
    .join(" · ")

  return (
    <RowMenu items={menu}>
      <Row
        swatch={<Swatch account={account} />}
        title={transaction.counterparty}
        description={description}
        meta={formatUsd(transaction.amount_usd - credits)}
        tone={selectable ? "selectable" : "default"}
        pending={transaction.status === Status.PENDING}
        struck={transaction.ignore === true}
        columns={
          <>
            {isCashback && <Chip state="success">Cashback</Chip>}
            <span
              className="flex items-center gap-2.5"
              title={
                transaction.exchange_rate != null
                  ? `Exchange rate: ${transaction.exchange_rate}`
                  : undefined
              }
            >
              {usd}
            </span>
          </>
        }
        field={
          selectable ? (
            <Button variant="accent" size="sm" onClick={onApplyCredit}>
              <LinkIcon />
              <span className="max-md:sr-only">Apply credit</span>
            </Button>
          ) : (
            <EurField
              label={`EUR amount for ${transaction.counterparty}`}
              value={value}
              estimate={transaction.guessed_amount_eur}
              draft={hasDraft}
              warning={warning}
              disabled={cashback.isPending}
              onChange={amount => {
                if (amount === transaction.amount_eur)
                  clearDraft(transaction.id)
                else setDraft(transaction.id, amount)
              }}
            />
          )
        }
      />
    </RowMenu>
  )
}
