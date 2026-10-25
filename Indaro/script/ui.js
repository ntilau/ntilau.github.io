import { escapeHtml, formatMoney, formatNightCount, formatDate, stripImageSize } from './utils.js';

const PLACEHOLDER = 'assets/stay-placeholder.svg';

export { PLACEHOLDER };

export function icon(name) {
	const ICONS = {
		star: `<path d="M12 17.27L18.18 21l1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z"/>`,
		check: `<polyline points="20 6 9 17 4 12"/>`,
		wifi: `<path d="M5 12.55a11 11 0 0114.08 0"/><path d="M1.42 9a16 16 0 0121.16 0"/><path d="M8.53 16.11a6 6 0 016.88 0"/><line x1="12" y1="20" x2="12.01" y2="20"/>`,
		pool: `<rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><path d="M3 9h18M3 15h18"/>`,
		bed: `<path d="M21 15V4a2 2 0 00-2-2H5a2 2 0 00-2 2v14l4-4h10l4 4z"/>`,
		wifi: ``,
		tag: `<path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 10V2h7.17a2 2 0 012.83 2.83z"/><line x1="7" y1="7" x2="7.01" y2="7"/>`,
		cup: `<path d="M5 7c0-1.885 1.587-3.414 3.539-3.906A15.8 15.8 0 0112 5c1.518 0 2.954.252 4.31.694A9.4 9.4 0 0118.5 7c0 1.885-1.587 3.414-3.539 3.906A15.8 15.8 0 0112 19c-1.518 0-2.954-.252-4.31-.694A9.4 9.4 0 015.5 7zM12 11a4 4 0 014 4v2a4 4 0 01-4 4H8a4 4 0 01-4-4v-2a4 4 0 014-4z"/>`,
		battery: `<rect x="2" y="7" width="20" height="10" rx="2" ry="2"/><path d="M23 11v-2"/>`,
		location: `<path d="M19.5 1.5C17.347 1.5 15.5 3.347 15.5 5.5C15.5 7.653 17.653 9.8 19.5 11.95C21.347 9.8 23.5 7.653 23.5 5.5C23.5 3.347 21.653 1.5 19.5 1.5ZM12 21.5L12 12L15.5 21.5"/>`,
		calendar: `<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>`,
		users: `<path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/>`,
		chevron: `<polyline points="9 18 15 12 9 6"/>`,
		'chevron-right': `<polyline points="9 6 15 12 9 18"/>`,
		close: `<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>`,
		heart: `<path d="M4 31C2.8 31 1.6 29.8 1.6 28.6C1.6 27.4 2.8 26.2 4 26.2C5.2 26.2 6.4 27.4 6.4 28.6C6.4 29.8 5.2 31 4 31ZM20 31C18.8 31 17.6 29.8 17.6 28.6C20 26.2 21.2 26.2 22.4 28.6C22.4 29.8 21.2 31 20 31ZM12 2C6.48 2 2 6.48 2 12C2 15.62 4.43 18.78 8 21.14C8.4 21.3 8.8 21.3 9.2 21.14C12.78 18.78 15.2 15.62 15.2 12C15.2 6.48 10.72 2 12 2Z"/>`,
		sparkles: `<path d="M21.29 10.71l-2.34-2.33-.54-.54-.53.54-.54.54-.54.53-.54.54.53.53-.54.53-.54.54-.54.53-.53.54-.53-.53.54-.53-.54-.54-.53-.53-.54-.54-.53l-2.33-2.33-2.33 2.33-.54.53-.53.54.53.53.54.54.54.54.53.54.54.54.54-.53.54-.53.54-.54 2.34 2.33 2.34-2.33-.54-.54-.54-.53-.53-.54-.53-.53-.54-.54-.54-.53-.54-.54-.54-.54-.53-.53-.54-.53-.54-.54-.53l2.33-2.34z"/>`,
		phone: `<path d="M15.554 4.554a4 4 0 010 5.657L8.708 13.5a2 2 0 00-2.828 2.828L1.554 17.22a4 4 0 010 5.657l5.364 5.363a2 2 0 002.828 2.828l11.314-11.313a4 4 0 010-5.657z"/>`,
		email: `<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>`,
		arrowRight: `<path d="M5 12h14M12 5l7 7-7 7"/>`,
		menu: `<line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/>`
	};
	const d = ICONS[name];
	if (!d) return '';
	return `<svg class="icon icon--${name}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${d}</svg>`;
}

