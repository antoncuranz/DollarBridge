import { Link as LinkIcon } from "lucide-react"

import type { Account, Credit } from "@/types"
import { Amount, Row, RowAction, Swatch } from "@/components/list/Row"
import { creditRemainder } from "@/lib/derive"
import { formatUsd } from "@/lib/money"

export function CreditRow({
  credit,
  account,
  selected,
  onToggle,
}: {
  credit: Credit
  account?: Account
  selected: boolean
  onToggle: () => void
}) {
  const remainder = creditRemainder(credit)
  const left = (
    <span className="tabular w-[100px] shrink-0 pr-2.5 text-right text-sm leading-5 whitespace-nowrap text-success md:w-[108px]">
      {formatUsd(remainder)} left
    </span>
  )

  return (
    <Row
      swatch={<Swatch account={account} />}
      title={credit.counterparty}
      description={credit.description}
      tone={selected ? "selected" : "default"}
      columns={
        remainder !== credit.amount_usd ? (
          <Amount struck>{formatUsd(credit.amount_usd)}</Amount>
        ) : undefined
      }
      field={left}
      action={
        <RowAction
          label={selected ? "Stop applying this credit" : "Apply this credit"}
          active={selected}
          onClick={onToggle}
        >
          <LinkIcon />
        </RowAction>
      }
    />
  )
}
