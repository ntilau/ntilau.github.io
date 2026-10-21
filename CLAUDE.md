# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`ntilau.github.io` is a GitHub Pages site pairing a root landing page with three independent sub-projects, each in its own subdirectory and served at its own path. There is no shared local build, lint, or test setup at the repository root; every sub-project is self-contained. A single root workflow deploys all of them (see [Deployment](#deployment)).

- `Runinga/` — `Runinga/index.html`: a single-file (~516 lines) HLS streaming TV app with 321 `{name, url}` M3U8 channels (HLS.js from jsDelivr, Safari native fallback). Keyboard, touch/swipe, mouse wheel, and click navigation with an on-screen display; failed streams are dropped automatically. No build step, no tests.
- `Isoko/` — e-commerce site with a Node.js/Express backend in `backend/` and a vanilla-JS frontend; localStorage-based auth and cart. Has its own `Isoko/CLAUDE.md`. `Isoko/README.md` is inherited upstream Alibaba-clone content (different deploy URLs and contributors) and is not a guide to this copy.
- `Ubuni/frontend/` — SvelteKit floor-plan editor (TypeScript strict, Tailwind, Three.js). Has its own `Ubuni/CLAUDE.md`. Commands: `npm run dev/build/preview/check/lint/format`; no test framework.

## Commands

There are no build, lint, or test commands at the repository root. Run each sub-project independently:

**Landing page**
- `python3 -m http.server 8080` from the repository root, then open http://localhost:8080/ — serves `index.html` and both static sub-projects. Ubuni is not reachable at `/Ubuni/` locally even after building (output lands in `Ubuni/frontend/build/`); use its dev server.

**Runinga**
- Open `Runinga/index.html` in a modern browser. Save edits and reload to test; debug with browser dev tools (F12).

**Isoko** — full details in `Isoko/CLAUDE.md`
- Backend: `cd Isoko/backend && npm install && npm run dev` (nodemon, auto-restart) or `npm start`; server defaults to http://localhost:5003.
- Frontend: serve static files, e.g. `python -m http.server 8080` from the repository root, then open http://localhost:8080/Isoko/.
- `Isoko/scripts/update-backend-url.sh`, `update-port-to-5002.sh`, `update-port-to-5003.sh` were written to switch frontend URLs between localhost ports, but currently match nothing because the checked-in URLs are the remote host (see Isoko architecture). Each backs up touched files before editing.

**Ubuni** — from `Ubuni/frontend/`; full details in `Ubuni/CLAUDE.md`
- `npm run dev` — Vite dev server (falls back to the next free port if 5173 is taken; URL printed to stdout)
- `npm run build` — production build via `vite build` (outputs to `build/`)
- `npm run preview` — serve the production build locally for verification
- `npm run check` — `svelte-kit sync && svelte-check` (TypeScript strict)
- `npm run lint` — ESLint; `npm run format` — Prettier

No test framework is configured at root or in any sub-project, so there are no tests to run and no single-test command.

## Architecture

The repository is a loose collection of independent static/web projects under one GitHub Pages domain. Each sub-project owns its HTML, CSS, JavaScript, and (where applicable) backend. There is no shared state, no common component library, and no cross-project build step. The root `index.html` is a dependency-free landing page linking to the three sub-projects; the root workflow is the only piece that knows about all of them.

### Runinga (`Runinga/index.html`)

Single HTML file with three sections:

- **HTML**: `<video id="v">` for playback, `<div id="osd">` for the channel on-screen display.
- **CSS**: fullscreen black background; video fills screen with `object-fit: contain`; semi-transparent OSD at top with fade transition; system font stack.
- **JavaScript**:
  - `channels` array (321 `{name, url}` objects, lines 31-353)
  - `isIOS()` / `isMobile()` device detection
  - `load(i)` — loads channel `i` via HLS.js (`Hls.isSupported()`) or native Safari HLS (`canPlayType`); destroys the prior HLS instance, resets the video element, shows the OSD for 1800ms; on fatal error calls `dropChannel(idx)`
  - `dropChannel(i)` — removes the failed stream, advances to the next working channel; shows "All streams failed" when none remain
  - Navigation: `keydown` (arrows/PageUp/PageDown), `touchstart`+`touchmove` (100px swipe threshold; double-tap on side thirds within a 300 ms window), `wheel` (200px horizontal threshold, 150 ms debounce), `click` (unmute, play, requestFullscreen)
  - iOS: `playsinline` attribute removed so JS can request fullscreen; retained on other platforms
  - Boot: `load(0)` then `v.requestFullscreen()`

### Isoko (`Isoko/`)

Dual data flow across two tracks:

