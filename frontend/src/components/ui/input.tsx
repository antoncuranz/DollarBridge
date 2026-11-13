import { Input as InputPrimitive } from "@base-ui/react/input"
import * as React from "react"

import { cn } from "@/lib/utils"

export const fieldClassName =
  "flex h-10 w-full items-center gap-2 rounded-[14px] border bg-card px-3 text-sm text-foreground shadow-[0_2px_2px_0_rgb(0_0_0/0.04)] outline-none transition-all placeholder:text-placeholder focus-visible:border-accent focus-visible:shadow-focus disabled:opacity-50 aria-invalid:border-destructive"

function Input({
  className,
  type,
  ...props
}: React.ComponentProps<typeof InputPrimitive>) {
  return (
    <InputPrimitive
      type={type}
      data-slot="input"
      className={cn(fieldClassName, className)}
      {...props}
    />
  )
}

export { Input }
