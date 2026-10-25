import { formatMoney } from './utils.js';
import { subscribeBooking } from './bookings.js';

const ICONS = {
	home: `<path d="M3 12l2-2m0 0l7-7 7 7M5 19v14a2 2 0 002 2h14a2 2 0 002-2v-14m-6-6H9m0 0l-2-2m2 2l7-7 7 7M21 12l2 2"/>`,
	search: `<circle cx="11" cy="11" r="8"/><path d="M21 21l-4.34-4.34"/>`,
	location: `<path d="M19.5 1.5C17.347 1.5 15.5 3.347 15.5 5.5C15.5 7.653 17.653 9.8 19.5 11.95C21.347 9.8 23.5 7.653 23.5 5.5C23.5 3.347 21.653 1.5 19.5 1.5ZM12 21.5L12 12L15.5 21.5"/>`,
	calendar: `<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>`,
	users: `<path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>`,
	heart: `<path d="M4 31C2.8 31 1.6 29.8 1.6 28.6C1.6 27.4 2.8 26.2 4 26.2C5.2 26.2 6.4 27.4 6.4 28.6C6.4 29.8 5.2 31 4 31ZM20 31C18.8 31 17.6 29.8 17.6 28.6C17.6 27.4 18.8 26.2 20 26.2C21.2 26.2 22.4 27.4 22.4 28.6C22.4 29.8 21.2 31 20 31ZM12 2C6.48 2 2 6.48 2 12C2 15.62 4.43 18.78 8 21.14C8.4 21.3 8.8 21.3 9.2 21.14C12.78 18.78 15.2 15.62 15.2 12C15.2 6.48 10.72 2 12 2Z"/>`,
	chevron: `<polyline points="9 18 15 12 9 6"/>`,
	'chevron-right': `<polyline points="9 6 15 12 9 18"/>`,
	'arrow-right': `<path d="M5 12h14M12 5l7 7-7 7"/>`,
	close: `<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>`,
	menu: `<line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>`,
	star: `<path d="M12 17.27L18.18 21l1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>`,
	check: `<polyline points="20 6 9 17 4 12"/>`,
	wifi: `<path d="M5 12.55a11 11 0 0114.08 0"/><path d="M1.42 9a16 16 0 0121.16 0"/><path d="M8.53 16.11a6 6 0 016.88 0"/><line x1="12" y1="20" x2="12.01" y2="20"/>`,
	pool: `<rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><path d="M3 9h18M3 15h18"/>`,
	bed: `<path d="M21 15V4a2 2 0 00-2-2H5a2 2 0 00-2 2v14l4-4h10l4 4z"/>`,
	'arrow-left': `<path d="M15 18l-6-6 6-6"/>`,
	phone: `<path d="M15.554 4.554a4 4 0 010 5.657L8.708 13.5a2 2 0 00-2.828 2.828L1.554 17.22a4 4 0 010 5.657l5.364 5.363a2 2 0 002.828 2.828l11.314-11.313a4 4 0 010-5.657z"/>`,
	email: `<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>`,
	building: `<path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3 6 3 6-3 2 3h4a2 2 0 012 2z"/><path d="M15 19v-2a2 2 0 00-2-2H9a2 2 0 00-2 2v2z"/><path d="M15 11v2a2 2 0 002 2h2a2 2 0 002-2v-2z"/><path d="M7 19v2a2 2 0 002 2h2a2 2 0 002-2v-2z"/><path d="M11 13v2a2 2 0 002 2h2a2 2 0 002-2v-2z"/>`,
	tag: `<path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 10V2h7.17a2 2 0 012.83 2.83z"/><line x1="7" y1="7" x2="7.01" y2="7"/>`,
	sparkles: `<path d="M21.29 10.71l-2.34-2.33-.54-.54-.53.54-.54.54-.54.53-.54.54.53.53-.54.53-.54.54-.54.53-.53.54-.53-.53.54-.53-.54-.54-.53-.53-.54-.54-.53l-2.33-2.33-2.33 2.33-.54.53-.53.54.53.53.54.54.54.54.53.54.54.54-.53.54-.53.54-.54 2.34 2.33 2.34-2.33-.54-.54-.54-.53-.53-.54-.53-.53-.54-.54-.54-.53-.54-.54-.54-.54-.53-.53-.54-.53-.54-.54-.53l2.33-2.34z"/>`,
	cup: `<path d="M5 7c0-1.885 1.587-3.414 3.539-3.906A15.8 15.8 0 0112 5c1.518 0 2.954.252 4.31.694A9.4 9.4 0 0118.5 7c0 1.885-1.587 3.414-3.539 3.906A15.8 15.8 0 0112 19c-1.518 0-2.954-.252-4.31-.694A9.4 9.4 0 015.5 7zM12 11a4 4 0 014 4v2a4 4 0 01-4 4H8a4 4 0 01-4-4v-2a4 4 0 014-4z"/>`,
	battery: `<rect x="2" y="7" width="20" height="10" rx="2" ry="2"/><path d="M23 11v-2"/>`,
	'stop-circle': `<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>`
};

