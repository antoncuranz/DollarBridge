import { beforeEach, describe, expect, it } from "vitest"
import { useStore } from "./store"

describe("clearSavedDrafts", () => {
  beforeEach(() => useStore.getState().clearDrafts())

  it("keeps drafts typed while the save was running", () => {
    const { setDraft } = useStore.getState()
    setDraft(1, 1000)
    setDraft(2, 2000)
    const sent = { ...useStore.getState().drafts }

    // edited during the save: a new draft and a changed one
    setDraft(3, 3000)
    setDraft(2, 2500)

    useStore.getState().clearSavedDrafts(sent)
    expect(useStore.getState().drafts).toEqual({ 2: 2500, 3: 3000 })
  })

  it("clears a saved empty amount", () => {
    useStore.getState().setDraft(1, null)
    useStore.getState().clearSavedDrafts({ 1: null })
    expect(useStore.getState().drafts).toEqual({})
  })
})
