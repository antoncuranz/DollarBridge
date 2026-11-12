import { Link, useLocation } from "@tanstack/react-router"
import { Eye, EyeOff, Moon, Sun } from "lucide-react"

import { useEffect, useRef } from "react"

import { useTheme } from "@/components/provider/ThemeProvider"
import { Button } from "@/components/ui/button"
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
  const dark = isDark(theme)

  return (
    <div className="flex shrink-0 items-center gap-2">
      <Button
        variant="secondary"
        size="icon"
        className="max-md:size-11"
        aria-label={privacyMode ? "Show amounts" : "Hide amounts"}
        aria-pressed={privacyMode}
        onClick={togglePrivacyMode}
      >
        {privacyMode ? <EyeOff /> : <Eye />}
      </Button>
      <Button
        variant="secondary"
        size="icon"
        className="max-md:size-11"
        aria-label={dark ? "Switch to light theme" : "Switch to dark theme"}
        onClick={() => setTheme(dark ? "light" : "dark")}
      >
        {dark ? <Moon /> : <Sun />}
      </Button>
    </div>
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
    <header className="flex shrink-0 flex-col gap-1.5 border-b bg-background pt-[max(env(safe-area-inset-top),0.75rem)] md:h-14 md:flex-row md:items-center md:gap-3.5 md:border-b-0 md:bg-transparent md:pt-0">
      <div className="flex items-center gap-3 pr-4 pl-6 md:contents">
        <h1 className="flex-1 text-[28px] leading-10 font-semibold whitespace-nowrap md:flex-none md:text-2xl md:leading-[34px]">
          money tracking
        </h1>
        <div className="md:order-last">
          <HeaderActions />
        </div>
      </div>
      <nav
        ref={nav}
        className="no-scrollbar flex gap-7 overflow-x-auto pl-6 md:h-14 md:flex-1 md:gap-5 md:pl-3"
      >
        {tabs.map(tab => (
          <Link
            key={tab.to}
            to={tab.to}
            className="flex shrink-0 items-center border-b-3 border-transparent pt-1 pb-2 text-lg leading-[26px] whitespace-nowrap text-muted-foreground transition-colors hover:text-foreground md:h-14 md:border-b-2 md:py-0 md:text-base md:leading-[23px]"
            activeProps={{
              className: "!border-accent !text-foreground md:font-medium",
            }}
            activeOptions={{ exact: tab.to === "/", includeSearch: false }}
          >
            {tab.label}
          </Link>
        ))}
        <span className="w-2 shrink-0 md:hidden" />
      </nav>
    </header>
  )
}
