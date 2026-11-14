import { Link, useLocation } from "@tanstack/react-router"
import { Moon, Sun } from "lucide-react"
import { useEffect, useRef } from "react"
import { useTheme } from "@/components/provider/ThemeProvider"
import { Button } from "@/components/ui/button"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuPositioner,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { usePreferences } from "@/store"

const tabs = [
  { to: "/", label: "Transactions" },
  { to: "/exchanges", label: "Exchanges" },
  { to: "/archive", label: "Archive" },
  { to: "/statements", label: "Statements" },
  { to: "/accounts", label: "Accounts" },
] as const

function isDark(theme: string): boolean {
  if (theme === "system") {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
  }
  return theme === "dark"
}

function HeaderActions() {
  const { theme, setTheme } = useTheme()
  const { privacyMode, togglePrivacyMode } = usePreferences()

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          <Button
            variant="secondary"
            size="icon"
            aria-label="Appearance and privacy"
          />
        }
      >
        {isDark(theme) ? <Moon /> : <Sun />}
      </DropdownMenuTrigger>
      <DropdownMenuPositioner align="end">
        <DropdownMenuContent>
          <DropdownMenuRadioGroup
            value={theme}
            onValueChange={value => setTheme(value as typeof theme)}
          >
            <DropdownMenuRadioItem value="light">Light</DropdownMenuRadioItem>
            <DropdownMenuRadioItem value="dark">Dark</DropdownMenuRadioItem>
            <DropdownMenuRadioItem value="system">System</DropdownMenuRadioItem>
          </DropdownMenuRadioGroup>
          <DropdownMenuSeparator />
          <DropdownMenuCheckboxItem
            checked={privacyMode}
            onCheckedChange={togglePrivacyMode}
          >
            Privacy
          </DropdownMenuCheckboxItem>
        </DropdownMenuContent>
      </DropdownMenuPositioner>
    </DropdownMenu>
  )
}

export function Header() {
  const nav = useRef<HTMLElement>(null)
  const pathname = useLocation({ select: location => location.pathname })

  // on mobile the tabs scroll sideways: keep the current one in view
  useEffect(() => {
    nav.current
      ?.querySelector('[data-status="active"]')
      ?.scrollIntoView({ inline: "center", block: "nearest" })
  }, [pathname])

  return (
    <header className="flex h-22 shrink-0 flex-col border-b bg-background pt-2 shadow-sm md:h-14 md:flex-row md:items-center md:gap-2 md:border-b-0 md:bg-transparent md:pt-0 md:shadow-none">
      <div className="flex items-center gap-2 pr-3 pl-5 md:contents">
        <h1 className="flex-1 truncate text-2xl leading-10 font-semibold md:flex-none">
          Dollar Bridge
        </h1>
        <div className="md:order-last">
          <HeaderActions />
        </div>
      </div>
      <nav
        ref={nav}
        className="no-scrollbar flex flex-1 items-center gap-6 overflow-x-auto pr-10 pl-5 md:h-14 md:pl-6 lg:gap-8"
        style={{
          maskImage:
            "linear-gradient(to right, transparent .0em, black 1em calc(100% - 3em), transparent calc(100% - .0em))",
        }}
      >
        {tabs.map(tab => (
          <Link
            key={tab.to}
            to={tab.to}
            className="block h-full shrink-0 border-b-3 border-transparent text-base leading-9 whitespace-nowrap text-muted-foreground transition-colors hover:text-foreground md:h-14 md:leading-14"
            activeProps={{
              className: "!border-accent !text-foreground",
            }}
            activeOptions={{ exact: tab.to === "/", includeSearch: false }}
          >
            {tab.label}
          </Link>
        ))}
      </nav>
    </header>
  )
}
