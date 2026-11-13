import { Switch as SwitchPrimitive } from "@base-ui/react/switch"

import { cn } from "@/lib/utils"

function Switch({ className, ...props }: SwitchPrimitive.Root.Props) {
  return (
    <SwitchPrimitive.Root
      data-slot="switch"
      className={cn(
        "inline-flex h-5 w-9 shrink-0 items-center rounded-full bg-border px-0.5 outline-none transition-colors",
        "data-[checked]:bg-primary focus-visible:shadow-focus disabled:cursor-not-allowed disabled:opacity-50",
        className,
      )}
      {...props}
    >
      <SwitchPrimitive.Thumb
        data-slot="switch-thumb"
        className="pointer-events-none block size-4 rounded-full bg-white transition-transform data-[checked]:translate-x-4 dark:data-[checked]:bg-primary-foreground"
      />
    </SwitchPrimitive.Root>
  )
}

export { Switch }
