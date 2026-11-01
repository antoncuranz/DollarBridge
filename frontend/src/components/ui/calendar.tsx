import * as React from "react"
import { ChevronLeft, ChevronRight } from "lucide-react"
import { DayPicker } from "react-day-picker"

import { cn } from "@/lib/utils"
import { buttonVariants } from "@/components/ui/button"

export type CalendarProps = React.ComponentProps<typeof DayPicker>

function Calendar({
  className,
  classNames,
  showOutsideDays = true,
  ...props
}: CalendarProps) {
  return (
    <DayPicker
      showOutsideDays={showOutsideDays}
      className={cn("p-3", className)}
      classNames={{
        months: "relative flex flex-col items-center gap-4 sm:flex-row",
        month: "flex w-full flex-col gap-4",
        month_caption: "relative flex items-center justify-center pt-1",
        caption_label: "text-sm font-medium",
        nav: "absolute right-0 top-0 z-10 flex items-center gap-1",
        button_previous: cn(
          buttonVariants({ variant: "outline" }),
          "h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100"
        ),
        button_next: cn(
          buttonVariants({ variant: "outline" }),
          "h-7 w-7 bg-transparent p-0 opacity-50 hover:opacity-100"
        ),
        month_grid: "mx-auto block w-auto border-collapse",
        weekdays: "flex w-full justify-center",
        weekday:
          "w-9 shrink-0 rounded-md text-center text-[0.8rem] font-normal text-muted-foreground",
        week: "mt-2 flex w-full justify-center",
        day: cn(
          "relative flex h-9 w-9 shrink-0 items-center justify-center p-0 text-center text-sm focus-within:z-20",
        ),
        day_button: cn(
          "inline-flex h-9 w-9 cursor-pointer items-center justify-center whitespace-nowrap rounded-md p-0 text-sm transition-colors focus-visible:outline-none disabled:pointer-events-none disabled:opacity-50",
          "aria-selected:opacity-100"
        ),
        range_end: "range_end",
        selected:
          "rounded-md bg-primary text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground",
        today: "font-black text-accent-foreground",
        outside:
          "outside text-muted-foreground opacity-50 aria-selected:bg-accent/50 aria-selected:text-muted-foreground aria-selected:opacity-30",
        disabled: "text-muted-foreground opacity-50",
        range_middle:
          "aria-selected:bg-accent aria-selected:text-accent-foreground",
        hidden: "invisible",
        ...classNames,
      }}
      components={{
        Chevron: ({ orientation, ...props }) => orientation === "left"
          ? <ChevronLeft {...props} className={cn("h-4 w-4", props.className)} />
          : <ChevronRight {...props} className={cn("h-4 w-4", props.className)} />,
      }}
      {...props}
    />
  )
}
Calendar.displayName = "Calendar"

export { Calendar }
