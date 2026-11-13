import { zodResolver } from "@hookform/resolvers/zod"
import { Check } from "lucide-react"
import { useId, useRef } from "react"
import { Controller, useForm } from "react-hook-form"
import { z } from "zod"

import { useSaveAccount } from "@/api/mutations"
import { useUser } from "@/api/useUser"
import { Button } from "@/components/ui/button"
import { Input, fieldClassName } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectPositioner,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Switch } from "@/components/ui/switch"
import { cn } from "@/lib/utils"
import { PlaidAccountSelect } from "./PlaidAccountSelect"
import { Dialog, Field } from "./Dialog"
import type { Account, BankAccount, Issuer, PlaidConnection } from "@/types"

const optionalInteger = (min: number, max: number, message: string) =>
  z
    .string()
    .trim()
    .refine(
      value =>
        value === "" ||
        (/^\d+$/.test(value) && Number(value) >= min && Number(value) <= max),
      message,
    )

const schema = z.object({
  name: z.string().trim().min(1, "Required"),
  institution: z.string().trim().min(1, "Required"),
  issuer: z.enum(["amex", "capital_one", "chase", "other"]),
  color: z
    .string()
    .trim()
    .refine(
      value => value === "" || /^#[0-9a-f]{6}$/i.test(value),
      "Use a hex colour such as #A33A2C",
    ),
  due_day: optionalInteger(1, 31, "1 to 31"),
  autopay_offset: optionalInteger(0, 31, "0 to 31"),
  target_spend: optionalInteger(0, 10_000_000, "Whole dollars"),
  bank_account_id: z.number().nullable(),
  plaid_account_id: z.number().nullable(),
  actual_id: z.string().trim(),
  active: z.boolean(),
})

type Values = z.infer<typeof schema>

const toNumber = (value: string) => (value === "" ? null : Number(value))
const toText = (value: number | null | undefined) =>
  value == null ? "" : String(value)

const NONE = -1

/** How each issuer derives the autopay and statement dates from the due day. */
const issuers: Record<
  Issuer,
  { label: string; rule: string; autopayOffset: number }
> = {
  amex: {
    label: "American Express",
    rule: "Autopay a few days before the due date, a Sunday moves to Saturday. Statement closes 25 days before the due date.",
    autopayOffset: 10,
  },
  capital_one: {
    label: "Capital One",
    rule: "Autopay on the due date, a Sunday moves to Monday. Statement closes 25 days before the due date.",
    autopayOffset: 0,
  },
  chase: {
    label: "Chase",
    rule: "Autopay on the due date, a Saturday moves to Friday. Statement closes 3 days after the due day, one month earlier.",
    autopayOffset: 0,
  },
  other: {
    label: "Other",
    rule: "Autopay exactly on the due date minus the offset. Statement closes 25 days before the due date.",
    autopayOffset: 0,
  },
}
const issuerKeys = Object.keys(issuers) as Array<Issuer>

