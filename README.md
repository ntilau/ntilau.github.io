# ntilau.github.io

Three self-contained web apps served from one GitHub Pages site.

**Live site:** https://ntilau.github.io/

| Project | Path | What it is |
| --- | --- | --- |
| [Runinga](Runinga/index.html) | `/Runinga/` | Fullscreen HLS television player with 321 channels |
| [Isoko](Isoko/index.html) | `/Isoko/` | Amazon-inspired marketplace for electronics, apparel, and car parts |
| [Ubuni](Ubuni/frontend/) | `/Ubuni/` | SvelteKit floor-plan editor with 2D and 3D views |

The root `index.html` is a dependency-free landing page linking to all three.

## Runinga

A single-file streaming app: one HTML file containing markup, styles, the channel list, and all playback logic.

- HLS.js from jsDelivr, with native HLS playback on Safari
- Navigate with arrow keys / Page Up / Page Down, horizontal swipes, the mouse wheel, or double-taps on the left/right thirds of the screen
- Failed streams are dropped automatically and playback advances to the next channel

No build step. Open `Runinga/index.html` directly in a browser, or visit `/Runinga/` on the live site.

## Isoko

A fully static, guest-only marketplace with an independent, Amazon-inspired storefront: dark utility header, department search, white product cards, filter sidebar, three-column product page, and cart summary. There is no backend, no accounts, and no payment integration, and no Amazon logos, fonts, assets, or copy are used.

- One unified catalog of 44 products across electronics, apparel and textiles, and car parts
- Header search that carries a department, plus a shareable shop URL with department, price-range, query, and sort filters
- Product pages with a gallery, buy box, quantity controls, related picks, and image fallbacks
- A cart saved in `localStorage` (`isoko:cart:v1`) with quantity editing and a ₹499 delivery fee, free over ₹10,000
- A local demo checkout that collects delivery details, generates an order number, saves the last order on the device, and clears the cart — nothing is uploaded or charged
- Old category and account URLs redirect into the new shop or home page

No build step or API is required. Serve the repository root and open `/Isoko/`:

```bash
python3 -m http.server 8080
# http://localhost:8080/Isoko/
```

Product images use remote alicdn URLs with a local branded placeholder on failure. The legacy `alibabacart` cart is migrated once into the new cart format.

## Ubuni

A client-only SvelteKit floor-plan editor built with TypeScript, Tailwind, and Three.js.

- Full 2D editor: select, wall, room, door, window, furniture, and pan tools with snap-to-grid and endpoint snapping
- Move/rotate/delete furniture, drag wall endpoints and room vertices, slide openings along walls, undo/redo, zoom and Fit
- 3D orbit view with openings, room floors, furniture, and click-to-select
- Inspector for editing selected objects; shortcuts and a live status bar
- Autosaves one design to `localStorage`; New, JSON import/export, vector SVG and PDF export
- Vitest suite for geometry, history, and exports

```bash
cd Ubuni/frontend
npm install
npm run dev        # Vite dev server
npm run build      # static build in build/
npm run check      # svelte-check (TypeScript strict)
npm test           # Vitest
npm run format     # Prettier
```

## Repository layout

```
.
├── index.html                 # landing page
├── Runinga/
│   └── index.html             # streaming app
├── Isoko/
│   ├── *.html                 # home, shop, product, cart, redirect stubs
│   ├── script/                # catalog, cart/store, layout, UI, page controllers
│   ├── style/                 # one shared design system
│   └── assets/                # favicon and product placeholder
├── Ubuni/
│   └── frontend/              # SvelteKit app
└── .github/workflows/
    └── deploy.yml             # Pages build and deploy
```

## Deployment

Pages is configured with Source: **GitHub Actions**. Do not switch it back to branch deploy: the legacy build overwrites the workflow artifact and leaves `/Ubuni/` 404.

Pushing to `main` triggers `.github/workflows/deploy.yml`, which:

1. Installs dependencies and builds Ubuni with `PAGES_BASE_PATH=/Ubuni`, so it is served from `/Ubuni/`.
2. Assembles a fresh `site/` directory from the landing page, `Runinga/`, `Isoko/`, and the Ubuni build.
3. Publishes `site/` to GitHub Pages.

Only static files are deployed. Isoko is entirely client-side, so it needs no API host; its cart and demo orders stay in each visitor's browser.

## Notes

- There is no shared build pipeline, lint config, or test framework at the repository root — each project is independent.
- Project-specific guidance lives in `Isoko/CLAUDE.md` and `Ubuni/CLAUDE.md`.
