const moneyFormatter = new Intl.NumberFormat('en-IN', {
	style: 'currency',
	currency: 'INR',
	minimumFractionDigits: 2,
	maximumFractionDigits: 2
});

const dateFormatter = new Intl.DateTimeFormat('en-IN', {
	dateStyle: 'medium'
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

export function parseQuantity(value, min = 1, max = 99) {
	const number = Number.parseInt(String(value), 10);
	if (!Number.isFinite(number)) return min;
	return clamp(number, min, max);
}

export function stripImageSize(url) {
	return String(url).replace(/_(?:50x50|220x220)\.(?:jpg|jpeg|png)$/i, '');
}

export function buildShopUrl({ q = '', category = '', sort = '' } = {}) {
	const params = new URLSearchParams();
	const query = q.trim();

	if (category) params.set('category', category);
	if (query) params.set('q', query);
	if (sort && sort !== 'featured') params.set('sort', sort);

	const search = params.toString();
	return search ? `shop.html?${search}` : 'shop.html';
}

export function buildProductUrl(id) {
	return `openproduct.html?id=${encodeURIComponent(id)}`;
}

export function readShopState(search = window.location.search) {
	const params = new URLSearchParams(search);
	return {
		q: (params.get('q') ?? '').trim(),
		category: (params.get('category') ?? '').trim(),
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