/** Edits a credit card, or adds one when no account is given. */
export function CreditCardDialog({
  account,
  bankAccounts,
  connections,
  onClose,
}: {
  account?: Account
  bankAccounts: Array<BankAccount>
  connections: Array<PlaidConnection>
  onClose: () => void
}) {
  const user = useUser()
  const ownerId = account?.user.id ?? user.id
  const id = useId()
  const mutation = useSaveAccount(account?.id)

  const {
    register,
    control,
    handleSubmit,
    watch,
    setValue,
    formState: { errors },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: {
      name: account?.name ?? "",
      institution: account?.institution ?? "",
      issuer: account?.issuer ?? "other",
      color: account?.color ?? "",
      due_day: toText(account?.due_day),
      autopay_offset: toText(account?.autopay_offset),
      target_spend: toText(account?.target_spend),
      bank_account_id: account?.bank_account_id ?? null,
      plaid_account_id: account?.plaid_account_id ?? null,
      actual_id: account?.actual_id ?? "",
      active: account?.active ?? true,
    },
  })

  const color = watch("color")
  const issuer = watch("issuer")
  const ownBankAccounts = bankAccounts.filter(b => b.user.id === ownerId)

  // Enter in the form can fire again while the save is still running
  const saving = useRef(false)
  const submit = handleSubmit(async values => {
    if (saving.current) return
    saving.current = true
    try {
      await mutation.mutateAsync({
        name: values.name,
        institution: values.institution,
        issuer: values.issuer,
        color: values.color || null,
        due_day: toNumber(values.due_day),
        autopay_offset: toNumber(values.autopay_offset),
        target_spend: toNumber(values.target_spend),
        bank_account_id: values.bank_account_id,
        plaid_account_id: values.plaid_account_id,
        actual_id: values.actual_id || null,
        active: values.active,
      })
      onClose()
    } catch {
      // already toasted by the mutation
    } finally {
      saving.current = false
    }
  })

  return (
    <Dialog
      open
      onClose={onClose}
      title={account ? "Edit credit card" : "Add credit card"}
      className="sm:max-w-[480px]"
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
        <div className="grid grid-cols-2 gap-3">
          <Field
            label="Name"
            htmlFor={id + "name"}
            error={errors.name?.message}
          >
            <Input id={id + "name"} autoFocus {...register("name")} />
          </Field>
          <Field
            label="Institution"
            htmlFor={id + "institution"}
            error={errors.institution?.message}
          >
            <Input id={id + "institution"} {...register("institution")} />
          </Field>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Field
            label="Color"
            htmlFor={id + "color"}
            error={errors.color?.message}
          >
            <div
              className={cn(
                fieldClassName,
                "focus-within:border-accent focus-within:shadow-focus",
              )}
            >
              <span
                className="size-3 shrink-0 rounded-[2px] bg-border"
                style={
                  /^#[0-9a-f]{6}$/i.test(color)
                    ? { backgroundColor: color }
                    : undefined
                }
              />
              <input
                id={id + "color"}
                placeholder="#A33A2C"
                className="w-full min-w-0 flex-1 bg-transparent outline-none placeholder:text-placeholder"
                {...register("color")}
              />
            </div>
          </Field>
          <Field label="Status">
            <Controller
              control={control}
              name="active"
              render={({ field }) => (
                <label className="flex h-10 items-center gap-2 text-[13px] font-medium">
                  <Switch
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                  {field.value ? "Active" : "Inactive"}
                </label>
              )}
            />
          </Field>
        </div>
        <Field
          label="Payment rules"
          htmlFor={id + "issuer"}
          hint={issuers[issuer].rule}
        >
          <Controller
            control={control}
            name="issuer"
            render={({ field }) => (
              <Select
                items={issuerKeys.map(key => ({
                  value: key,
                  label: issuers[key].label,
                }))}
                value={field.value}
                onValueChange={value => {
                  const next = value as Issuer
                  field.onChange(next)
                  // each issuer has its usual autopay offset; it stays editable
                  setValue(
                    "autopay_offset",
                    String(issuers[next].autopayOffset),
                  )
                }}
              >
                <SelectTrigger id={id + "issuer"}>
                  <SelectValue />
                </SelectTrigger>
                <SelectPositioner>
                  <SelectContent>
                    {issuerKeys.map(key => (
                      <SelectItem key={key} value={key}>
                        {issuers[key].label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </SelectPositioner>
              </Select>
            )}
          />
        </Field>
        <div className="grid grid-cols-3 gap-3">
          <Field
            label="Due day"
            htmlFor={id + "due"}
            hint="Day of month"
            error={errors.due_day?.message}
          >
            <Input
              id={id + "due"}
              inputMode="numeric"
              {...register("due_day")}
            />
          </Field>
          <Field
            label="Autopay offset"
            htmlFor={id + "offset"}
            hint="Days before due day"
            error={errors.autopay_offset?.message}
          >
            <Input
              id={id + "offset"}
              inputMode="numeric"
              {...register("autopay_offset")}
            />
          </Field>
          <Field
            label="Target spend"
            htmlFor={id + "target"}
            error={errors.target_spend?.message}
          >
            <div
              className={cn(
                fieldClassName,
                "focus-within:border-accent focus-within:shadow-focus",
              )}
            >
              <span className="text-muted-foreground">$</span>
              <input
                id={id + "target"}
                inputMode="numeric"
                className="w-full min-w-0 flex-1 bg-transparent outline-none"
                {...register("target_spend")}
              />
            </div>
          </Field>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <Field label="Pays from" htmlFor={id + "bank"}>
            <Controller
              control={control}
              name="bank_account_id"
              render={({ field }) => (
                <Select
                  items={[
                    { value: NONE, label: "Not connected" },
                    ...ownBankAccounts.map(b => ({
                      value: b.id,
                      label: b.name,
                    })),
                  ]}
                  value={field.value ?? NONE}
                  onValueChange={value =>
                    field.onChange(value === NONE ? null : value)
                  }
                >
                  <SelectTrigger id={id + "bank"}>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectPositioner>
                    <SelectContent>
                      <SelectItem value={NONE}>Not connected</SelectItem>
                      {ownBankAccounts.map(bankAccount => (
                        <SelectItem key={bankAccount.id} value={bankAccount.id}>
                          {bankAccount.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </SelectPositioner>
                </Select>
              )}
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
                  userId={ownerId}
                  value={field.value}
                  onChange={field.onChange}
                />
              )}
            />
          </Field>
        </div>
        <Field label="Actual ID" htmlFor={id + "actual"}>
          <Input id={id + "actual"} {...register("actual_id")} />
        </Field>
        <button type="submit" className="hidden" />
      </form>
    </Dialog>
  )
}
