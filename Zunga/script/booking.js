import { mountLayout } from './layout.js';
import {
	formatMoney, formatDate, formatNightCount, escapeHtml, createElement
} from './utils.js';
import { getListingById } from './listings.js';
import { createBooking, getBooking, clearBooking, subscribeBooking } from './bookings.js';
import { icon } from './ui.js';

export function initBooking() {
	mountLayout({ currentPage: 'booking' });

	const params = new URLSearchParams(window.location.search);
	const id = params.get('id');
	const ordered = params.has('ordered');

	const listing = id ? getListingById(id) : null;

	const formView = document.getElementById('booking-form-view');
	const confirmView = document.getElementById('booking-confirm-view');

	if (ordered) {
		if (formView) formView.hidden = true;
		if (confirmView) confirmView.hidden = false;
		renderConfirmation();
		return;
	}

	if (formView) formView.hidden = false;
	if (confirmView) confirmView.hidden = true;

	const listingName = document.getElementById('booking-listing-name');
	const listingPrice = document.getElementById('booking-listing-price');
	const checkIn = document.getElementById('order-checkin');
	const checkOut = document.getElementById('order-checkout');
	const guests = document.getElementById('order-guests');
	const nightsEl = document.getElementById('order-nights');
	const subtotalEl = document.getElementById('order-subtotal');
	const totalEl = document.getElementById('order-total');
	const form = document.getElementById('booking-form');

	if (listing && listingName) listingName.textContent = listing.name;
	if (listing && listingPrice) listingPrice.textContent = formatMoney(listing.pricePerNight);

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

	function refresh() {
		const ci = checkIn.value; const co = checkOut.value;
		let nights = 0; let total = 0;
		if (listing && ci && co) {
			const a = new Date(ci); const b = new Date(co);
			if (!isNaN(a.getTime()) && !isNaN(b.getTime())) {
				nights = Math.max(0, Math.round((b - a) / 86400000));
				total = listing.pricePerNight * Math.max(1, nights);
			}
		}
		if (nightsEl) nightsEl.textContent = nights === 1 ? '1 night' : `${nights} nights`;
		if (subtotalEl) subtotalEl.textContent = formatMoney(total);
		if (totalEl) totalEl.textContent = formatMoney(total);
	}
	checkIn.addEventListener('change', refresh);
	checkOut.addEventListener('change', refresh);
	guests.addEventListener('change', refresh);
	refresh();

	if (form) {
		form.addEventListener('submit', (event) => {
			event.preventDefault();
			if (!listing) {
				showToastInline('This stay is not available.');
				return;
			}
			const name = document.getElementById('order-name').value.trim();
			const email = document.getElementById('order-email').value.trim();
			const phone = document.getElementById('order-phone').value.trim();
			const notes = document.getElementById('order-notes').value.trim();

			if (!name || !email) {
				showToastInline('Please enter your name and email.');
				return;
			}
			if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
				showToastInline('Please enter a valid email address.');
				return;
			}

			const ci = checkIn.value; const co = checkOut.value;
			const created = createBooking({
				listing,
				checkIn: ci,
				checkOut: co,
				guests: guests ? guests.value : 2,
				customer: { name, email, phone },
				notes
			});

			clearBooking();
			window.location.href = `booking.html?id=${encodeURIComponent(listing.id)}&ordered=1`;
		});
	}
}

function renderConfirmation() {
	const booking = getBooking();
	const orderNumber = document.getElementById('confirm-order-number');
	const orderDate = document.getElementById('confirm-order-date');
	const confirmListing = document.getElementById('confirm-listing');
	const confirmNights = document.getElementById('confirm-nights');
	const confirmGuests = document.getElementById('confirm-guests');
	const confirmTotal = document.getElementById('confirm-total');

	if (orderNumber) orderNumber.textContent = booking.orderNumber || '—';
	if (orderDate && booking.createdAt) orderDate.textContent = formatDate(booking.createdAt);
	if (confirmListing && booking.listing) confirmListing.textContent = booking.listing.name;
	if (confirmNights) confirmNights.textContent = booking.nights === 1 ? '1 night' : `${booking.nights} nights`;
	if (confirmGuests) confirmGuests.textContent = `${booking.guests} guest${booking.guests !== 1 ? 's' : ''}`;
	if (confirmTotal) confirmTotal.textContent = formatMoney(booking.total);

	const customerName = document.getElementById('confirm-customer');
	const customerEmail = document.getElementById('confirm-email');
	if (customerName) customerName.textContent = booking.customer.name || '—';
	if (customerEmail) customerEmail.textContent = booking.customer.email || '—';
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
