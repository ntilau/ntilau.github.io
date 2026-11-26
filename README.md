# ntilau.github.io

Runinga, a fullscreen HLS streaming TV app, served from the root of this GitHub Pages site.

**Live site:** https://ntilau.github.io/

**Repository:** description — `Runinga - HLS live TV player: 321 M3U8 channels, keyboard/touch nav, OSD, auto-drops failed streams. GitHub Pages.` Topics — `html5`, `javascript`, `multimedia`, `web-application`, `github-pages`, `streaming`, `hls`, `iptv`, `live-tv`, `m3u8`.

## What it is

A single-file streaming app: one HTML file containing markup, styles, the channel list (321 channels), and all playback logic.

- HLS.js from jsDelivr, with native HLS playback on Safari
- Keyboard (arrows, Page Up/Down), touch/swipe, mouse wheel, and click navigation with an on-screen display
- Failed streams are dropped automatically and playback advances to the next channel

No build step. Open `index.html` directly in a browser, or visit the live site.

## Running locally

```bash
python3 -m http.server 8080
# http://localhost:8080/
```

Save edits to `index.html` and reload; debug with browser dev tools (F12).

## Adding a channel

1. Open `index.html` and locate the `channels` array (starts at line 31).
2. Append a new object: `{name:"Channel Name",url:"https://example.com/stream.m3u8"}`.
3. Save and reload — the channel appears in navigation automatically.

## Repository layout

```
.
├── index.html                 # Runinga streaming app
└── .github/workflows/
    └── deploy.yml             # Pages build and deploy
```

## Deployment

Pages is configured with Source: **GitHub Actions**. Pushing to `main` triggers `.github/workflows/deploy.yml`, which assembles a fresh `site/` directory from `index.html` and publishes it to GitHub Pages.

## Notes

- There is no shared build pipeline, lint config, or test framework at the repository root.
