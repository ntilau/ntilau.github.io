# ntilau.github.io

Three self-contained web apps served from one GitHub Pages site.

**Live site:** https://ntilau.github.io/

| Project | Path | What it is |
| --- | --- | --- |
| [Runinga](Runinga/index.html) | `/Runinga/` | Fullscreen HLS television player with 321 channels |
| [Isoko](Isoko/index.html) | `/Isoko/` | E-commerce storefront for electronics, apparel, and car parts |
| [Ubuni](Ubuni/frontend/) | `/Ubuni/` | SvelteKit floor-plan editor with 2D and 3D views |

The root `index.html` is a dependency-free landing page linking to all three.

## Runinga

A single-file streaming app: one HTML file containing markup, styles, the channel list, and all playback logic.

- HLS.js from jsDelivr, with native HLS playback on Safari
- Navigate with arrow keys / Page Up / Page Down, horizontal swipes, the mouse wheel, or double-taps on the left/right thirds of the screen
- Failed streams are dropped automatically and playback advances to the next channel

No build step. Open `Runinga/index.html` directly in a browser, or visit `/Runinga/` on the live site.

## Isoko

An Alibaba-inspired storefront split across two data flows:

- **Electronics** pages fetch products and authenticate against an Express API. The checked-in frontend points at `http://143.47.179.233:5003`.
- **Apparel and car parts** pages are fully static, with product arrays defined in the HTML.

Auth tokens and the cart live in `localStorage` (`Authorization`, `alibabacart`).

A local API equivalent is included in `Isoko/backend/`:

```bash
cd Isoko/backend
npm install
npm run dev        # nodemon, http://localhost:5003
```

It uses an in-memory user store and JWT auth (1-hour expiry); data resets on restart. To exercise the electronics pages locally, replace the hardcoded remote API URL in the frontend files with `http://localhost:5003`.

## Ubuni

A client-only SvelteKit floor-plan editor built with TypeScript, Tailwind, and Three.js.

- 2D canvas with grid snapping, wall drawing, and furniture placement; 3D lit view with shadows
- Furniture catalog with 10 items
- Export the current design as JSON, PDF, or SVG
- All state is in memory for the session — nothing is persisted or uploaded
- No tests are configured; `npm run check` provides TypeScript/Svelte validation

```bash
cd Ubuni/frontend
npm install
npm run dev        # Vite dev server
npm run build      # static build in build/
npm run check      # svelte-check (TypeScript strict)
npm run format     # Prettier
```

## Repository layout

```
.
├── index.html                 # landing page
├── Runinga/
│   └── index.html             # streaming app
├── Isoko/
│   ├── *.html                 # storefront pages
│   ├── components/            # shared ES-module UI
│   ├── script/                # page-specific JS
│   ├── style/                 # stylesheets
│   └── backend/               # local Express API
├── Ubuni/
│   └── frontend/              # SvelteKit app
└── .github/workflows/
    └── deploy.yml             # Pages build and deploy
```

## Deployment

Pushing to `main` triggers `.github/workflows/deploy.yml`, which:

1. Installs dependencies and builds Ubuni with `PAGES_BASE_PATH=/Ubuni`, so it is served from `/Ubuni/`.
2. Assembles a fresh `site/` directory from the landing page, `Runinga/`, `Isoko/`, and the Ubuni build.
3. Publishes `site/` to GitHub Pages.

Only static files are deployed. The Isoko backend is not hosted on Pages; the electronics pages depend on the remote API URL baked into the frontend.

## Notes

- There is no shared build pipeline, lint config, or test framework at the repository root — each project is independent.
- Project-specific guidance lives in `Isoko/CLAUDE.md` and `Ubuni/CLAUDE.md`.
