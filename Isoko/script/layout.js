import { CATEGORIES } from './catalog.js';
import { getCartCount, subscribeCart } from './store.js';
import { ICON_SPRITE, icon } from './ui.js';
import { createElement } from './utils.js';

const BRAND_MARK = `
	<svg class="brand-mark" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
		<rect x="1" y="1" width="62" height="62" rx="16" fill="#173A2E"/>
		<path d="M32 12c-8 6-13 13-13 21a13 13 0 0 0 26 0c0-8-5-15-13-21Z" fill="#D9A441" opacity=".25"/>
		<path d="M32 46V22M32 31c5-1 8-4 9-9-5 0-8 3-9 9Zm0 7c-4-1-7-4-8-8 4 0 7 2 8 8Z" fill="none" stroke="#F7F1E7" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
		<circle cx="44" cy="18" r="4" fill="#C85C3C"/>
	</svg>
`;

function categoryLinks() {
	return CATEGORIES.map(
		(category) =>
			`<a href="shop.html?category=${encodeURIComponent(category.slug)}">${category.label}</a>`
	).join('');
}

function headerMarkup() {
	return `
		<div class="announcement">A small, independent market for useful everyday things.</div>
		<div class="container header-inner">
			<a class="brand" href="index.html" aria-label="Isoko home">
				${BRAND_MARK}
				<span>isoko</span>
			</a>

			<nav class="site-nav" id="site-nav" aria-label="Primary">
				<div class="nav-links">
					<a href="shop.html" data-nav="shop">Shop all</a>
					${categoryLinks()}
				</div>
				<form class="nav-search" action="shop.html" method="get" role="search">
					<label class="visually-hidden" for="site-search">Search the market</label>
					<input id="site-search" name="q" type="search" placeholder="Search the market" autocomplete="off">
					<button type="submit" aria-label="Search">${icon('search')}</button>
				</form>
			</nav>

			<a class="cart-link" href="shoppingcart.html" data-cart-link aria-label="Cart, 0 items">
				${icon('cart')}
				<span class="cart-label">Cart</span>
				<span class="cart-badge" data-cart-count hidden>0</span>
			</a>

			<button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-nav" aria-label="Open menu">
				<span data-menu-icon>${icon('menu')}</span>
				<span data-close-icon hidden>${icon('close')}</span>
			</button>
		</div>
	`;
}

function footerMarkup() {
	const year = new Date().getFullYear();
	const categories = CATEGORIES.map(
		(category) =>
			`<a href="shop.html?category=${encodeURIComponent(category.slug)}">${category.label}</a>`
	).join('');

	return `
		<div class="container">
			<div class="footer-grid">
				<div class="footer-brand">
					<a class="brand" href="index.html" aria-label="Isoko home">
						${BRAND_MARK}
						<span>isoko</span>
					</a>
					<p>A calm, independent market for electronics, textiles, and car parts — gathered in one place.</p>
				</div>

				<div>
					<h2>Shop</h2>
					<div class="footer-links">
						<a href="shop.html">Shop all</a>
						${categories}
					</div>
				</div>

				<div>
					<h2>About Isoko</h2>
					<div class="footer-links">
						<a href="index.html#how-it-works">How it works</a>
						<a href="index.html#assurances">Shipping &amp; care</a>
						<a href="shoppingcart.html">Your cart</a>
					</div>
				</div>

				<div>
					<h2>The small print</h2>
					<p class="footer-note">
						<strong>A demo storefront.</strong> Browsing and checkout happen entirely on this device.
						There are no accounts, no payments, and no orders sent anywhere.
					</p>
				</div>
			</div>

			<div class="footer-bottom">
				<span>© ${year} Isoko market. All product images belong to their original sellers.</span>
				<a href="shop.html">Back to the market</a>
			</div>
		</div>
	`;
}

function setCartCountLabel(count) {
	const badge = document.querySelector('[data-cart-count]');
	const link = document.querySelector('[data-cart-link]');
	if (!badge || !link) return;

	badge.textContent = count > 99 ? '99+' : String(count);
	badge.hidden = count === 0;
	link.setAttribute('aria-label', `Cart, ${count} ${count === 1 ? 'item' : 'items'}`);
}

