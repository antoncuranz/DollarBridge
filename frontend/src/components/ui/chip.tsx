import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"
import type { VariantProps } from "class-variance-authority"


const chipVariants = cva(
  "inline-flex h-7 shrink-0 items-center gap-1.5 rounded-full px-2.5 text-[13px] leading-[19px] font-medium whitespace-nowrap",
  {
    variants: {
      state: {
        default: "border bg-card text-foreground",
        active: "bg-primary text-primary-foreground",
        warning: "bg-warning-soft text-warning",
        success: "bg-success-soft text-success",
        accent: "bg-accent-soft text-accent",
      },
    },
    defaultVariants: { state: "default" },
  },
)

function Chip({
  className,
  state,
  ...props
}: React.ComponentProps<"span"> & VariantProps<typeof chipVariants>) {
  return <span className={cn(chipVariants({ state, className }))} {...props} />
}

export { Chip }
