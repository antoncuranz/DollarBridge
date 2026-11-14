import { create } from "zustand"
import { api, describeError } from "@/api/client"
import { draftAmountsFromRows, matchedRows, needsReview } from "@/lib/derive"
import type {
  StatementMatchResponse,
  StatementMatchResult,
  TransactionAmountMap,
} from "@/types"

export type StatementTab = {
  id: string
  accountId: number
  fileName: string
  status: "loading" | "ready" | "saved" | "error"
  error?: string
  rows: Array<StatementMatchResult>
  /** EUR amounts that will be saved, by transaction id */
  amounts: TransactionAmountMap
  /** uncertain matches the user confirmed */
  accepted: Array<number>
  /** matches the user does not want to save */
  skipped: Array<number>
}

type State = {
  tabs: Array<StatementTab>
  activeId: string | null
  setActive: (id: string) => void
  upload: (accountId: number, file: File) => void
  close: (id: string) => void
  update: (id: string, change: (tab: StatementTab) => StatementTab) => void
}

const controllers = new Map<string, AbortController>()
let counter = 0

/** Statement uploads and their review state; kept while the app is open. */
export const useStatements = create<State>()((set, get) => ({
  tabs: [],
  activeId: null,
  setActive: activeId => set({ activeId }),

  update: (id, change) =>
    set(state => ({
      tabs: state.tabs.map(tab => (tab.id === id ? change(tab) : tab)),
    })),

  close: id => {
    controllers.get(id)?.abort()
    controllers.delete(id)
    set(state => {
      const index = state.tabs.findIndex(tab => tab.id === id)
      const tabs = state.tabs.filter(tab => tab.id !== id)
      const next = tabs[index] ?? tabs[index - 1] ?? null
      return {
        tabs,
        activeId: state.activeId === id ? (next?.id ?? null) : state.activeId,
      }
    })
  },

  upload: (accountId, file) => {
    counter += 1
    const id = `${accountId}-${counter}`
    const controller = new AbortController()
    controllers.set(id, controller)

    set(state => ({
      tabs: [
        ...state.tabs,
        {
          id,
          accountId,
          fileName: file.name,
          status: "loading",
          rows: [],
          amounts: {},
          accepted: [],
          skipped: [],
        },
      ],
      activeId: id,
    }))

    const body = new FormData()
    body.append("file", file)

    api
      .post<StatementMatchResponse>(`/api/statement-match/${accountId}`, {
        body,
        signal: controller.signal,
      })
      .then(response => {
        const rows = matchedRows(response.results)
        get().update(id, tab => ({
          ...tab,
          status: "ready",
          rows,
          amounts: draftAmountsFromRows(rows),
        }))
      })
      .catch((error: unknown) => {
        if (error instanceof Error && error.name === "AbortError") return
        get().update(id, tab => ({
          ...tab,
          status: "error",
          error: describeError(error),
        }))
      })
      .finally(() => controllers.delete(id))
  },
}))

export type ReviewGroups = {
  review: Array<StatementMatchResult>
  ready: Array<StatementMatchResult>
  skipped: Array<StatementMatchResult>
}

export function reviewGroups(tab: StatementTab): ReviewGroups {
  const groups: ReviewGroups = { review: [], ready: [], skipped: [] }
  for (const row of tab.rows) {
    const id = row.transaction_id
    if (tab.skipped.includes(id)) groups.skipped.push(row)
    else if (!tab.accepted.includes(id) && needsReview(row, tab.amounts[id])) {
      groups.review.push(row)
    } else groups.ready.push(row)
  }
  return groups
}

/** the amounts of confident or accepted matches */
export function amountsToSave(tab: StatementTab): TransactionAmountMap {
  const result: TransactionAmountMap = {}
  for (const row of reviewGroups(tab).ready) {
    const amount = tab.amounts[row.transaction_id]
    if (amount != null) result[row.transaction_id] = amount
  }
  return result
}
