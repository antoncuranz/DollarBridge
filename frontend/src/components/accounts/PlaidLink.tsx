import { useQueryClient } from "@tanstack/react-query"
import { useEffect, useRef, useState } from "react"
import { usePlaidLink } from "react-plaid-link"
import { toast } from "sonner"
import { api, describeError } from "@/api/client"
import { keys } from "@/api/queries"

/**
 * Opens Plaid Link as soon as it is mounted: for a new connection, or in
 * update mode to repair an existing one (`updateId`).
 */
export function PlaidLink({
  updateId,
  onDone,
}: {
  updateId?: number
  onDone: () => void
}) {
  const queryClient = useQueryClient()
  const [token, setToken] = useState<string | null>(null)
  const opened = useRef(false)

  useEffect(() => {
    let cancelled = false
    api
      .post<{ link_token: string }>("/api/import/plaid/create_link_token", {
        params: { update_id: updateId },
      })
      .then(data => {
        if (!cancelled) setToken(data.link_token)
      })
      .catch((error: unknown) => {
        if (cancelled) return
        toast.error("Could not start Plaid", {
          description: describeError(error),
        })
        onDone()
      })
    return () => {
      cancelled = true
    }
  }, [updateId])

  const { open, ready } = usePlaidLink({
    token,
    onExit: onDone,
    onSuccess: publicToken => {
      const finish = async () => {
        try {
          // repairing a connection needs no token exchange
          if (updateId == null) {
            await api.post("/api/import/plaid/exchange_token", {
              params: { public_token: publicToken },
            })
          }
          toast.success(
            updateId == null ? "Bank connected" : "Connection repaired",
          )
        } catch (error) {
          toast.error("Could not finish connecting", {
            description: describeError(error),
          })
        }
        await queryClient.invalidateQueries({ queryKey: keys.connections })
        onDone()
      }
      void finish()
    },
  })

  useEffect(() => {
    if (ready && token && !opened.current) {
      opened.current = true
      open()
    }
  }, [ready, token, open])

  return null
}
