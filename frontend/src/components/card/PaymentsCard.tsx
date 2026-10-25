import {fetchAccounts, fetchPayments} from "@/requests.ts";
import Card from "@/components/card/Card.tsx";
import PaymentTable from "@/components/table/PaymentTable.tsx";

export default async function PaymentsCard() {
  const accounts = await fetchAccounts()
  const activeAccounts = accounts.filter(account => account.active)
  const activeAccountIds = new Set(activeAccounts.map(account => account.id))
  const payments = (await fetchPayments()).filter(payment => activeAccountIds.has(payment.account_id))

  return (
    <Card title="Payments">
        <PaymentTable payments={payments} accounts={activeAccounts}/>
    </Card>
  )
}
