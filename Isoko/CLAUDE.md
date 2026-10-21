# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Isoko is a **fully static, guest-only marketplace** served at `/Isoko/` on GitHub Pages. It has no backend, no accounts, no payment integration, and no build step. All application state lives in the browser: the cart and the last demo order are stored in `localStorage`, and nothing is uploaded.

The site carries its own Isoko brand (warm paper, deep green ink, terracotta and gold accents), not an Alibaba lookalike. It has one unified catalog of **44 products** across three categories: electronics (12), apparel and textiles (12), and car parts (20). Product images remain remote alicdn URLs, lazy-loaded, with a local branded fallback.

Every path is relative so the app works both at `/Isoko/` on Pages and from a local static server.

## Commands

There is no build, lint, package manager, or test suite for Isoko.

```bash
# From the repository root
python3 -m http.server 8080
# Open http://localhost:8080/Isoko/
```

Useful static checks:

```bash
# JS modules are plain ES modules
for file in Isoko/script/*.js; do node --check "$file" || exit 1; done

# No backend/API/auth remnants (only the intentional legacy keys in store.js remain)
rg -n '143\.47\.179\.233|/backend|jwt|bcrypt|Authorization|fetch\(|XMLHttpRequest|axios' Isoko

# No dead controls
rg -n 'href="#"|href=""|src=""' Isoko
```

Deployment is handled by the root `.github/workflows/deploy.yml`, which copies the entire `Isoko/` directory into the Pages artifact. There is no Isoko-specific workflow.

## Page Map

| File | Purpose |
| --- | --- |
| `index.html` | Editorial home: working search, hero collage, category tiles, featured picks, how-it-works, demo rules |
| `shop.html` | Unified catalog with search, category chips, sort, result count, and quick-add |
| `openproduct.html` | Product detail selected by `?id=<global-product-id>`; gallery, quantity, add to cart, related products |
| `shoppingcart.html` | Guest cart, delivery form, demo checkout, and `?ordered=1` confirmation |
| `electronics.html`, `electronics-subcategory.html` | Redirect to `shop.html?category=electronics` |
| `apparels.html`, `apparel.html` | Redirect to `shop.html?category=apparel` |
| `carpart.html` | Redirect to `shop.html?category=car-parts` |
| `signin.html`, `signUp.html` | Redirect to `index.html`; accounts no longer exist |

Redirect stubs use `meta refresh`, `window.location.replace`, a visible fallback link, and `noindex`. Keep them working when routes change.

### URL Contract

- `shop.html?category=electronics|apparel|car-parts&q=<search>&sort=featured|price-asc|price-desc|name-asc`
- `openproduct.html?id=electronics-1` (IDs are globally unique and category-prefixed)
- `shoppingcart.html?ordered=1` re-renders the saved last order

Shop state is URL-driven. `script/shop.js` reads and validates it on load, then updates the URL with `history.replaceState` as filters change. Unknown categories or sort values fall back to all products / featured order.

## Architecture

### Shared chrome

Every page contains empty `<header id="site-header">` and `<footer id="site-footer">` elements plus `<div id="toast-region" role="status" aria-live="polite">`. `script/layout.js`:

- Injects the inline SVG icon sprite and renders the header/footer.
- Renders the local `isoko` wordmark, shop/category links, global search form, and cart link with a live quantity badge.
- Wires the mobile menu (toggle, Escape, outside click, close on navigation, resize).
- Marks the active nav/category/cart item from `body[data-page]` and query parameters.
- Subscribes to cart changes; `store.js` also listens for cross-tab `storage` events.
- Exports `createBreadcrumb()` for JS-rendered pages.

### Catalog — `script/catalog.js`

The single source of truth for categories and products. Never duplicate product data in HTML or page scripts.

Exports: `CATEGORIES`, `SORT_OPTIONS`, `PRODUCTS`, `getProductById()`, `getCategory()`, `getCategoryCount()`, `categoryCounts()`, `getFeatured()`, `getRelated()`, `isValidSort()`, and `queryProducts({ q, category, sort })`.

Product shape:

```js
{
  id, title, category, categoryLabel, subcategory, price,
  images, description, keywords, stock, featured, badge, order
}
```

Products are frozen. Images are deduplicated and thumbnail suffixes such as `_50x50` are stripped. Prices are INR and rounded to two decimals. Search normalizes case/diacritics and AND-matches tokens across title, subcategory, category label, keywords, and description. Sorting is pure and operates on copies.

Category order is the display order. The three slugs (`electronics`, `apparel`, `car-parts`) are part of the URL contract.

### Cart and orders — `script/store.js`

The only module that writes cart/order state. All reads validate and sanitize parsed JSON: unknown product IDs are dropped, duplicate IDs merge, and quantities are clamped to product stock.

```js
CART_KEY       = 'isoko:cart:v1'
ORDER_KEY      = 'isoko:last-order:v1'
FLAT_SHIPPING  = 499
FREE_SHIPPING_AT = 10000
```

