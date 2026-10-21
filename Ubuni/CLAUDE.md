# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands run from the `frontend/` directory.

- `npm run dev` — Vite dev server (SvelteKit); falls back to the next free port if 5173 is taken.
- `npm run build` — production static build via `vite build` (outputs to `build/`).
- `npm run preview` — serve the production build at `/` for local verification. It does not reproduce the `/Ubuni/` base path; use a static server over a copied build to test that (see Deployment).
- `npm run check` — `svelte-kit sync && svelte-check` (TypeScript strict).
- `npm test` — run the Vitest suite once.
- `npm run test:watch` — Vitest in watch mode.
- `npx vitest run src/lib/geometry.test.ts` — run one test file; add `-t "snapping"` to filter by test name.
- `npm run format` — Prettier (includes `prettier-plugin-svelte`).

## Architecture

A client-only SvelteKit floor-plan editor (ubuni.app). There is no backend, no API routes, and no database. SvelteKit uses `adapter-static` with `prerender = true`; everything runs in the browser. Design state autosaves to `localStorage` but is never uploaded.

**Model units are meters everywhere** — geometry, store, both canvases, and the shared plan. Furniture catalog sizes are authored in centimeters and divided by 100 at the source. The inspector shows centimeters. Defaults: wall thickness `0.15 m`, snap step `0.1 m`, door width `0.9 m`, window width `1.2 m`. 2D displays at pixels-per-meter; 3D uses 1 unit = 1 m; SVG uses 100 units/m; PDF works in millimeters.

### State and history

`src/lib/store.ts` is the single source of truth:

- `design` (the domain model from `src/lib/types.ts`) plus UI stores: `activeTool`, `viewMode`, `selection`, `placementItem`, `snapEnabled`, `zoom2D`, `cursorWorld`, `statusMessage`, `sidebarOpen`.
- `mutate(updater, { history })` is the only mutation path. It applies an immutable update, stamps `updatedAt`, pushes undo history, prunes a selection whose entity disappeared, and notifies subscribers. New edits clear redo.
- `beginTransaction()` / `endTransaction()` coalesce a drag into one undo step. History is capped at 100 snapshots.
- `undo`, `redo`, `deleteSelection` (cascades wall deletion to its doors/windows), `rotateSelection`, `nudgeSelection`, `newDesign`, `replaceDesign`, `requestFit`.
- `activeTool` is `select | wall | room | door | window | furniture | pan`.

`src/lib/persistence.ts` validates and normalizes a design on load, stores it under `ubuni:design:v1`, and exposes `startAutosave()` (400 ms debounce). Storage access is guarded so prerendering never touches `localStorage`. `+page.svelte` loads the saved design and starts autosave in `onMount`. JSON imports accept either a bare design or the `{ schemaVersion, exportedAt, design }` envelope.

### Geometry and plan

`src/lib/geometry.ts` holds pure math: snapping, point/segment projection, opening clamping, opening-aware wall segmentation, polygon area/centroid/containment, rotated furniture corners, and design bounds.

`src/lib/plan.ts` normalizes a design once for exporters: padded bounds, solid wall segments with door/window gaps, opening leaf/arc geometry, room/furniture primitives. Both export paths consume it, so exporting cannot disagree with the canvases. The 2D and 3D canvases use the same geometry helpers directly.

### Views

- `src/lib/canvas/Canvas2D.svelte` — Three.js orthographic top-down editor. Groups: grid, rooms, walls, openings, furniture, handles, preview. All edits rebuild from `design` + `selection`. Pointer handling covers pan (middle mouse, Space, Pan tool), wheel zoom anchored at the cursor, handle picking, drag (furniture, wall endpoints, room vertices, openings), tool placement, and ghost previews. `ResizeObserver` keeps the renderer matched to the pane; geometry/materials and subscriptions are disposed on unmount.
- `src/lib/canvas/Canvas3D.svelte` — Three.js perspective view with `OrbitControls`, shadows, opening-aware wall boxes, door panels, window glass, room floors, furniture heights, and a selection `BoxHelper`. A click (pointer movement under 5 px) raycasts and updates the shared selection; an orbit drag does not select.
- Both read the same `design`/`selection` stores, so switching views preserves the design and selection.

`src/lib/editorKeys.ts` handles global shortcuts while the 2D canvas is mounted: `V W M D N F H` tools, `R`/`Shift+R` rotate ±15°, arrows nudge 0.1 m (Shift 0.5 m), `Delete`/`Backspace`, `Escape`, `Cmd/Ctrl+Z`, `Cmd/Ctrl+Shift+Z` or `Ctrl+Y`, `G` snap, `0` fit. Editable targets are ignored. In 3D, use toolbar Undo/Redo and the inspector.

### UI shell

`src/routes/+page.svelte` composes `Toolbar`, the sidebar (`FurnitureCatalog` + `Inspector`), the active canvas, `DesignExporter`, and `StatusBar`. Below `md` the sidebar is a drawer with a backdrop; it closes when crossing below the breakpoint and starts closed on mobile. Toolbar owns the editable design name, tools, undo/redo, snap, Fit, 2D/3D, New, and the mobile sidebar toggle. Inspector edits the selected entity's properties; StatusBar shows the tool hint, cursor in meters, counts, snap, and zoom.

### Export and import

`src/lib/export/DesignExporter.svelte` provides JSON import plus JSON, SVG, and PDF downloads. SVG and PDF are vector plans generated from `plan.ts`; PDF uses a dynamic import of jsPDF. Downloads use Blob object URLs (`download.ts`); nothing is uploaded.

### Styling / config

Svelte 4 idioms (`writable`, `$store`, `on:click`, `<slot>`), SvelteKit with `adapter-static`, TypeScript strict, Tailwind (`tailwind.config.js`, `postcss.config.js`), Three.js 0.160. `src/app.css` is imported by `+layout.svelte` and defines the base page styles. `svelte.config.js` sets `kit.paths.base` from `PAGES_BASE_PATH`; the Pages workflow builds with `PAGES_BASE_PATH=/Ubuni`.

### Tests

Vitest (`vitest.config.ts`, node environment, `$lib` alias) covers pure modules only — no Svelte or Three imports:

- `src/lib/geometry.test.ts` — snapping, projection, opening intervals/splitting/merging, clamping, resizing openings, polygons, bounds.
- `src/lib/store.test.ts` — undo/redo, redo clearing, transaction coalescing, history cap, selection pruning, cascade delete.
- `src/lib/export.test.ts` — plan door gaps, SVG validity/escaping, JSON import/export round-trip, PDF page fitting.

Run `npm test` alongside `npm run check` and `npm run build` after changes.

### Local permissions

`.claude/settings.local.json` pre-approves `npm run`, `pkill -f "vite dev"`, `curl`, `npm install`, `npx svelte-kit`, and `npm create`.