function wireNavigation(header) {
	const toggle = header.querySelector('.nav-toggle');
	const nav = header.querySelector('#site-nav');
	const menuIcon = header.querySelector('[data-menu-icon]');
	const closeIcon = header.querySelector('[data-close-icon]');
	if (!toggle || !nav) return;

	const setOpen = (open) => {
		nav.classList.toggle('is-open', open);
		toggle.setAttribute('aria-expanded', String(open));
		toggle.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
		if (menuIcon) menuIcon.hidden = open;
		if (closeIcon) closeIcon.hidden = !open;
	};

	toggle.addEventListener('click', () => {
		setOpen(toggle.getAttribute('aria-expanded') !== 'true');
	});

	nav.addEventListener('click', (event) => {
		if (event.target.closest('a')) setOpen(false);
	});

	document.addEventListener('keydown', (event) => {
		if (event.key === 'Escape' && nav.classList.contains('is-open')) {
			setOpen(false);
			toggle.focus();
		}
	});

	document.addEventListener('click', (event) => {
		if (!nav.classList.contains('is-open')) return;
		if (!header.contains(event.target)) setOpen(false);
	});

	window.addEventListener('resize', () => {
		if (window.innerWidth > 960 && nav.classList.contains('is-open')) setOpen(false);
	});
}

function wireSearch(header) {
	const form = header.querySelector('.nav-search');
	const input = form?.querySelector('input[name="q"]');
	if (!form || !input) return;

	if (document.body.dataset.page === 'shop') {
		const query = new URLSearchParams(window.location.search).get('q');
		if (query) input.value = query;
	}

	form.addEventListener('submit', (event) => {
		event.preventDefault();
		const query = input.value.trim();
		window.location.href = query ? `shop.html?q=${encodeURIComponent(query)}` : 'shop.html';
	});
}

function markActivePage(header) {
	const page = document.body.dataset.page;
	const navLink = header.querySelector('[data-nav="shop"]');
	const cartLink = header.querySelector('[data-cart-link]');

	if ((page === 'shop' || page === 'product') && !new URLSearchParams(window.location.search).get('category')) {
		navLink?.setAttribute('aria-current', 'page');
	}

	if (page === 'cart') cartLink?.setAttribute('aria-current', 'page');

	if (page === 'home') {
		const brand = header.querySelector('.brand');
		brand?.setAttribute('aria-current', 'page');
	}

	const activeCategory = new URLSearchParams(window.location.search).get('category');
	if (activeCategory) {
		const categoryLink = header.querySelector(
			`.nav-links a[href="shop.html?category=${CSS.escape(activeCategory)}"]`
		);
		categoryLink?.setAttribute('aria-current', 'page');
		if ((page === 'shop' || page === 'product') && categoryLink) navLink?.removeAttribute('aria-current');
	}
}

export function mountLayout() {
	document.body.insertAdjacentHTML('afterbegin', ICON_SPRITE);

	const header = document.getElementById('site-header');
	const footer = document.getElementById('site-footer');

	if (header) {
		header.className = 'site-header';
		header.innerHTML = headerMarkup();
		wireNavigation(header);
		wireSearch(header);
		markActivePage(header);
	}

	if (footer) {
		footer.className = 'site-footer';
		footer.innerHTML = footerMarkup();
	}

	setCartCountLabel(getCartCount());
	subscribeCart((totals) => setCartCountLabel(totals.count));
}

export function createBreadcrumb(items) {
	const nav = createElement('nav', 'breadcrumb');
	nav.setAttribute('aria-label', 'Breadcrumb');
	const list = document.createElement('ol');
	list.style.display = 'contents';

	items.forEach((item, index) => {
		const li = document.createElement('li');
		li.style.display = 'contents';

		if (index > 0) {
			const chevron = document.createElement('span');
			chevron.setAttribute('aria-hidden', 'true');
			chevron.innerHTML = icon('chevron');
			li.append(chevron);
		}

		if (item.href && index < items.length - 1) {
			const link = document.createElement('a');
			link.href = item.href;
			link.textContent = item.label;
			li.append(link);
		} else {
			const span = document.createElement('span');
			span.textContent = item.label;
			span.setAttribute('aria-current', 'page');
			li.append(span);
		}

		list.append(li);
	});

	nav.append(list);
	return nav;
}
