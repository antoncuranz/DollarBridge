# Frontend

Static single-page app: Vite, React, TanStack Router (file-based routes in
`src/routes`) and TanStack Query. There is no Node server; the browser calls the
FastAPI backend under `/api`.

## Run locally

```sh
# backend on :8000, e.g. against the local database from clone_db.sh
cd backend && POSTGRES_PORT=5433 POSTGRES_DATABASE=postgres OVERWRITE_USER_HEADER=<user> fastapi dev main.py

cd frontend && npm ci && npm run dev   # http://localhost:3000, proxies /api to :8000
```

`BACKEND_URL` changes the proxy target of the dev server.

| Command | What it does |
|---|---|
| `npm run lint` | oxlint (type-aware) |
| `npm run fix` | oxfmt, then lint auto-fixes |
| `npm run typecheck` | `tsgo --noEmit` |
| `npm test` | Vitest (jsdom, Testing Library) |
| `npm run build` | production build to `dist/`, then type check |

## Deployment

`frontend/Dockerfile` builds the app and serves it with unprivileged nginx on
port 3000 (`nginx.conf.template`). nginx proxies `/api` to `BACKEND_URL` and
passes request headers on unchanged, so the backend still identifies the user
by the headers oauth2-proxy adds. Unknown paths fall back to `index.html`.

## Structure

| Path | Content |
|---|---|
| `src/api` | fetch client, query definitions (`queries.ts`), mutations with toasts and cache invalidation (`mutations.ts`) |
| `src/lib` | pure logic: amounts in cents (`money.ts`), dates, derived values such as remainders and deviations (`derive.ts`) |
| `src/store.ts` | client-only state: unsaved EUR amounts, apply-credit / apply-exchange mode, preferences kept per device |
| `src/components/ui` | primitives on Base UI |
| `src/components/shell` | header with tabs, `Workspace` (sidebar and list pane), `SaveBar` |
| `src/components/list` | `Row`, `EurField`, `GroupSeparator`, row context menu |
| `src/components/sidebar` | due calendar, account filter, stat tiles |
| `src/components/dialog` | dialogs and their form fields |
| `src/styles.css` | design tokens for light and dark, taken from the Figma "Concept v2" variables |

Conventions:

- Amounts are integer cents everywhere. EUR fields and row columns use `39,68`;
  USD and headline totals use `1,274.50`.
- Server state lives in TanStack Query only. A mutation names the query keys it
  invalidates; nothing reloads the whole page.
- The account filter and the archive month are URL search params.
- Desktop and mobile share components. `Workspace` shows the sidebar from the
  `md` breakpoint and the `mobileTop` content below it.
