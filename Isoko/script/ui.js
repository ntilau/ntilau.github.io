import { buildProductUrl, createElement, formatMoney, clamp } from './utils.js';

export const FALLBACK_IMAGE = new URL('../assets/product-placeholder.svg', import.meta.url).href;

export const ICON_SPRITE = `
<svg class="icon-sprite" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false">
	<symbol id="icon-search" viewBox="0 0 24 24"><circle cx="11" cy="11" r="6.5" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="m16 16 4.5 4.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></symbol>
	<symbol id="icon-cart" viewBox="0 0 24 24"><path d="M3 4h2.2l1.5 10.2a2 2 0 0 0 2 1.7h8.9a2 2 0 0 0 2-1.6L21 8H6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><circle cx="9.5" cy="20" r="1.2" fill="currentColor"/><circle cx="18" cy="20" r="1.2" fill="currentColor"/></symbol>
	<symbol id="icon-menu" viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h16" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"/></symbol>
	<symbol id="icon-close" viewBox="0 0 24 24"><path d="m6 6 12 12M18 6 6 18" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"/></symbol>
	<symbol id="icon-chevron" viewBox="0 0 24 24"><path d="m9 5 7 7-7 7" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/></symbol>
	<symbol id="icon-arrow" viewBox="0 0 24 24"><path d="M4 12h15M13 6l6 6-6 6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></symbol>
	<symbol id="icon-check" viewBox="0 0 24 24"><path d="m5 12.5 4.5 4.5L19 7" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></symbol>
	<symbol id="icon-trash" viewBox="0 0 24 24"><path d="M4 7h16M9 7V4.5h6V7m-8.5 0 .8 12h9.4l.8-12M10 11v5M14 11v5" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></symbol>
	<symbol id="icon-minus" viewBox="0 0 24 24"><path d="M5 12h14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></symbol>
	<symbol id="icon-plus" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></symbol>
	<symbol id="icon-truck" viewBox="0 0 24 24"><path d="M3 6h10v10H3zM13 10h4l4 4v2h-8z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><circle cx="7" cy="18" r="1.8" fill="none" stroke="currentColor" stroke-width="1.7"/><circle cx="18" cy="18" r="1.8" fill="none" stroke="currentColor" stroke-width="1.7"/></symbol>
	<symbol id="icon-shield" viewBox="0 0 24 24"><path d="M12 3 4.5 6v5.5c0 4.8 3.2 8.2 7.5 9.5 4.3-1.3 7.5-4.7 7.5-9.5V6L12 3Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="m8.7 12 2.2 2.2 4.4-4.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></symbol>
	<symbol id="icon-package" viewBox="0 0 24 24"><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="m4.5 7.8 7.5 4.3 7.5-4.3M12 12v9" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></symbol>
	<symbol id="icon-camera" viewBox="0 0 24 24"><rect x="3" y="7" width="18" height="13" rx="2.5" fill="none" stroke="currentColor" stroke-width="1.7"/><path d="m8 7 1.3-2h5.4L16 7" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><circle cx="12" cy="13.5" r="3.5" fill="none" stroke="currentColor" stroke-width="1.7"/></symbol>
	<symbol id="icon-shirt" viewBox="0 0 24 24"><path d="m9 4-5 3 2.3 4L9 9.6V20h6V9.6l2.7 1.4L20 7l-5-3a3 3 0 0 1-6 0Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></symbol>
	<symbol id="icon-car" viewBox="0 0 24 24"><path d="m5 16-1-4.5L7 6h10l3 5.5-1 4.5H5Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="M4 16h16v3h-3v-2H7v2H4v-3Z" fill="currentColor" opacity=".9"/><circle cx="7.5" cy="12" r="1" fill="currentColor"/><circle cx="16.5" cy="12" r="1" fill="currentColor"/></symbol>
	<symbol id="icon-leaf" viewBox="0 0 24 24"><path d="M20 4C11 4 5 8 5 15a6 6 0 0 0 6 6c7 0 9-9 9-17Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="M4 21c2-6 6-10 12-13" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></symbol>
	<symbol id="icon-bag" viewBox="0 0 24 24"><path d="M5 8h14l-1 12H6L5 8Z" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/><path d="M9 9V6a3 3 0 0 1 6 0v3" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></symbol>
</svg>`;

