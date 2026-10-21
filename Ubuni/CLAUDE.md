# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

All commands run from the `frontend/` directory unless noted.

- `npm run dev` — start the Vite dev server (SvelteKit). Falls back to the next free port if 5173 is in use; the local URL is printed to stdout.
- `npm run build` — production build via `vite build` (outputs to `build/`).
- `npm run preview` — serve the production build locally for verification.
- `npm run check` — type-check with `svelte-kit sync && svelte-check`.
- `npm run format` — run Prettier.

There is no test framework configured (no Vitest/Jest), so there are no tests to run and no single-test command. If you add tests, wire them into `check`.

## Architecture

`frontend/` is a client-only SvelteKit floor-plan editor (ubuni.app). There is no backend server, no API routes, and no database — all state lives in memory in the browser.

### State
- `src/lib/store.ts` holds the single source of truth: a writable `design` store (walls, rooms, doors, windows, furniture) plus UI stores (`activeTool`, `viewMode`, `selectedFurniture`, `isDrawing`, `currentPoint`). Designs are not persisted to localStorage or synced to a server; they exist only for the session.
- `src/lib/types.ts` defines the domain model: `Design`, `Wall`, `Room`, `Door`, `Window`, `FurnitureItem`, `Point`, `CanvasTool`, `ViewMode`.

### Views
- `src/routes/+page.svelte` is the app shell: top `Toolbar`, left sidebar (`viewMode` 2D/3D toggle + `FurnitureCatalog`), the canvas area, and the fixed `DesignExporter`. `+layout.svelte` is just a slot and `+layout.ts` enables prerendering.
- The canvas swaps between `Canvas2D.svelte` (Three.js orthographic camera, grid, wall drawing with grid-snapping, furniture placement) and `Canvas3D.svelte` (Three.js perspective camera, lit walls/furniture with shadows). Both re-render by subscribing to the `design` store and rebuilding Three.js meshes on every change.
- `src/lib/canvas/Canvas2D.svelte` implements the interactive tools: clicking places furniture or starts/completes a wall (click-click to define start/end). Only `wall` and `furniture` have mouse handling; `select` is the reset/default state. `CanvasTool` contains just these three values.

### Furniture
- `src/lib/catalog/catalog.ts` defines `furnitureLibrary` (10 items with id, name, category, size). `FurnitureCatalog.svelte` renders it and dispatches `itemselect`, which sets `selectedFurniture` and switches the tool to `furniture`.

### Export
- `src/lib/export/DesignExporter.svelte` offers client-side download of the current design as JSON, PDF (via `jspdf`), and SVG. Nothing is uploaded.

### Styling / config
- Tailwind CSS (`tailwind.config.js`, `postcss.config.js`). SvelteKit with `adapter-static` (outputs `build/`). TypeScript in `strict` mode. Vite config allows filesystem access to `..` (`vite.config.js` `fs.allow`).

### Local permissions
- `.claude/settings.local.json` pre-approves `npm run`, `pkill -f "vite dev"`, `curl`, `npm install`, `npx svelte-kit`, and `npm create`.
