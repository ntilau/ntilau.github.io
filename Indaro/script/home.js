import { mountLayout } from './layout.js';
import { buildStaysUrl, createElement } from './utils.js';
import { getFeatured } from './listings.js';
import { renderListingCard, icon, PLACEHOLDER } from './ui.js';

export function initHome() {
	mountLayout({ currentPage: 'home' });

	const form = document.getElementById('hero-search');
	const locationSelect = document.getElementById('hero-location');
	const checkIn = document.getElementById('hero-checkin');
	const checkOut = document.getElementById('hero-checkout');
	const guests = document.getElementById('hero-guests');

	if (locationSelect) {
		const { LOCATIONS } = getLocationsModule();
		for (const location of LOCATIONS) {
			const option = document.createElement('option');
			option.value = location.slug;
			option.textContent = location.label;
			locationSelect.appendChild(option);
		}
	}

	todayMinInputs(checkIn, checkOut);

	if (form) {
		form.addEventListener('submit', (event) => {
			event.preventDefault();
			const params = {};
			if (locationSelect && locationSelect.value) params.location = locationSelect.value;
			if (checkIn.value) params.checkIn = checkIn.value;
			if (checkOut.value) params.checkOut = checkOut.value;
			if (guests.value && guests.value !== '2') params.guests = guests.value;
			window.location.href = buildStaysUrl(params);
		});
	}

	renderFeatured();
}

function getLocationsModule() {
	// imported at top via listings module to avoid circular concerns
	return { LOCATIONS: window.__INDARO_LOCATIONS || [] };
}

function todayMinInputs(checkIn, checkOut) {
	const today = new Date();
	today.setHours(0, 0, 0, 0);
	const min = today.toISOString().slice(0, 10);
	if (checkIn) checkIn.min = min;
	if (checkOut) checkOut.min = min;
	const tomorrow = new Date(today);
	tomorrow.setDate(tomorrow.getDate() + 1);
	if (!checkIn.value) checkIn.value = tomorrow.toISOString().slice(0, 10);
	if (!checkOut.value) {
		const t2 = new Date(tomorrow);
		t2.setDate(t2.getDate() + 1);
		checkOut.value = t2.toISOString().slice(0, 10);
	}
}

function renderFeatured() {
	const grid = document.getElementById('featured-grid');
	if (!grid) return;
	const featured = getFeatured(6);
	if (!featured || featured.length === 0) {
		grid.innerHTML = '<p class="empty-hint">No featured stays available.</p>';
		return;
	}
	grid.innerHTML = '';
	for (const listing of featured) {
		grid.appendChild(cardElement(listing));
	}
}

function cardElement(listing) {
	const wrapper = document.createElement('div');
	wrapper.className = 'listing-card';
	wrapper.innerHTML = renderListingCard(listing).replace(/^<a[^>]*>/, '').replace(/<\/a>$/, '');
	const anchor = document.createElement('a');
	anchor.href = `stay.html?id=${encodeURIComponent(listing.id)}`;
	anchor.className = 'listing-card';
	anchor.append(...Array.from(wrapper.children));
	return anchor;
}