export function icon(name, className = 'icon') {
	return `<svg class="${className}" aria-hidden="true" focusable="false"><use href="#icon-${name}"></use></svg>`;
}

export function attachImageFallback(image) {
	const fallback = () => {
		if (image.dataset.fallback === '1') return;
		image.dataset.fallback = '1';
		image.src = FALLBACK_IMAGE;
		image.classList.add('is-fallback');
	};

	if (image.complete && image.naturalWidth === 0) {
		fallback();
	} else {
		image.addEventListener('error', fallback, { once: true });
	}
}

export function createImage(src, alt, { className = '', eager = false } = {}) {
	const image = document.createElement('img');
	image.src = src || FALLBACK_IMAGE;
	image.alt = alt;
	image.className = className;
	image.loading = eager ? 'eager' : 'lazy';
	image.decoding = 'async';
	if (eager) image.fetchPriority = 'high';
	attachImageFallback(image);
	return image;
}

export function productCard(product, { onAdd } = {}) {
	const card = createElement('article', 'product-card');
	card.dataset.productId = product.id;

	const mediaLink = document.createElement('a');
	mediaLink.className = 'product-card__media';
	mediaLink.href = buildProductUrl(product.id);
	mediaLink.setAttribute('aria-label', `View ${product.title}`);
	mediaLink.append(createImage(product.images[0], product.title, { className: 'product-card__image' }));

	if (product.badge) {
		mediaLink.append(createElement('span', 'product-card__badge', product.badge));
	}

	const body = createElement('div', 'product-card__body');
	const eyebrow = createElement(
		'p',
		'product-card__eyebrow',
		`${product.categoryLabel} · ${product.subcategory}`
	);

	const heading = document.createElement('h3');
	heading.className = 'product-card__title';
	const titleLink = document.createElement('a');
	titleLink.href = buildProductUrl(product.id);
	titleLink.textContent = product.title;
	heading.append(titleLink);

	const meta = createElement('div', 'product-card__meta');
	const price = createElement('strong', 'product-card__price', formatMoney(product.price));
	const stock = createElement(
		'span',
		`product-card__stock${product.stock <= 3 ? ' is-low' : ''}`,
		product.stock <= 3 ? `Only ${product.stock} left` : 'In stock'
	);
	meta.append(price, stock);

	const addButton = document.createElement('button');
	addButton.type = 'button';
	addButton.className = 'btn btn--primary btn--small product-card__add';
	addButton.dataset.addToCart = product.id;
	addButton.setAttribute('aria-label', `Add ${product.title} to cart`);
	addButton.innerHTML = `${icon('plus')}<span>Add to cart</span>`;
	addButton.addEventListener('click', () => onAdd?.(product));

	body.append(eyebrow, heading, meta, addButton);
	card.append(mediaLink, body);
	return card;
}

export function renderProductGrid(products, container, options = {}) {
	container.replaceChildren();

	if (!products.length) {
		renderEmptyState(container, {
			title: 'No products found',
			text: 'Try a different search or browse the full market.',
			actionLabel: 'Clear filters',
			actionHref: 'shop.html',
			iconName: 'search'
		});
		return;
	}

	const fragment = document.createDocumentFragment();
	for (const product of products) fragment.append(productCard(product, options));
	container.append(fragment);
}

export function renderEmptyState(container, { title, text, actionLabel, actionHref, iconName = 'package' }) {
	const panel = createElement('div', 'empty-state');
	const mark = createElement('span', 'empty-state__icon');
	mark.innerHTML = icon(iconName);
	panel.append(mark, createElement('h2', '', title), createElement('p', '', text));

	if (actionLabel && actionHref) {
		const action = document.createElement('a');
		action.className = 'btn btn--primary';
		action.href = actionHref;
		action.textContent = actionLabel;
		panel.append(action);
	}

	container.replaceChildren(panel);
}

