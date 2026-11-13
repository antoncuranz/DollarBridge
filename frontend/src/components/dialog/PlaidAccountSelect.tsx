import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectPositioner,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import type { PlaidConnection } from "@/types"

const NONE = -1

/** Plaid accounts of one user, grouped by connection. */
export function PlaidAccountSelect({
  id,
  connections,
  userId,
  value,
  onChange,
}: {
  id?: string
  connections: Array<PlaidConnection>
  userId: number
  value: number | null
  onChange: (value: number | null) => void
}) {
  const own = connections.filter(connection => connection.user.id === userId)
  const items = [
    { value: NONE, label: "Not connected" },
    ...own.flatMap(connection =>
      connection.plaid_accounts.map(account => ({
        value: account.id,
        label: `${connection.name ?? "Plaid"} · ${account.name}`,
      })),
    ),
  ]

  return (
    <Select
      items={items}
      value={value ?? NONE}
      onValueChange={next =>
        onChange(next === NONE || next == null ? null : (next as number))
      }
    >
      <SelectTrigger id={id}>
        <SelectValue placeholder="Choose an account…" />
      </SelectTrigger>
      <SelectPositioner>
        <SelectContent>
          <SelectItem value={NONE}>Not connected</SelectItem>
          {own.map(connection => (
            <SelectGroup key={connection.id}>
              <SelectLabel>
                {connection.name ?? connection.plaid_item_id}
              </SelectLabel>
              {connection.plaid_accounts.map(account => (
                <SelectItem key={account.id} value={account.id}>
                  {account.name}
                </SelectItem>
              ))}
            </SelectGroup>
          ))}
        </SelectContent>
      </SelectPositioner>
    </Select>
  )
}
