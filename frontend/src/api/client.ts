export class ApiError extends Error {
  status: number

  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

async function errorMessage(response: Response): Promise<string> {
  const text = await response.text().catch(() => "")
  try {
    const body: unknown = JSON.parse(text)
    if (body && typeof body === "object" && "detail" in body) {
      const detail = body.detail
      return typeof detail === "string" ? detail : JSON.stringify(detail)
    }
  } catch {
    // not JSON
  }
  return text || response.statusText
}

type Params = Record<string, string | number | boolean | null | undefined>

function withParams(path: string, params?: Params): string {
  if (!params) return path
  const search = new URLSearchParams()
  for (const [key, value] of Object.entries(params)) {
    if (value != null) search.set(key, String(value))
  }
  const query = search.toString()
  return query ? `${path}?${query}` : path
}

type RequestOptions = {
  params?: Params
  json?: unknown
  body?: BodyInit
  signal?: AbortSignal
}

async function request<T>(
  method: string,
  path: string,
  { params, json, body, signal }: RequestOptions = {},
): Promise<T> {
  const response = await fetch(withParams(path, params), {
    method,
    signal,
    headers:
      json !== undefined ? { "Content-Type": "application/json" } : undefined,
    body: json !== undefined ? JSON.stringify(json) : body,
  })

  if (!response.ok) {
    throw new ApiError(response.status, await errorMessage(response))
  }
  if (response.status === 204) return undefined as T
  return (await response.json()) as T
}

export const api = {
  get: <T>(path: string, params?: Params, signal?: AbortSignal) =>
    request<T>("GET", path, { params, signal }),
  post: <T = void>(path: string, options?: RequestOptions) =>
    request<T>("POST", path, options),
  put: <T = void>(path: string, options?: RequestOptions) =>
    request<T>("PUT", path, options),
  delete: <T = void>(path: string, options?: RequestOptions) =>
    request<T>("DELETE", path, options),
}

export function describeError(error: unknown): string {
  return error instanceof Error ? error.message : "Please try again."
}
