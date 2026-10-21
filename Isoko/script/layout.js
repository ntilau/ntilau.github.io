import { CATEGORIES, getCategory } from './catalog.js';
import { getTotals, subscribeCart } from './store.js';
import { ICON_SPRITE, icon } from './ui.js';
import { buildShopUrl, createElement, escapeHtml, formatMoney, readShopState } from './utils.js';

const BRAND_MARK = `
	<svg class="brand-mark" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
		<rect x="1" y="1" width="62" height="62" rx="13" fill="#FFD814"/>
		<path d="M32 11c-8 6-13 14-13 22a13 13 0 0 0 26 0c0-8-5-16-13-22Z" fill="#131921" opacity=".12"/>
		<path d="M32 48V21M32 31c5-1 9-4 10-10-5 0-9 4-10 10Zm0 9c-5-1-8-4-9-9 5 0 8 3 9 9Z" fill="none" stroke="#131921" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/>
		<circle cx="45" cy="18" r="3.4" fill="#131921"/>
	</svg>
`;

function categoryLinks() {
	return CATEGORIES.map(
		(category) =>
			`<a href="shop.html?category=${encodeURIComponent(category.slug)}">${escapeHtml(category.label)}</a>`
	).join('');
}

function categoryOptions() {
	return [
		'<option value="">All departments</option>',
		...CATEGORIES.map(
			(category) =>
				`<option value="${encodeURIComponent(category.slug)}">${escapeHtml(category.label)}</option>`
		)
	].join('');
}

function headerMarkup() {
	return `
		<div class="announcement">
			<div class="container announcement__inner">
				<span>An independent, guest-only market for useful everyday things.</span>
				<a href="index.html#assurances">Free delivery over ₹10,000</a>
			</div>
		</div>

		<div class="header-main">
			<div class="container header-inner">
				<a class="brand" href="index.html" aria-label="Isoko home">
					${BRAND_MARK}
					<span class="brand__text">
						<span class="brand__word">isoko</span>
						<span class="brand__tagline">guest market</span>
					</span>
				</a>

				<a class="header-utility header-utility--delivery" href="index.html#assurances">
					<span class="header-utility__top">Delivery</span>
					<strong class="header-utility__bottom">Free over ₹10,000</strong>
				</a>

				<form class="nav-search" action="shop.html" method="get" role="search">
					<label class="visually-hidden" for="site-search-category">Search department</label>
					<select class="nav-search__select" id="site-search-category" name="category">
						${categoryOptions()}
					</select>
					<label class="visually-hidden" for="site-search">Search the market</label>
					<input id="site-search" name="q" type="search" placeholder="Search the market" autocomplete="off">
					<button class="nav-search__button" type="submit" aria-label="Search">${icon('search')}</button>
				</form>

				<a class="header-utility header-utility--guest" href="shoppingcart.html">
					<span class="header-utility__top">Hello, guest</span>
					<strong class="header-utility__bottom">Guest checkout</strong>
				</a>

				<a class="cart-link" href="shoppingcart.html" data-cart-link aria-label="Cart, 0 items">
					<span class="cart-link__icon">
						${icon('cart')}
						<span class="cart-badge" data-cart-count hidden>0</span>
					</span>
					<span class="cart-link__copy">
						<span class="cart-label">Cart</span>
						<strong class="cart-total" data-cart-total>₹0.00</strong>
					</span>
				</a>

				<button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-nav" aria-label="Open menu">
					<span data-menu-icon>${icon('menu')}</span>
					<span data-close-icon hidden>${icon('close')}</span>
				</button>
			</div>
		</div>

		<nav class="site-nav" id="site-nav" aria-label="Primary">
			<div class="container nav-inner">
				<div class="nav-links">
					<a href="shop.html" data-nav="shop">All products</a>
					${categoryLinks()}
					<a href="index.html#market-picks">Today’s picks</a>
					<a href="shoppingcart.html">Guest checkout</a>
				</div>
				<span class="nav-note">${icon('truck')} Guest cart saved on this device</span>
			</div>
		</nav>
	`;
}

function footerMarkup() {
	const year = new Date().getFullYear();
	const categories = CATEGORIES.map(
		(category) =>
			`<a href="shop.html?category=${encodeURIComponent(category.slug)}">${escapeHtml(category.label)}</a>`
	).join('');

	return `
		<a class="back-to-top" href="#main-content">Back to top</a>

		<div class="container footer-main">
			<div class="footer-grid">
				<div class="footer-brand">
					<a class="brand" href="index.html" aria-label="Isoko home">
						${BRAND_MARK}
						<span class="brand__text">
							<span class="brand__word">isoko</span>
							<span class="brand__tagline">guest market</span>
						</span>
					</a>
					<p>An independent market for electronics, apparel and textiles, and car parts — all in one place.</p>
					<a class="footer-cta" href="shop.html">Start shopping ${icon('arrow')}</a>
				</div>

				<div class="footer-column">
					<h2>Departments</h2>
					<div class="footer-links">
						<a href="shop.html">All products</a>
						${categories}
					</div>
				</div>

				<div class="footer-column">
					<h2>Your market</h2>
					<div class="footer-links">
						<a href="index.html#market-picks">Today’s picks</a>
						<a href="index.html#how-it-works">How it works</a>
						<a href="index.html#assurances">Delivery &amp; care</a>
						<a href="shoppingcart.html">Your cart</a>
					</div>
				</div>

				<div class="footer-column">
					<h2>The small print</h2>
					<p class="footer-note">
						<strong>A demo storefront.</strong> Browsing and checkout happen entirely on this device.
						There are no accounts, no payments, and no orders sent anywhere.
					</p>
				</div>
			</div>
		</div>

		<div class="footer-bottom">
			<div class="container footer-bottom__inner">
				<span>© ${year} Isoko market. All product images belong to their original sellers.</span>
				<a href="shop.html">Back to the market</a>
			</div>
		</div>
	`;
}

function setCartSummary(totals = {}) {
	const count = Number(totals.count) || 0;
	const subtotal = Number(totals.subtotal) || 0;
	const badge = document.querySelector('[data-cart-count]');
	const totalNode = document.querySelector('[data-cart-total]');
	const link = document.querySelector('[data-cart-link]');
	if (!badge || !link) return;

	badge.textContent = count > 99 ? '99+' : String(count);
	badge.hidden = count === 0;
	if (totalNode) totalNode.textContent = formatMoney(subtotal);
	link.setAttribute(
		'aria-label',
		`Cart, ${count} ${count === 1 ? 'item' : 'items'}, subtotal ${formatMoney(subtotal)}`
	);
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
	const select = form?.querySelector('select[name="category"]');
	if (!form || !input) return;

	if (document.body.dataset.page === 'shop') {
		const state = readShopState();
		if (state.q) input.value = state.q;
		if (select && getCategory(state.category)) select.value = state.category;
	}

	form.addEventListener('submit', (event) => {
		event.preventDefault();
		const category = getCategory(select?.value ?? '') ? select.value : '';
		window.location.href = buildShopUrl({ q: input.value, category });
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

	setCartSummary(getTotals());
	subscribeCart((totals) => setCartSummary(totals));
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
