export type User = {
  id: number
  name: string
  super_user: boolean
}

export type Account = {
  id: number
  user: User
  bank_account_id: number | null
  actual_id: string
  plaid_account_id: number | null
  name: string
  institution: string
  due_day: number | null
  autopay_offset: number | null
  color: string | null
  target_spend: number | null
  active: boolean
}

export type BankAccount = {
  id: number
  user: User
  name: string
  institution: string
  balance: number
  plaid_account_id: number | null
  last_successful_update: string | null
}

export type Credit = {
  id: number
  account_id: number
  import_id: string
  date: string
  counterparty: string
  description: string
  category: string
  amount_usd: number
  transactions: Array<CreditTransaction>
}

export type CreditTransaction = {
  amount: number
  credit_id: number
  transaction_id: number
}

export type Transaction = {
  id: number
  account_id: number
  import_id: string
  actual_id: string | null
  date: string
  counterparty: string
  description: string
  category: string
  amount_usd: number
  amount_eur: number | null
  guessed_amount_eur: number | null
  status: number
  payment_id: number | null
  fees_and_risk_eur: number | null
  credits: Array<CreditTransaction>
  ignore: boolean | null
  exchange_rate: number | null
  cashback_exchange_id: number | null
}

export type TransactionAmountMap = Record<number, number | null>

export type StatementMatchResult = {
  transaction_id: number
  date: string
  amount_usd: number
  amount_eur: number | null
  guessed_amount_eur: number | null
  counterparty: string
  description: string
  matched: boolean
  confidence: number
  statement_excerpt: string | null
  reason: string
}

export type StatementMatchResponse = {
  account_id: number
  results: Array<StatementMatchResult>
}

export type Exchange = {
  id: number
  actual_id: string | null
  date: string
  amount_usd: number
  exchange_rate: number
  amount_eur: number | null
  paid_eur: number
  fees_eur: number | null
  cashback_transaction_id: number | null
  cashback_transaction_description: string | null
  payments: Array<ExchangePayment>
}

export type ExchangePayment = {
  amount: number
  exchange_id: number
  payment_id: number
}

export type Payment = {
  id: number
  account_id: number
  import_id: string
  actual_id: string | null
  date: string
  counterparty: string
  description: string
  category: string
  amount_usd: number
  amount_eur_with_fx: number | null
  amount_eur_without_fx: number | null
  status: number
  exchanges: Array<ExchangePayment>
}

export type Balances = {
  total: number
  posted: number
  pending: number
  credits: number
  exchanged: number
  virtual_account: string
  avg_exchange_rate: number
}

export type AccountBalances = Record<string, AccountBalance | undefined>

export type AccountBalance = {
  posted: number
  pending: number
  total_spent: number
  total_credits: number
  last_successful_update: string | null
}

export type FeeSummary = {
  fees_and_risk_eur: number
  paid_eur: number
}

export type AccountDatesMap = Record<string, AccountDates | undefined>

export type AccountDates = {
  color: string
  due: string
  statement: string
}

export type PlaidAccount = {
  id: number
  name: string
  plaid_account_id: string
  connection_id: number
}

export type PlaidConnection = {
  id: number
  user: User
  name: string | null
  plaid_item_id: string
  plaid_accounts: Array<PlaidAccount>
}

export type TransactionAmountsResult = {
  saved: Array<number>
  actual_failed: Array<number>
}

export const Status = { PENDING: 1, POSTED: 2, PAID: 3 } as const
