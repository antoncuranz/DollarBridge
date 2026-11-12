import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"
import { EurField } from "./EurField"

function setup(value: number | null, onChange = vi.fn()) {
  render(
    <>
      <EurField
        label="first"
        value={value}
        estimate={5731}
        onChange={onChange}
      />
      <EurField label="saved" value={4482} onChange={vi.fn()} />
      <EurField label="empty" value={null} onChange={vi.fn()} />
    </>,
  )
  return { onChange, user: userEvent.setup() }
}

describe("EurField", () => {
  it("shows the estimate as placeholder and the value formatted", () => {
    setup(null)
    expect(screen.getByLabelText("first")).toHaveAttribute(
      "placeholder",
      "57,31",
    )
    expect(screen.getByLabelText("saved")).toHaveValue("44,82")
  })

  it("commits the parsed amount when leaving the field", async () => {
    const { onChange, user } = setup(null)
    await user.click(screen.getByLabelText("first"))
    await user.keyboard("57.4")
    await user.keyboard("{Enter}")
    expect(onChange).toHaveBeenCalledWith(5740)
  })

  it("clears the amount when emptied and ignores unchanged input", async () => {
    const { onChange, user } = setup(4482)
    const field = screen.getByLabelText("first")
    await user.click(field)
    await user.keyboard("{Enter}")
    expect(onChange).not.toHaveBeenCalled()
    await user.clear(field)
    await user.keyboard("{Enter}")
    expect(onChange).toHaveBeenCalledWith(null)
  })

  it("moves with Tab to the next field without an amount", async () => {
    const { user } = setup(null)
    await user.click(screen.getByLabelText("first"))
    await user.keyboard("1")
    await user.tab()
    expect(screen.getByLabelText("empty")).toHaveFocus()
  })
})
