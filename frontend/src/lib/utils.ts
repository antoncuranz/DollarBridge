import { clsx } from "clsx"
import { twMerge } from "tailwind-merge"
import type { ClassValue } from "clsx"

export function cn(...inputs: Array<ClassValue>) {
  return twMerge(clsx(inputs))
}

/** "faye" → "Faye’s " — prefix for things that belong to another user */
export function possessive(name: string): string {
  return name.charAt(0).toUpperCase() + name.slice(1) + "’s "
}
