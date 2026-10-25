import { mountLayout } from './layout.js';
import { buildBookingUrl, formatMoney, formatDate, formatNightCount, escapeHtml } from './utils.js';
import { getListingById, getRelated } from './listings.js';
import { createBooking, subscribeBooking } from './bookings.js';
import { renderStars, icon, createImage, PLACEHOLDER } from './ui.js';

export function initStay() {
	mountLayout({ currentPage: 'stays' });

	const params = new URLSearchParams(window.location.search);
	const id = params.get('id');
	const listing = id ? getListingById(id) : null;

	const notFound = document.getElementById('stay-not-found');
	const detail = document.getElementById('stay-detail');
	if (!listing) {
		if (notFound) notFound.hidden = false;
		if (detail) detail.hidden = true;
		return;
	}
	if (notFound) notFound.hidden = true;
	if (detail) detail.hidden = false;

	// Gallery
	const mainImage = document.getElementById('stay-main-image');
	const thumbs = document.getElementById('stay-thumbnails');
	const images = listing.images && listing.images.length ? listing.images : [PLACEHOLDER];

	if (mainImage) {
		mainImage.src = images[0];
		mainImage.alt = listing.name;
		mainImage.onerror = () => { mainImage.src = PLACEHOLDER; };
	}
	if (thumbs) {
		thumbs.innerHTML = '';
		images.forEach((src, index) => {
			const img = createImage(src, `${listing.name} image ${index + 1}`, 80, 80);
			img.className = index === 0 ? 'thumb thumb--active' : 'thumb';
			img.addEventListener('click', () => {
				mainImage.src = src;
				mainImage.alt = listing.name;
				for (const child of thumbs.children) child.classList.remove('thumb--active');
				img.classList.add('thumb--active');
			});
			thumbs.appendChild(img);
		});
	}

	// Header info
	elText('stay-name', listing.name);
	elText('stay-eyebrow', listing.type.replace(/-/g, ' '));
	elText('stay-location', listing.locationLabel);
	elText('stay-rating', `${listing.rating.toFixed(1)}`);
	elText('stay-reviews', listing.reviewCount ? `(${listing.reviewCount})` : '');
	elText('stay-description', listing.description);
	if (listing.badge) {
		const badge = document.getElementById('stay-badge');
		if (badge) { badge.textContent = listing.badge; badge.hidden = false; }
	}
	const starsEl = document.getElementById('stay-stars');
	if (starsEl) starsEl.innerHTML = renderStars(listing.rating);

	// Amenities
	const amenitiesEl = document.getElementById('stay-amenities');
	if (amenitiesEl && listing.amenities) {
		amenitiesEl.innerHTML = `<div class="amenity-wrap">${listing.amenities.map((a) => `<span class="amenity-chip" aria-label="${escapeHtml(a)}">${escapeHtml(a)}</span>`).join('')}</div>`;
	}

	// Booking box
	const priceEl = document.getElementById('stay-price');
	if (priceEl) priceEl.textContent = formatMoney(listing.pricePerNight);
	const checkIn = document.getElementById('booking-checkin');
	const checkOut = document.getElementById('booking-checkout');
	const guests = document.getElementById('booking-guests');
	const nightsEl = document.getElementById('booking-nights');
	const totalEl = document.getElementById('booking-total');
	const addBtn = document.getElementById('booking-add');

	const today = new Date(); today.setHours(0, 0, 0, 0);
	const min = today.toISOString().slice(0, 10);
	if (checkIn) checkIn.min = min;
	if (checkOut) checkOut.min = min;
	if (!checkIn.value) {
		const t = new Date(today); t.setDate(t.getDate() + 1);
		checkIn.value = t.toISOString().slice(0, 10);
	}
	if (!checkOut.value) {
		const t = new Date(); t.setDate(t.getDate() + 2);
		checkOut.value = t.toISOString().slice(0, 10);
	}

	function refreshTotals() {
		const ci = checkIn.value; const co = checkOut.value;
		let nights = 0; let total = 0;
		if (ci && co) {
			const a = new Date(ci); const b = new Date(co);
			if (!isNaN(a.getTime()) && !isNaN(b.getTime())) {
				nights = Math.max(0, Math.round((b - a) / 86400000));
				total = listing.pricePerNight * Math.max(1, nights);
			}
		}
		if (nightsEl) nightsEl.textContent = nights === 1 ? '1 night' : `${nights} nights`;
		if (totalEl) totalEl.textContent = formatMoney(total);
	}
	checkIn.addEventListener('change', refreshTotals);
	checkOut.addEventListener('change', refreshTotals);
	refreshTotals();

	// Subscribe to booking state for badge-like button text
	let unsub = subscribeBooking(() => { /* UI reflects latest via totals only */ });

	if (addBtn) {
		addBtn.addEventListener('click', () => {
			const ci = checkIn.value; const co = checkOut.value;
			if (!ci || !co) {
				showToastInline('Please select check-in and check-out dates.');
				return;
			}
			const created = createBooking({
				listing,
				checkIn: ci,
				checkOut: co,
				guests: guests ? guests.value : 2
			});
			showToastInline(`${escapeHtml(listing.name)} added to your booking.`, {
				actionLabel: 'Review booking',
				onAction: () => { window.location.href = 'booking.html'; }
			});
			unsub();
		});
	}

	// Related stays
	const relatedGrid = document.getElementById('related-grid');
	if (relatedGrid) {
		const related = getRelated(listing, 3);
		relatedGrid.innerHTML = '';
		for (const item of related) {
			const anchor = document.createElement('a');
			anchor.href = `stay.html?id=${encodeURIComponent(item.id)}`;
			anchor.className = 'listing-card';
			anchor.style.textDecoration = 'none';
			anchor.style.color = 'inherit';
			anchor.innerHTML = `
				<div class="listing-card__media">${item.badge ? `<span class="listing-card__badge">${escapeHtml(item.badge)}</span>` : ''}<img src="${escapeHtml(item.images && item.images.length ? item.images[0] : PLACEHOLDER)}" alt="${escapeHtml(item.name)}" loading="lazy" onerror="this.onerror=null;this.src='${PLACEHOLDER}'"></div>
				<div class="listing-card__body" style="padding:12px 14px 6px;">
					<div class="listing-card__eyebrow">${escapeHtml(item.type.replace(/-/g, ' '))}</div>
					<h3 style="margin:0 0 4px;font-size:14px;">${escapeHtml(item.name)}</h3>
					<div class="listing-card__location">${icon('location')} <span>${escapeHtml(item.locationLabel)}</span></div>
				</div>
				<div class="listing-card__footer" style="padding:6px 14px 14px;">
					<div class="listing-card__price">${formatMoney(item.pricePerNight)}<span>/night</span></div>
				</div>
			`;
			relatedGrid.appendChild(anchor);
		}
	}
}

function elText(id, text) {
	const el = document.getElementById(id);
	if (el) el.textContent = text;
}

function showToastInline(message, { actionLabel, onAction } = {}) {
	let region = document.getElementById('toast-region');
	if (!region) {
		region = document.createElement('div');
		region.id = 'toast-region';
		region.className = 'toast-region';
		document.body.appendChild(region);
	}
	const toast = document.createElement('div');
	toast.className = 'toast';
	toast.setAttribute('role', 'status');
	toast.setAttribute('aria-live', 'polite');
	const iconHtml = `<div class="toast__icon">${icon('check')}</div>`;
	const actionHtml = actionLabel && onAction ? `<button class="toast__action" type="button">${escapeHtml(actionLabel)}</button>` : '';
	toast.innerHTML = `${iconHtml}<div class="toast__message">${escapeHtml(message)}</div>${actionHtml}`;
	if (actionHtml) {
		toast.querySelector('.toast__action').addEventListener('click', () => { onAction(); region.removeChild(toast); });
	}
	region.appendChild(toast);
	setTimeout(() => toast.remove(), 4000);
}
