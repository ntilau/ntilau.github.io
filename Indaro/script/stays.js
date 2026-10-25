import { mountLayout } from './layout.js';
import {
	readStayState,
	buildStaysUrl,
	formatMoney,
	formatDate,
	formatNightCount,
	createElement,
	escapeHtml
} from './utils.js';
import {
	queryListings,
	LOCATIONS,
	PROPERTY_TYPES,
	SORT_OPTIONS,
	locationCounts,
	typeCounts,
	getListingById
} from './listings.js';
import { renderStars, renderAmenityChips, icon, PLACEHOLDER } from './ui.js';

export function initStays() {
	mountLayout({ currentPage: 'stays' });

	const state = readStayState();
	const form = document.getElementById('stays-filter');
	const locationSelect = document.getElementById('filter-location');
	const typeSelect = document.getElementById('filter-type');
	const sortSelect = document.getElementById('sort-select');
	const checkIn = document.getElementById('filter-checkin');
	const checkOut = document.getElementById('filter-checkout');
	const guests = document.getElementById('filter-guests');
	const resultsCount = document.getElementById('results-count');
	const grid = document.getElementById('results-grid');
	const chipsContainer = document.getElementById('active-chips');
	const clearBtn = document.getElementById('clear-filters');

	populate(locationSelect, LOCATIONS, 'location');
	populate(typeSelect, PROPERTY_TYPES, 'type');
	populate(sortSelect, SORT_OPTIONS, 'sort');

	locationSelect.value = state.location;
	typeSelect.value = state.type;
	sortSelect.value = state.sort || 'featured';
	checkIn.value = state.checkIn;
	checkOut.value = state.checkOut;
	guests.value = state.guests || '2';

	const minDate = new Date();
	minDate.setHours(0, 0, 0, 0);
	const min = minDate.toISOString().slice(0, 10);
	if (checkIn) checkIn.min = min;
	if (checkOut) checkOut.min = min;

	render();

	const inputs = [locationSelect, typeSelect, sortSelect, checkIn, checkOut, guests];
	for (const input of inputs) {
		input.addEventListener('change', () => {
			state.location = locationSelect.value;
			state.type = typeSelect.value;
			state.sort = sortSelect.value;
			state.checkIn = checkIn.value;
			state.checkOut = checkOut.value;
			state.guests = guests.value;
			history.replaceState(null, '', buildStaysUrl(state));
			render();
		});
		input.addEventListener('keydown', (event) => {
			if (event.key === 'Enter') event.preventDefault();
		});
	}

	if (clearBtn) {
		clearBtn.addEventListener('click', () => {
			locationSelect.value = '';
			typeSelect.value = '';
			sortSelect.value = 'featured';
			checkIn.value = '';
			checkOut.value = '';
			guests.value = '2';
			history.replaceState(null, '', 'stays.html');
			render();
		});
	}

	function render() {
		const { results, nights } = queryListings(state);
		if (resultsCount) {
			resultsCount.textContent = `${results.length} stay${results.length !== 1 ? 's' : ''}${
				nights ? ` &middot; ${formatNightCount(nights)} selected` : ''
			}`;
		}
		renderChips();
		renderGrid(results);
	}

	function renderChips() {
		if (!chipsContainer) return;
		chipsContainer.innerHTML = '';
		const chips = [];
		if (state.location) {
			const loc = LOCATIONS.find((l) => l.slug === state.location);
			chips.push({ label: loc ? loc.label : state.location, remove: 'location' });
		}
		if (state.type) {
			const t = PROPERTY_TYPES.find((t) => t.slug === state.type);
			chips.push({ label: t ? t.label : state.type, remove: 'type' });
		}
		if (state.checkIn) chips.push({ label: `From ${formatDate(state.checkIn)}`, remove: 'checkIn' });
		if (state.checkOut) chips.push({ label: `To ${formatDate(state.checkOut)}`, remove: 'checkOut' });
		if (state.guests && state.guests !== '2') chips.push({ label: `${state.guests} guests`, remove: 'guests' });
		if (state.sort && state.sort !== 'featured') chips.push({ label: `Sort: ${SORT_OPTIONS.find((s) => s.value === state.sort)?.label}`, remove: 'sort' });
		if (state.q) chips.push({ label: `Search: ${escapeHtml(state.q)}`, remove: 'q' });

		for (const chip of chips) {
			const el = document.createElement('button');
			el.className = 'chip chip--price';
			el.type = 'button';
			el.innerHTML = `${escapeHtml(chip.label)} <span class="chip__count" aria-hidden="true">×</span>`;
			el.title = `Remove ${chip.label}`;
			el.addEventListener('click', () => {
				state[chip.remove] = chip.remove === 'sort' ? 'featured' : '';
				history.replaceState(null, '', buildStaysUrl(state));
				render();
			});
			chipsContainer.appendChild(el);
		}
		chipsContainer.hidden = chips.length === 0;
	}

	function renderGrid(results) {
		if (!grid) return;
		grid.innerHTML = '';
		for (const listing of results) {
			const price = formatMoney(listing.pricePerNight);
			const stars = renderStars(listing.rating);
			const article = document.createElement('article');
			article.className = 'listing-card';
			const locationLabel = escapeHtml(listing.locationLabel);
			const imageSrc = escapeHtml(listing.images && listing.images.length ? listing.images[0] : PLACEHOLDER);
			article.innerHTML = `
				<a class="listing-card__link" href="stay.html?id=${encodeURIComponent(listing.id)}" style="display:block;inherit:inherit;text-decoration:none;color:inherit;height:100%;">
					<div class="listing-card__media">
						${listing.badge ? `<span class="listing-card__badge">${escapeHtml(listing.badge)}</span>` : ''}
						<img src="${imageSrc}" alt="${escapeHtml(listing.name)}" loading="lazy" onerror="this.onerror=null;this.src='${PLACEHOLDER}'">
					</div>
					<div class="listing-card__body">
						<div class="listing-card__eyebrow">${escapeHtml(listing.type.replace(/-/g, ' '))}</div>
						<h3>${escapeHtml(listing.name)}</h3>
						<div class="listing-card__location">${icon('location')} <span>${locationLabel}</span></div>
						<div style="display:flex;align-items:center;gap:8px;margin:8px 0 0;">
							<div style="color:var(--leaf);font-weight:700;">${stars}</div>
							<div style="color:var(--ink-soft);font-size:13px;">${listing.rating.toFixed(1)}${
								listing.reviewCount ? ` <span>(${listing.reviewCount})</span>` : ''
							}</div>
						</div>
					</div>
					<div class="listing-card__footer">
						<div class="listing-card__price">${price}<span>/night</span></div>
						<button class="btn btn--primary btn--small" type="button" style="margin-left:auto;">View</button>
					</div>
				</a>
			`;
			grid.appendChild(article);
		}
	}
}

function populate(select, items, valueKey) {
	if (!select) return;
	select.innerHTML = '<option value="">Any</option>';
	for (const item of items) {
		const option = document.createElement('option');
		option.value = item[valueKey] || item.value;
		option.textContent = item.label;
		select.appendChild(option);
	}
}
