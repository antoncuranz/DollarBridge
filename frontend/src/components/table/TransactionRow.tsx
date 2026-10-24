import EditableTransactionRow from "@/components/table/EditableTransactionRow.tsx";
import {formatAmount} from "@/components/util.ts";
import {useToast} from "@/components/ui/use-toast.ts";
import {useStore} from "@/store.ts";
import {Account, Transaction} from "@/types.ts";
import {MouseEventHandler, useState} from "react";
import {ContextMenu, ContextMenuContent, ContextMenuItem, ContextMenuTrigger} from "@/components/ui/context-menu.tsx";

export default function TransactionRow({
  transaction, account, readonly, selectable, onClick, canMarkCashback = false, onCashback, onUndoCashback
}: {
  transaction: Transaction,
  onClick: MouseEventHandler<HTMLTableRowElement> | undefined;
  account?: Account,
  readonly?: boolean,
  selectable?: boolean,
  canMarkCashback?: boolean,
  onCashback?: (transaction: Transaction) => Promise<void>,
  onUndoCashback?: (transaction: Transaction) => Promise<void>,
}) {
  const {putTransactionAmount, clearTransactionAmount} = useStore()
  const {toast} = useToast()
  const [cashbackInProgress, setCashbackInProgress] = useState(false)

  function isCreditApplied() {
    return transaction.credits != null && transaction.credits.length > 0
  }

  function calculateCredit() {
    return transaction.credits.map(ct => ct.amount).reduce((a, b) => a + b, 0)
  }

  function getClasses() {
    const classes = []

    if (selectable)
      classes.push("hover:bg-muted cursor-pointer")

    if (transaction.ignore)
      classes.push("line-through")

    return classes.join(" ")
  }

  function toastExchangeRate() {
    toast({
      title: "Exchange rate: " + transaction.exchange_rate?.toString(),
    })
  }

  function updateTransactionAmount(amount: number | null) {
    if (transaction.amount_eur == amount)
      clearTransactionAmount(transaction.id)
    else
      putTransactionAmount(transaction.id, amount)
  }

  async function runCashbackAction(action: ((transaction: Transaction) => Promise<void>) | undefined) {
    if (!action) return
    setCashbackInProgress(true)
    try {
      await action(transaction)
    } finally {
      setCashbackInProgress(false)
    }
  }

  const row = (
    <EditableTransactionRow
      onClick={onClick}
      className={getClasses()}
      style={{borderLeftStyle: transaction.status == 1 ? "dashed" : "solid"}}
      account={account}
      date={transaction.date}
      remoteName={transaction.counterparty}
      purpose={transaction.description}
      amount={transaction.amount_eur}
      placeholderAmount={transaction.guessed_amount_eur}
      onAmountChange={updateTransactionAmount}
      amountDisabled={readonly || cashbackInProgress}
      afterAmountInput={
        <>
          {transaction.cashback_exchange_id != null && <span className="mr-2 text-xs font-medium text-muted-foreground">Cashback</span>}
          <span className="price text-sm" onClick={toastExchangeRate}>
            {isCreditApplied() ?
              <>
                <span className="line-through mr-1">{formatAmount(transaction.amount_usd)}</span>
                <span style={{color: "green"}}>{formatAmount(transaction.amount_usd - calculateCredit())}</span>
              </>
              :
              formatAmount(transaction.amount_usd)
            }
          </span>
        </>
      }
    />
  )

  const canChangeCashback = canMarkCashback && !readonly && !selectable
  const showCashback = canChangeCashback && transaction.cashback_exchange_id == null && onCashback != null &&
    transaction.status == 2 && transaction.amount_usd > 0
  const showUndoCashback = canChangeCashback && transaction.cashback_exchange_id != null && onUndoCashback != null
  const hasContextAction = showCashback || showUndoCashback

  return (
    <ContextMenu>
      <ContextMenuTrigger asChild>
        <div className="tx-row-border" onContextMenu={hasContextAction ? undefined : event => event.preventDefault()}>{row}</div>
      </ContextMenuTrigger>
      {hasContextAction && <ContextMenuContent>
        {showCashback && <ContextMenuItem disabled={cashbackInProgress} onSelect={() => void runCashbackAction(onCashback)}>
          {cashbackInProgress ? "Marking cashback…" : "Cashback"}
        </ContextMenuItem>}
        {showUndoCashback && <ContextMenuItem disabled={cashbackInProgress} onSelect={() => void runCashbackAction(onUndoCashback)}>
          {cashbackInProgress ? "Undoing cashback…" : "Undo Cashback"}
        </ContextMenuItem>}
      </ContextMenuContent>}
    </ContextMenu>
  )
}