function icon(name) {
	const d = ICONS[name];
	if (!d) return '';
	return `<svg class="icon icon--${name}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${d}</svg>`;
}

export { icon };

const HEADER_MARKUP = `
	<div class="announcement">
		<div class="container announcement__inner">
			<strong>Indaro</strong> &middot; sample hospitality bookings for Rwanda &mdash; illustrative stays only, not real inventory.
			<a href="#about">Read the site note &rarr;</a>
			<button class="nav-toggle" aria-expanded="false" aria-controls="site-nav" id="nav-toggle" type="button">${icon('menu')}</button>
		</div>
	</div>
	<header class="header-main" id="header-main">
		<div class="container header-inner">
			<a href="index.html" class="brand" aria-label="Indaro home">
				<svg class="brand-mark" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
					<defs>
						<linearGradient id="bungle-grad" x1="0" y1="0" x2="1" y2="1">
							<stop offset="0%" stop-color="#C45525"/>
							<stop offset="100%" stop-color="#E87A4A"/>
						</linearGradient>
					</defs>
					<rect x="1" y="1" width="62" height="62" rx="14" fill="#121417"/>
					<path d="M32 12c-9 0-16 7.5-16 17a17 17 0 0 0 34 0c0-9.5-7-17-16 17Z" fill="url(#bungle-grad)"/>
					<path d="M32 46V20M32 32c-4.5 0-8 4-8 9s3.5 9 8 9Zm0 12c-4.5 0-8-4-8-9s3.5-9 8-9Z" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
					<circle cx="46" cy="18" r="3" fill="#FFFFFF"/>
				</svg>
				<div class="brand__text">
					<div class="brand__word">Indaro</div>
					<div class="brand__tagline">Hospitality &middot; Rwanda</div>
				</div>
			</a>
			<div class="nav-search" id="nav-search">
				<select class="nav-search__select" id="nav-location" aria-label="Filter by location">
					<option value="">Any location</option>
				</select>
				<label class="visually-hidden" for="nav-search-input">Search stays</label>
				<input class="nav-search__input" id="nav-search-input" type="search" placeholder="Search stays &hellip;" aria-label="Search stays"/>
				<button class="nav-search__button" type="button" id="nav-search-button">${icon('search')}</button>
			</div>
			<a href="booking.html" class="cart-link" aria-label="Your booking summary">
				<span class="cart-link__icon">${icon('heart')}</span>
				<div class="cart-link__copy">
					<div class="cart-label">Your booking</div>
					<div class="cart-total" id="cart-total">$0.00</div>
				</div>
				<span class="cart-badge" id="cart-badge">0</span>
			</a>
		</div>
	</header>
	<nav class="site-nav" id="site-nav">
		<div class="container nav-inner">
			<div class="nav-links">
				<a href="index.html"${currentPage === 'home' ? ' aria-current="page"' : ''}>Home</a>
				<a href="stays.html"${currentPage === 'stays' ? ' aria-current="page"' : ''}>Stays</a>
				<a href="#about"${currentPage === 'about' ? ' aria-current="page"' : ''}>About</a>
				<a href="#help"${currentPage === 'help' ? ' aria-current="page"' : ''}>Help</a>
			</div>
			<div class="nav-note">
				${icon('info-circle') ? icon('stop-circle') : ''}
				<span>Illustrative sample data &mdash; not real inventory</span>
			</div>
		</div>
	</nav>
`;

