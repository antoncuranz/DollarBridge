import { describe, expect, it } from "vitest"
import {
  formatAmount,
  formatEur,
  formatSigned,
  formatUsd,
  parseAmount,
} from "./money"

describe("formatAmount", () => {
  it("formats cents with a decimal comma", () => {
    expect(formatAmount(12345)).toBe("123,45")
    expect(formatAmount(5)).toBe("0,05")
    expect(formatAmount(-250)).toBe("-2,50")
    expect(formatAmount(null)).toBe("")
  })

  it("supports whole numbers and large values", () => {
    expect(formatAmount(1500, 0)).toBe("1500")
    expect(formatAmount(3_000_000_000_00)).toBe("3000000000,00")
  })
})

describe("grouped formats", () => {
  it("groups thousands and uses a decimal point", () => {
    expect(formatUsd(127450)).toBe("$ 1,274.50")
    expect(formatEur(412)).toBe("€ 4.12")
    expect(formatSigned(12)).toBe("+0,12")
    expect(formatSigned(-21)).toBe("−0,21")
  })
})

describe("parseAmount", () => {
  it("accepts comma and point", () => {
    expect(parseAmount("12,34")).toBe(1234)
    expect(parseAmount("12.34")).toBe(1234)
    expect(parseAmount(" 1 234,5 ")).toBe(123450)
    expect(parseAmount("300")).toBe(30000)
    expect(parseAmount(",5")).toBe(50)
    expect(parseAmount("-2,5")).toBe(-250)
  })

  it("cuts off surplus decimals", () => {
    expect(parseAmount("1,239")).toBe(123)
  })

  it("distinguishes empty from invalid", () => {
    expect(parseAmount("")).toBeNull()
    expect(parseAmount("  ")).toBeNull()
    expect(parseAmount("abc")).toBeUndefined()
    expect(parseAmount(",")).toBeUndefined()
    expect(parseAmount("1,2,3")).toBeUndefined()
  })

  it("parses rates with seven decimals", () => {
    expect(parseAmount("1.082", 7)).toBe(10820000)
  })
})
