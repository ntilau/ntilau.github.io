const moneyFormatter = new Intl.NumberFormat('en-US', {
	style: 'currency',
	currency: 'USD',
	minimumFractionDigits: 2,
	maximumFractionDigits: 2
});

const dateFormatter = new Intl.DateTimeFormat('en-US', {
	weekday: 'short',
	month: 'short',
	day: 'numeric'
});

const dateInputFormatter = new Intl.DateTimeFormat('en-US', {
	year: 'numeric',
	month: '2-digit',
	day: '2-digit'
});

export function roundMoney(value) {
	return Math.round((Number(value) + Number.EPSILON) * 100) / 100;
}

export function formatMoney(value) {
	return moneyFormatter.format(roundMoney(value));
}

export function formatDate(value) {
	const date = new Date(value);
	return Number.isNaN(date.getTime()) ? '' : dateFormatter.format(date);
}

export function formatDateInput(value) {
	const date = new Date(value);
	return Number.isNaN(date.getTime()) ? '' : dateInputFormatter.format(date);
}

export function normalizeText(value) {
	return String(value ?? '')
		.toLowerCase()
		.normalize('NFKD')
		.replace(/[̀-ͯ]/g, '')
		.replace(/[^a-z0-9]+/g, ' ')
		.trim();
}

export function escapeHtml(value) {
	return String(value ?? '').replace(
		/[&<>"']/g,
		(character) =>
			({
				'&': '&amp;',
				'<': '&lt;',
				'>': '&gt;',
				'"': '&quot;',
				"'": '&#39;'
			})[character]
	);
}

export function clamp(value, min, max) {
	return Math.min(Math.max(value, min), max);
}

export function parseNights(checkIn, checkOut) {
	const start = new Date(checkIn);
	const end = new Date(checkOut);
	if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return 0;
	const ms = end.getTime() - start.getTime();
	return Math.max(0, Math.round(ms / 86400000));
}

export function parseGuests(value, min = 1, max = 10) {
	const number = Number.parseInt(String(value), 10);
	if (!Number.isFinite(number)) return min;
	return clamp(number, min, max);
}

export function stripImageSize(url) {
	return String(url).replace(/_(?:50x50|220x220)\.(?:jpg|jpeg|png)$/i, '');
}

export function buildStaysUrl({ q = '', location = '', type = '', checkIn = '', checkOut = '', guests = '', sort = '' } = {}) {
	const params = new URLSearchParams();
	if (q.trim()) params.set('q', q.trim());
	if (location) params.set('location', location);
	if (type) params.set('type', type);
	if (checkIn) params.set('checkIn', checkIn);
	if (checkOut) params.set('checkOut', checkOut);
	if (guests && guests !== '2') params.set('guests', guests);
	if (sort && sort !== 'featured') params.set('sort', sort);
	const search = params.toString();
	return search ? `stays.html?${search}` : 'stays.html';
}

export function buildListingUrl(id) {
	return `stay.html?id=${encodeURIComponent(id)}`;
}

export function buildBookingUrl(id) {
	return `booking.html?id=${encodeURIComponent(id)}`;
}

export function readStayState(search = window.location.search) {
	const params = new URLSearchParams(search);
	return {
		q: (params.get('q') ?? '').trim(),
		location: (params.get('location') ?? '').trim(),
		type: (params.get('type') ?? '').trim(),
		checkIn: (params.get('checkIn') ?? '').trim(),
		checkOut: (params.get('checkOut') ?? '').trim(),
		guests: (params.get('guests') ?? '').trim(),
		sort: (params.get('sort') ?? '').trim()
	};
}

export function debounce(callback, delay = 180) {
	let timer = 0;
	return (...args) => {
		window.clearTimeout(timer);
		timer = window.setTimeout(() => callback(...args), delay);
	};
}

export function createElement(tag, className, text) {
	const element = document.createElement(tag);
	if (className) element.className = className;
	if (text !== undefined) element.textContent = text;
	return element;
}

export function formatNightCount(nights) {
	return nights === 1 ? '1 night' : `${nights} nights`;
}
