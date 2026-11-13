import { createFileRoute, redirect } from "@tanstack/react-router"

/** old address of the Statements page */
export const Route = createFileRoute("/statement-match")({
  beforeLoad: () => {
    throw redirect({ to: "/statements", replace: true })
  },
})
