import CreditTable from "@/components/table/CreditTable.tsx";
import {fetchAccounts, fetchCredits} from "@/requests.ts";
import Card from "@/components/card/Card.tsx";

export default async function CreditsCard() {
  const accounts = await fetchAccounts()
  const activeAccounts = accounts.filter(account => account.active)
  const activeAccountIds = new Set(activeAccounts.map(account => account.id))
  const credits = (await fetchCredits()).filter(credit => activeAccountIds.has(credit.account_id))

  return (
    <Card title="Credits">
        <CreditTable credits={credits} accounts={activeAccounts}/>
    </Card>
  )
}