export function createCategoryTile(category, count) {
	const tile = document.createElement('a');
	tile.className = 'category-tile';
	tile.href = `shop.html?category=${encodeURIComponent(category.slug)}`;
	tile.style.setProperty('--category-accent', category.accent);
	tile.innerHTML = `
		<span class="category-tile__mark">${icon(category.icon)}</span>
		<span class="category-tile__count">${count} ${count === 1 ? 'product' : 'products'}</span>
		<h3>${category.label}</h3>
		<p>${category.blurb}</p>
		<span class="category-tile__link">Browse ${category.label} ${icon('arrow')}</span>
	`;
	return tile;
}

export function createQuantityStepper({
	value = 1,
	min = 1,
	max = 99,
	label = 'Quantity',
	onChange = () => {}
} = {}) {
	const wrapper = createElement('div', 'quantity-stepper');
	const minus = document.createElement('button');
	minus.type = 'button';
	minus.className = 'quantity-stepper__button';
	minus.setAttribute('aria-label', `Decrease ${label.toLowerCase()}`);
	minus.innerHTML = icon('minus');

	const input = document.createElement('input');
	input.type = 'number';
	input.className = 'quantity-stepper__input';
	input.min = String(min);
	input.max = String(max);
	input.step = '1';
	input.value = String(clamp(value, min, max));
	input.setAttribute('aria-label', label);
	input.inputMode = 'numeric';

	const plus = document.createElement('button');
	plus.type = 'button';
	plus.className = 'quantity-stepper__button';
	plus.setAttribute('aria-label', `Increase ${label.toLowerCase()}`);
	plus.innerHTML = icon('plus');

	const setValue = (next, emit = true) => {
		const quantity = parseQuantity(next, min, max);
		input.value = String(quantity);
		minus.disabled = quantity <= min;
		plus.disabled = quantity >= max;
		if (emit) onChange(quantity);
		return quantity;
	};

	minus.addEventListener('click', () => setValue(Number(input.value) - 1));
	plus.addEventListener('click', () => setValue(Number(input.value) + 1));
	input.addEventListener('change', () => setValue(input.value));
	input.addEventListener('blur', () => {
		if (!input.value) setValue(min);
	});

	wrapper.append(minus, input, plus);
	setValue(value, false);
	return { element: wrapper, getValue: () => parseQuantity(input.value, min, max), setValue };
}

let toastTimer = 0;

export function showToast(message, { actionLabel = '', actionHref = '', duration = 5000 } = {}) {
	const region = document.getElementById('toast-region');
	if (!region) return;

	window.clearTimeout(toastTimer);
	region.replaceChildren();

	const toast = createElement('div', 'toast');
	toast.innerHTML = `<span class="toast__icon">${icon('check')}</span>`;

	const text = createElement('span', 'toast__text', message);
	toast.append(text);

	if (actionLabel && actionHref) {
		const action = document.createElement('a');
		action.className = 'toast__action';
		action.href = actionHref;
		action.textContent = actionLabel;
		toast.append(action);
	}

	const close = document.createElement('button');
	close.type = 'button';
	close.className = 'toast__close';
	close.setAttribute('aria-label', 'Dismiss notification');
	close.innerHTML = icon('close');
	close.addEventListener('click', () => dismiss());
	toast.append(close);

	const dismiss = () => {
		window.clearTimeout(toastTimer);
		toast.classList.remove('is-visible');
		window.setTimeout(() => toast.remove(), 220);
	};

	region.append(toast);
	requestAnimationFrame(() => toast.classList.add('is-visible'));
	toastTimer = window.setTimeout(dismiss, duration);
}

function parseQuantity(value, min, max) {
	const number = Number.parseInt(String(value), 10);
	if (!Number.isFinite(number)) return min;
	return clamp(number, min, max);
}
