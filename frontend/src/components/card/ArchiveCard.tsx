import {fetchAccounts, fetchTransactions} from "@/requests.ts";
import Card from "@/components/card/Card.tsx";
import ArchiveTable from "@/components/table/ArchiveTable.tsx";

export default async function ArchiveCard() {
  const accounts = await fetchAccounts()
  const activeAccounts = accounts.filter(account => account.active)
  const activeAccountIds = new Set(activeAccounts.map(account => account.id))
  const transactions = (await fetchTransactions()).filter(transaction => activeAccountIds.has(transaction.account_id))

  return (
    <Card title="Paid Transactions">
        <ArchiveTable transactions={transactions} accounts={activeAccounts}/>
    </Card>
  )
}