Key exports: `getCart()`, `getCartLines()`, `getCartCount()`, `getSubtotal()`, `getShipping()`, `getTotals()`, `addToCart()`, `setQuantity()`, `removeFromCart()`, `clearCart()`, `generateOrderNumber()`, `saveOrder()`, `getLastOrder()`, `subscribeCart()`, `hasPersistentStorage()`.

- Totals are always recomputed from the catalog, never trusted from storage.
- Shipping is ₹499 flat and free once the subtotal reaches ₹10,000.
- Every non-silent write dispatches `isoko:cart-change` with current totals; subscribers update the header badge and cart page.
- `clearCart()` writes an empty canonical cart instead of deleting the key, so legacy migration cannot resurrect items.
- Legacy migration from `alibabacart` matches normalized product titles, writes the new cart, then removes `alibabacart`, `openedProduct`, and `details_prod`. This migration is intentional; those key names are the only legacy references that should remain.
- Storage access is guarded. If `localStorage` is blocked or fails, the cart/order fall back to module memory for the current page session.

### Demo checkout

`script/cart.js` builds the cart, delivery form, summary, and confirmation entirely from JS. Checkout is explicitly a local demonstration: it collects delivery details, validates them, creates an order number in the form `ISK-YYYYMMDD-XXXX`, snapshots items/totals/customer, saves the order under `ORDER_KEY`, clears the cart, replaces the URL with `?ordered=1`, and shows a printable confirmation.

- No payment details are requested or processed.
- Customer details never leave the browser.
- Confirmation copy must never claim an order was sent, accepted, or paid for.
- On reload with `?ordered=1`, the saved order is re-rendered; without a saved order, the page falls back to the normal cart and removes the query.
- Cart quantity controls and remove buttons are `type="button"` so they do not submit the checkout form.

### UI helpers and utilities

- `script/ui.js`: icon sprite, `FALLBACK_IMAGE`, image creation with error fallback, product cards/grid, category tiles, empty states, quantity steppers, and toasts. User-controlled text is inserted with `textContent`, not HTML interpolation.
- `script/utils.js`: money/date formatting (`en-IN`, INR), text normalization, HTML escaping, quantity parsing, image URL cleanup, shop/product URL builders, shop-state parsing, debounce, and DOM helpers.
- `script/home.js`, `shop.js`, `product.js`, `cart.js`: page controllers; each mounts the layout first.
- `style/isoko.css`: the single design system. It owns tokens, header/footer, cards, gallery, cart/checkout, forms, toast, empty states, responsive breakpoints, reduced motion, and print styles. `[hidden] { display: none !important; }` is deliberate because author display rules otherwise override the hidden attribute.

### Images and assets

- Product images are remote alicdn URLs. They are lazy-loaded except the main product image and first hero image.
- `attachImageFallback()` swaps failed images for `assets/product-placeholder.svg` and adds `.is-fallback`.
- `assets/favicon.svg` is the local Isoko favicon. Do not reintroduce Alibaba logos, social/app-store icons, or hotlinked brand assets.

## Editing Rules

- Keep Isoko static: no backend, API calls, authentication, accounts, payment processing, or network writes.
- Keep all URLs relative (for example `style/isoko.css`, `script/home.js`, `assets/...`) so Pages' `/Isoko/` base works.
- Put product changes in `catalog.js` only, and preserve globally unique prefixed IDs; old product links depend on them.
- Put cart/order writes in `store.js` only. Treat `localStorage` as untrusted input.
- Keep one shared CSS system and one shared header/footer implementation.
- Preserve accessibility basics: one visible `h1` per view, skip link, semantic landmarks, labeled controls, `aria-live` result/toast regions, keyboard-operable galleries/steppers, visible focus, and reduced-motion/print support.
- Never label the checkout as real, uploaded, or paid.

## Verification

1. Serve the repository root and open `http://localhost:8080/Isoko/`.
2. Home: category tiles navigate to filtered shop URLs; search submits to `shop.html?q=...`; featured quick-add updates the cart badge.
3. Shop: category/search/sort/clear filters work, URL stays shareable, no-results state appears, and all 44 products render with no filters.
4. Product: direct `?id=` load, unknown ID not-found panel, gallery switching, quantity clamping, add/merge, related products, image fallback.
5. Cart: reload persistence, quantity updates, free-shipping threshold at ₹10,000, remove-to-empty, invalid-form focus, valid demo order, confirmation, cart cleared, `?ordered=1` reload.
6. Legacy migration from `alibabacart`, all redirect stubs, mobile menu, and no horizontal overflow at 320 px.
7. Check that there are no page errors, console errors, failed local asset requests, dead `href="#"` links, or root-absolute Isoko paths.
8. After changing docs, re-read this file to ensure no stale paths or line numbers remain.