const FOOTER_MARKUP = `
	<div class="footer-main">
		<div class="container footer-grid">
			<div class="footer-brand">
				<a href="index.html" class="brand" aria-label="Indaro home">
					<svg class="brand-mark" viewBox="0 0 64 64" aria-hidden="true" focusable="false">
						<rect x="1" y="1" width="62" height="62" rx="14" fill="var(--header)"/>
						<path d="M32 12c-9 0-16 7.5-16 17a17 17 0 0 0 34 0c0-9.5-7-17-16 17Z" fill="url(#bungle-grad)"/>
						<path d="M32 46V20M32 32c-4.5 0-8 4-8 9s3.5 9 8 9Zm0 12c-4.5 0-8-4-8-9s3.5-9 8-9Z" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
						<circle cx="46" cy="18" r="3" fill="#FFFFFF"/>
					</svg>
					<div class="brand__text">
						<div class="brand__word">Indaro</div>
						<div class="brand__tagline">Hospitality &middot; Rwanda</div>
					</div>
				</a>
				<p>Sample hospitality platform for Rwanda &mdash; built to explore accommodation opportunities referenced in the Rwanda Formula 1 &amp; Tourism Investment checklist. Listings are illustrative and not bookable inventory.</p>
				<a href="stays.html" class="footer-cta">Browse stays${icon('arrow-right')}</a>
			</div>
			<div class="footer-column">
				<h2>Stay</h2>
				<div class="footer-links">
					<a href="stays.html">All stays</a>
					<a href="stays.html?location=kigali">Kigali</a>
					<a href="stays.html?location=musanze">Musanze</a>
					<a href="stays.html?location=gisenyi">Gisenyi</a>
					<a href="stays.html?location=nyungwe">Nyungwe</a>
				</div>
			</div>
			<div class="footer-column">
				<h2>Type</h2>
				<div class="footer-links">
					<a href="stays.html?type=hotel">Hotels</a>
					<a href="stays.html?type=boutique-hotel">Boutique hotels</a>
					<a href="stays.html?type=guesthouse">Guesthouses</a>
					<a href="stays.html?type=villa">Villas</a>
					<a href="stays.html?type=glamping">Glamping</a>
				</div>
			</div>
			<div class="footer-column">
				<h2>Help</h2>
				<div class="footer-links">
					<a href="#help">How booking works</a>
					<a href="#about">Site note &amp; data</a>
					<a href="#about">Illustrative disclaimer</a>
					<a href="#help">Contact</a>
				</div>
			</div>
		</div>
	</div>
	<div class="footer-bottom">
		<div class="container footer-bottom__inner">
			<span class="footer-note">&copy; ${new Date().getFullYear()} Indaro &mdash; sample project.</span>
			<div class="footer-links" style="flex-direction:row; gap:16px;">
				<a href="#privacy">Privacy</a>
				<a href="#terms">Terms</a>
			</div>
		</div>
	</div>
`;

export function mountLayout({ currentPage = '' } = {}) {
	const header = document.getElementById('site-header');
	const footer = document.getElementById('site-footer');
	if (header) header.innerHTML = HEADER_MARKUP.replace(/currentPage === '([^']+)' \? .*?: ''/g, () => '').replace(
		/\$\{currentPage === '([^']+)' \? ' aria-current="page"' : ''\}/g,
		(match, page) => (page === currentPage ? ' aria-current="page"' : '')
	);
	if (footer) footer.innerHTML = FOOTER_MARKUP;

	// Icon sprite (hidden) so <use> references across pages resolve in-document.
	const sprite = document.createElement('div');
	sprite.hidden = true;
	sprite.innerHTML = `
		<svg xmlns="http://www.w3.org/2000/svg">
			<symbol id="icon-info-circle" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></symbol>
		</svg>
	`;
	if (header) header.parentNode?.insertBefore(sprite, header.nextSibling);

	// Wire mobile menu.
	const toggle = document.getElementById('nav-toggle');
	const nav = document.getElementById('site-nav');
	if (toggle && nav) {
		toggle.addEventListener('click', () => {
			const open = nav.classList.toggle('is-open');
			toggle.setAttribute('aria-expanded', String(open));
		});
	}

	// Wire header search: location filter + keyword.
	const locationSelect = document.getElementById('nav-location');
	const searchInput = document.getElementById('nav-search-input');
	const searchButton = document.getElementById('nav-search-button');
	if (locationSelect) {
		// populate locations lazily via listings module if available
	}
	if (searchButton && searchInput) {
		searchButton.addEventListener('click', () => {
			const q = searchInput.value.trim();
			const location = locationSelect ? locationSelect.value : '';
			window.location.href = buildStaysUrl({ q, location });
		});
		searchInput.addEventListener('keydown', (event) => {
			if (event.key === 'Enter') {
				event.preventDefault();
				const q = searchInput.value.trim();
				const location = locationSelect ? locationSelect.value : '';
				window.location.href = buildStaysUrl({ q, location });
			}
		});
	}

	// Booking badge / total subscription.
	subscribeBooking((booking) => {
		const badge = document.getElementById('cart-badge');
		const total = document.getElementById('cart-total');
		const hasListing = booking.listing && booking.checkIn && booking.checkOut;
		if (badge) badge.textContent = booking.listing ? '1' : '0';
		if (total) total.textContent = hasListing ? formatMoney(booking.total) : '$0.00';
		badge?.classList.toggle('is-hidden', !booking.listing);
		total?.classList.toggle('is-hidden', !booking.listing);
	});
}

import { buildStaysUrl } from './utils.js';

export { HEADER_MARKUP, FOOTER_MARKUP };
