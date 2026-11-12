import { create } from "zustand"
import { persist } from "zustand/middleware"
import type { TransactionAmountMap } from "@/types"

type State = {
  /** unsaved EUR amounts on the Transactions page, by transaction id */
  drafts: TransactionAmountMap
  setDraft: (id: number, amount: number | null) => void
  clearDraft: (id: number) => void
  clearDrafts: () => void

  /** credit that is being applied to transactions ("apply mode") */
  creditSelection: number | null
  setCreditSelection: (creditId: number | null) => void

  /** exchange that is being applied to payments */
  exchangeSelection: number | null
  setExchangeSelection: (exchangeId: number | null) => void

  missingEurOnly: boolean
  setMissingEurOnly: (enabled: boolean) => void
}

export const useStore = create<State>()(set => ({
  drafts: {},
  setDraft: (id, amount) =>
    set(state => ({ drafts: { ...state.drafts, [id]: amount } })),
  clearDraft: id =>
    set(state => {
      const { [id]: _removed, ...drafts } = state.drafts
      return { drafts }
    }),
  clearDrafts: () => set({ drafts: {} }),

  creditSelection: null,
  setCreditSelection: creditSelection => set({ creditSelection }),

  exchangeSelection: null,
  setExchangeSelection: exchangeSelection => set({ exchangeSelection }),

  missingEurOnly: false,
  setMissingEurOnly: missingEurOnly => set({ missingEurOnly }),
}))

type Preferences = {
  privacyMode: boolean
  togglePrivacyMode: () => void
  /** mobile due calendar: full month instead of the week strip */
  calendarExpanded: boolean
  setCalendarExpanded: (expanded: boolean) => void
}

/** remembered per device */
export const usePreferences = create<Preferences>()(
  persist(
    set => ({
      privacyMode: false,
      togglePrivacyMode: () =>
        set(state => ({ privacyMode: !state.privacyMode })),
      calendarExpanded: false,
      setCalendarExpanded: calendarExpanded => set({ calendarExpanded }),
    }),
    { name: "money-tracking-preferences" },
  ),
)
