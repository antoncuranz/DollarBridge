import { zodResolver } from "@hookform/resolvers/zod"
import { Check } from "lucide-react"
import { useId } from "react"
import { Controller, useForm } from "react-hook-form"
import { z } from "zod"

import { Dialog, Field } from "./Dialog"
import { PlaidAccountSelect } from "./PlaidAccountSelect"
import type { BankAccount, PlaidConnection } from "@/types"
import { useSaveBankAccount } from "@/api/mutations"
import { useUser } from "@/api/useUser"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"

const schema = z.object({
  name: z.string().trim().min(1, "Required"),
  institution: z.string().trim().min(1, "Required"),
  icon: z.string().trim(),
  plaid_account_id: z.number().nullable(),
})

type Values = z.infer<typeof schema>

/** Edits a bank account, or adds one when none is given. */
export function BankAccountDialog({
  bankAccount,
  connections,
  onClose,
}: {
  bankAccount?: BankAccount
  connections: Array<PlaidConnection>
  onClose: () => void
}) {
  const user = useUser()
  const id = useId()
  const mutation = useSaveBankAccount(bankAccount?.id)

  const {
    register,
    control,
    handleSubmit,
    formState: { errors },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: bankAccount?.name ?? "",
      institution: bankAccount?.institution ?? "",
      icon: bankAccount?.icon ?? "",
      plaid_account_id: bankAccount?.plaid_account_id ?? null,
    },
  })

  const submit = handleSubmit(values =>
    mutation.mutate(
      { ...values, icon: values.icon || null },
      { onSuccess: onClose },
    ),
  )

  return (
    <Dialog
      open
      onClose={onClose}
      title={bankAccount ? "Edit bank account" : "Add bank account"}
      footer={
        <Button
          size="lg"
          className="flex-1 rounded-full"
          disabled={mutation.isPending}
          onClick={() => void submit()}
        >
          <Check />
          {mutation.isPending ? "Saving…" : "Save"}
        </Button>
      }
    >
      <form
        className="flex flex-col gap-3"
        onSubmit={event => void submit(event)}
      >
        <Field label="Name" htmlFor={id + "name"} error={errors.name?.message}>
          <Input id={id + "name"} autoFocus {...register("name")} />
        </Field>
        <Field
          label="Institution"
          htmlFor={id + "institution"}
          error={errors.institution?.message}
        >
          <Input id={id + "institution"} {...register("institution")} />
        </Field>
        <Field label="Icon" htmlFor={id + "icon"}>
          <Input
            id={id + "icon"}
            placeholder="Image URL (optional)"
            {...register("icon")}
          />
        </Field>
        <Field label="Plaid connection" htmlFor={id + "plaid"}>
          <Controller
            control={control}
            name="plaid_account_id"
            render={({ field }) => (
              <PlaidAccountSelect
                id={id + "plaid"}
                connections={connections}
                userId={bankAccount?.user.id ?? user.id}
                value={field.value}
                onChange={field.onChange}
              />
            )}
          />
        </Field>
        <button type="submit" className="hidden" />
      </form>
    </Dialog>
  )
}