export function createImage(src, alt, width, height) {
	const img = document.createElement('img');
	img.src = src;
	img.alt = alt;
	if (width) img.width = width;
	if (height) img.height = height;
	img.loading = 'lazy';
	img.decoding = 'async';
	img.onerror = () => {
		img.onerror = null;
		img.src = PLACEHOLDER;
		img.alt = alt || 'Stay image';
	};
	return img;
}

export function renderStars(rating) {
	const full = Math.floor(rating);
	const half = rating % 1 >= 0.5;
	let html = '';
	for (let i = 1; i <= 5; i += 1) {
		if (i <= full) html += icon('star');
		else if (i === full + 1 && half) html += `<svg class="icon icon--star" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 5.18 9.24l5-4.87L6.91 8.46z"/></svg>`;
		else html += `<svg class="icon icon--star icon--empty" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 5.18 9.24l5-4.87L6.91 8.46z"/></svg>`;
	}
	return html;
}

export function renderAmenityChips(amenities) {
	return amenities
		.map((amenity) => `<span class="amenity-chip" aria-label="${escapeHtml(amenity)}">${escapeHtml(amenity)}</span>`)
		.join('');
}

export function renderListingCard(listing, { link = true } = {}) {
	const price = formatMoney(listing.pricePerNight);
	const stars = renderStars(listing.rating);
	const name = escapeHtml(listing.name);
	const location = escapeHtml(listing.locationLabel);
	const badge = listing.badge ? `<span class="listing-card__badge">${escapeHtml(listing.badge)}</span>` : '';
	const imageHtml = listing.images && listing.images.length
		? `<img src="${escapeHtml(stripImageSize(listing.images[0]))}" alt="${name}" loading="lazy" onerror="this.src='${PLACEHOLDER}'">`
		: `<div class="placeholder-box" aria-hidden="true">${icon('building')}</div>`;
	const href = link ? `stay.html?id=${encodeURIComponent(listing.id)}` : '#';
	const reviews = listing.reviewCount ? ` <span>(${listing.reviewCount})</span>` : '';
	return `
		<a class="listing-card" href="${href}"${link ? '' : ' aria-disabled="true" tabindex="-1"'} style="text-decoration:none;color:inherit;">
			<div class="listing-card__media">${badge}${imageHtml}</div>
			<div class="listing-card__body">
				<div class="listing-card__eyebrow">${escapeHtml(listing.type.replace(/-/g, ' '))}</div>
				<h3>${name}</h3>
				<div class="listing-card__location">${icon('location')} <span>${location}</span></div>
				<div style="display:flex;align-items:center;gap:8px;margin:8px 0;">
					<div style="color:var(--leaf);font-weight:700;">${stars}</div>
					<div style="color:var(--ink-soft);font-size:13px;">${listing.rating.toFixed(1)}${reviews}</div>
				</div>
			</div>
			<div class="listing-card__footer">
				<div class="listing-card__price">${price}<span>/night</span></div>
			</div>
		</a>
	`;
}

export function renderListingGrid(container, listings, { link = true } = {}) {
	container.innerHTML = '';
	if (!listings || listings.length === 0) {
		container.innerHTML = `
			<div class="empty-state">
				<div class="empty-state__icon">${icon('stop-circle')}</div>
				<h2>No stays found</h2>
				<p>Try adjusting your dates, location, or guest count.</p>
			</div>
		`;
		return;
	}
	for (const listing of listings) {
		const article = document.createElement('article');
		article.className = 'listing-card';
		article.innerHTML = renderListingCard(listing, { link }).replace(/^<a[^>]*>/, '').replace(/<\/a>$/, '');
		// wrap back in anchor for link behavior
		const anchor = document.createElement('a');
		anchor.href = `stay.html?id=${encodeURIComponent(listing.id)}`;
		anchor.className = 'listing-card';
		anchor.append(...Array.from(article.children));
		container.appendChild(anchor);
	}
}