- **Electronics track** (electronics, electronics-subcategory, openproduct, shoppingcart, index, signin, signUp): consumes the backend REST API (currently the remote host below; `Isoko/backend/` is a local equivalent) — `POST /register`, `POST /login`, `GET /users/{token}`, `GET /electronics/{category}` — for authentication and product data.
- **Apparels / car parts track** (apparels, apparel, carpart): static, hardcoded product arrays in the HTML; no backend calls.
- Both tracks share auth/cart via localStorage: `Authorization` (JWT token), `alibabacart` (cart), `openedProduct` / `details_prod` (opened product). Shared ES-module components live in `components/` (`navbar.js`, `footer.js`, `homepagefooter.js`).
- Backend (`backend/server.js`): Express + bcryptjs + jsonwebtoken; users live only in an in-memory `Map` (mongoose is declared in `package.json` but never imported, so data resets on restart); JWT secret `isoko_secret_key_2026` with 1-hour expiry; CORS for all origins; port from `PORT` env (default 5003).
- Backend URL is currently hardcoded to `http://143.47.179.233:5003` in all eight frontend consumers. The `scripts/update-*.sh` helpers only replace `localhost:5000` / `5002` / `5003` (and the old Heroku URL), so as checked in they match nothing and are no-ops until those URLs are restored or edited manually. Each script backs up touched files first under a timestamped `*-backup-*` directory.

Details: `Isoko/CLAUDE.md`. Note that `Isoko/backend/README.md` still claims the default port is 5000 and references the obsolete Heroku backend; `server.js` and the root `CLAUDE.md` are authoritative. The actual `GET /electronics/{category}` handler returns the same mock items for every category.

### Ubuni (`Ubuni/frontend/`)

Client-only SvelteKit floor-plan editor: no backend server, no API routes, no database; all design state lives in browser memory for the session only (not persisted to localStorage or synced to a server).

- `src/lib/store.ts` — single source of truth: writable `design` store (walls, rooms, doors, windows, furniture) plus UI stores (`activeTool`, `viewMode`, `selectedFurniture`, `isDrawing`, `currentPoint`) and derived counts (`wallCount`, `roomCount`, `furnitureCount`).
- `src/lib/types.ts` — domain model: `Design`, `Wall`, `Room`, `Door`, `Window`, `FurnitureItem`, `Point`, `CanvasTool`, `ViewMode`.
- `src/routes/+page.svelte` — app shell: `Toolbar`, sidebar (2D/3D toggle + `FurnitureCatalog`), canvas area, and fixed `DesignExporter`. The canvas swaps `Canvas2D.svelte` (Three.js orthographic, grid, grid-snapping) for `Canvas3D.svelte` (Three.js perspective, lit walls/furniture with shadows) based on `$viewMode`; both rebuild from the `design` store on every change.
- `src/lib/catalog/catalog.ts` — `furnitureLibrary` (10 items); `FurnitureCatalog.svelte` dispatches `itemselect`, which sets `selectedFurniture` and switches the tool to `furniture`.
- `src/lib/export/DesignExporter.svelte` — client-side download of the design as JSON, PDF (jspdf), or SVG; nothing is uploaded.
- Only the `wall` and `furniture` tools are wired to canvas interactions; `select`, `door`, `window`, `room`, `pan` are declared in `CanvasTool` but not wired.

Styling: Tailwind (`tailwind.config.js`, `postcss.config.js`); SvelteKit with `adapter-static` (outputs `build/`, configured in `svelte.config.js`); Vite allows filesystem access to `..`. `+layout.svelte` is just a `<slot>`, `+layout.ts` sets `prerender = true`, and all app state lives in `+page.svelte`.

### Deployment

The root `.github/workflows/deploy.yml` runs on every push to `main`:

1. Installs and builds Ubuni with `npm install` (not `npm ci` — the lockfile is not in sync) and `PAGES_BASE_PATH=/Ubuni`, so SvelteKit emits base-prefixed URLs.
2. Assembles a fresh `site/` directory containing `index.html` (landing page), `Runinga/`, `Isoko/`, and the Ubuni build as `Ubuni/`.
3. Uploads `site/` as the Pages artifact and deploys it.

The Isoko backend is not deployed — Pages serves only its static frontend, which points at the remote backend host noted above. Any root-level file that should be published must be copied into `site/` by the workflow.

## Common Tasks

### Adding a channel to Runinga

1. Open `Runinga/index.html` and locate the `channels` array (starts at line 31).
2. Append a new object: `{name:"Channel Name",url:"https://example.com/stream.m3u8"}`.
3. Save and reload `Runinga/index.html`; the channel is included in navigation automatically.

## Critical Files

- `index.html` — root landing page linking to the three sub-projects
- `.github/workflows/deploy.yml` — builds and publishes the whole site to GitHub Pages
- `Runinga/index.html` — the Runinga streaming app
- `Isoko/CLAUDE.md` — guidance for the Isoko e-commerce sub-project
- `Ubuni/CLAUDE.md` — guidance for the Ubuni floor-plan editor sub-project
- Root `CLAUDE.md` — this file

## Verification

- Open `Runinga/index.html` in a browser; confirm the video loads and left/right arrow keys change channels.
- Serve the repository root (`python3 -m http.server 8080`) and confirm `/`, `/Runinga/`, and `/Isoko/` load. For Ubuni, run `npm run dev` or `npm run preview` from `Ubuni/frontend/`.
- Confirm `Isoko/CLAUDE.md` and `Ubuni/CLAUDE.md` exist at their paths.
- After editing, re-read this file to confirm no stale line numbers or paths remain.
