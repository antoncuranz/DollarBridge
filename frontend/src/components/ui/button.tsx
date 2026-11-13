import { Button as ButtonPrimitive } from "@base-ui/react/button"
import { cva } from "class-variance-authority"
import { cn } from "@/lib/utils"
import type { VariantProps } from "class-variance-authority"


const buttonVariants = cva(
  cn(
    "inline-flex shrink-0 items-center justify-center gap-1.5 whitespace-nowrap text-sm font-medium outline-none select-none",
    "transition-all active:scale-[0.98] focus-visible:shadow-focus focus-visible:border-accent",
    "disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0",
  ),
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground hover:bg-primary-hover border border-transparent",
        secondary:
          "bg-card text-foreground border shadow-row hover:bg-secondary-hover",
        ghost: "text-muted-foreground hover:bg-muted hover:text-foreground",
        accent:
          "bg-accent text-accent-foreground hover:opacity-90 border border-transparent",
        destructive:
          "bg-card text-destructive border shadow-row hover:bg-secondary-hover",
      },
      size: {
        default: "h-9 rounded-row px-3.5 [&_svg:not([class*='size-'])]:size-4",
        sm: "h-7 rounded-field px-2.5 text-[13px] [&_svg:not([class*='size-'])]:size-3.5",
        lg: "h-10 rounded-[14px] px-4 [&_svg:not([class*='size-'])]:size-4",
        icon: "size-10 rounded-full [&_svg:not([class*='size-'])]:size-5",
        "icon-tile":
          "size-10 rounded-[14px] [&_svg:not([class*='size-'])]:size-5",
        "icon-sm": "size-8 rounded-full [&_svg:not([class*='size-'])]:size-4",
        "icon-xs":
          "h-7 rounded-field px-1.5 [&_svg:not([class*='size-'])]:size-4",
        fab: "size-12 rounded-full !shadow-lg [&_svg:not([class*='size-'])]:size-6",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  },
)

function Button({
  className,
  variant = "default",
  size = "default",
  ref,
  ...props
}: ButtonPrimitive.Props &
  VariantProps<typeof buttonVariants> &
  React.RefAttributes<HTMLElement>) {
  return (
    <ButtonPrimitive
      data-slot="button"
      className={cn(buttonVariants({ variant, size, className }))}
      ref={ref}
      {...props}
    />
  )
}

export { Button, buttonVariants }