export function showToast(message, { actionLabel, onAction, duration = 4000 } = {}) {
	const region = document.getElementById('toast-region') || (() => {
		const r = document.createElement('div');
		r.id = 'toast-region';
		r.className = 'toast-region';
		document.body.appendChild(r);
		return r;
	})();
	const toast = document.createElement('div');
	toast.className = 'toast';
	toast.setAttribute('role', 'status');
	toast.setAttribute('aria-live', 'polite');
	const iconHtml = `<div class="toast__icon">${icon('check')}</div>`;
	const messageHtml = `<div class="toast__message">${escapeHtml(message)}</div>`;
	const actionHtml = actionLabel && onAction
		? `<button class="toast__action" type="button">${escapeHtml(actionLabel)}</button>`
		: '';
	toast.innerHTML = `${iconHtml}${messageHtml}${actionHtml}`;
	if (actionHtml) {
		const btn = toast.querySelector('.toast__action');
		btn.addEventListener('click', () => {
			onAction();
			region.removeChild(toast);
		});
	}
	region.appendChild(toast);
	const timer = setTimeout(() => {
		toast.remove();
	}, duration);
	return { element: toast, cancel: () => clearTimeout(timer) };
}

export function renderDateLabel(value) {
	return value ? formatDate(value) : 'Select date';
}

export function createGuestStepper({ name, value, min = 1, max = 10, onChange }) {
	const field = document.createElement('div');
	field.className = 'field';
	field.innerHTML = `
		<label>${escapeHtml(name)} <span>${escapeHtml(value)} guest${value !== 1 ? 's' : ''}</span></label>
		<div style="display:flex;align-items:center;gap:8px;">
			<button type="button" class="btn--small" aria-label="Decrease ${name}">&#8722;</button>
			<input type="number" name="${escapeHtml(name)}" value="${escapeHtml(value)}" min="${min}" max="${max}" style="width:48px;text-align:center;" readonly/>
			<button type="button" class="btn--small" aria-label="Increase ${name}">&#43;</button>
		</div>
	`;
	const minus = field.querySelector('button:first-of-type');
	const plus = field.querySelector('button:last-of-type');
	const input = field.querySelector('input');
	let current = value;
	const refresh = () => {
		input.value = current;
		field.querySelector('label span').textContent = current + ' guest' + (current !== 1 ? 's' : '');
		if (onChange) onChange(current);
	};
	minus.addEventListener('click', () => { if (current > min) { current -= 1; refresh(); } });
	plus.addEventListener('click', () => { if (current < max) { current += 1; refresh(); } });
	input.addEventListener('change', () => {
		const n = parseInt(input.value, 10);
		if (!Number.isNaN(n)) current = clamp(n, min, max);
		refresh();
	});
	return field;
}

function clamp(value, min, max) {
	return Math.min(Math.max(value, min), max);
}

export { clamp };

export function createBreadcrumb(items) {
	const nav = document.createElement('nav');
	nav.className = 'breadcrumb';
	nav.setAttribute('aria-label', 'Breadcrumb');
	const ol = document.createElement('ol');
	ol.style.display = 'flex';
	ol.style.alignItems = 'center';
	ol.style.gap = '8px';
	ol.style.padding = '0';
	ol.style.margin = '0';
	ol.style.listStyle = 'none';
	ol.style.fontSize = '13px';
	ol.style.color = 'var(--muted)';
	for (let i = 0; i < items.length; i += 1) {
		const item = items[i];
		const li = document.createElement('li');
		li.style.display = 'inline';
		if (i < items.length - 1 && item.url) {
			const a = document.createElement('a');
			a.href = item.url;
			a.textContent = item.label;
			a.style.color = 'var(--accent)';
			a.style.textDecoration = 'none';
			li.appendChild(a);
		} else {
			li.textContent = item.label;
			li.style.color = 'var(--ink)';
			li.style.fontWeight = '600';
		}
		if (i < items.length - 1) {
			const sep = document.createElement('span');
			sep.textContent = '/';
			sep.style.margin = '0 4px';
			sep.style.color = 'var(--muted)';
			li.appendChild(sep);
		}
		ol.appendChild(li);
	}
	nav.appendChild(ol);
	return nav;
}
