import { PRODUCTS, getProductById } from './catalog.js';
import { normalizeText, parseQuantity, roundMoney } from './utils.js';

export const CART_KEY = 'isoko:cart:v1';
export const ORDER_KEY = 'isoko:last-order:v1';
export const FLAT_SHIPPING = 499;
export const FREE_SHIPPING_AT = 10000;

const LEGACY_CART_KEY = 'alibabacart';
const LEGACY_DETAIL_KEYS = ['openedProduct', 'details_prod'];
const TITLE_LOOKUP = new Map(PRODUCTS.map((product) => [normalizeText(product.title), product]));

let storage = null;
let memoryCart = { v: 1, items: [] };
let memoryOrder = null;
let migrationChecked = false;

try {
	const testKey = '__isoko_storage_test__';
	window.localStorage.setItem(testKey, '1');
	window.localStorage.removeItem(testKey);
	storage = window.localStorage;
} catch {
	storage = null;
}

function emptyCart() {
	return { v: 1, items: [] };
}

function sanitizeItems(items) {
	const merged = new Map();

	for (const item of Array.isArray(items) ? items : []) {
		if (!item || typeof item !== 'object') continue;

		const product = getProductById(item.id);
		if (!product) continue;

		const quantity = parseQuantity(item.qty ?? item.quantity ?? 1, 1, product.stock);
		const existing = merged.get(product.id);
		const addedAt = Number.isFinite(Number(item.addedAt)) ? Number(item.addedAt) : Date.now();

		merged.set(product.id, {
			id: product.id,
			qty: Math.min(product.stock, (existing?.qty ?? 0) + quantity),
			addedAt: existing?.addedAt ?? addedAt
		});
	}

	return [...merged.values()];
}

function parseCart(raw) {
	if (!raw) return null;

	try {
		const parsed = JSON.parse(raw);
		const items = Array.isArray(parsed) ? parsed : parsed?.items;
		if (!Array.isArray(items)) return null;
		return { v: 1, items: sanitizeItems(items) };
	} catch {
		return null;
	}
}

function persist(cart, { silent = false } = {}) {
	const normalized = { v: 1, items: sanitizeItems(cart?.items) };
	memoryCart = normalized;

	if (storage) {
		try {
			storage.setItem(CART_KEY, JSON.stringify(normalized));
		} catch {
			storage = null;
		}
	}

	if (!silent) {
		window.dispatchEvent(new CustomEvent('isoko:cart-change', { detail: getTotals() }));
	}

	return normalized;
}

function migrateLegacyCart() {
	if (migrationChecked) return;
	migrationChecked = true;
	if (!storage) return;

	try {
		const raw = storage.getItem(LEGACY_CART_KEY);
		const legacy = raw ? JSON.parse(raw) : null;
		const legacyItems = Array.isArray(legacy) ? legacy : legacy?.items;

		if (Array.isArray(legacyItems)) {
			const migrated = [];

			for (const item of legacyItems) {
				const title = item?.productTitle ?? item?.title ?? item?.name;
				const product = TITLE_LOOKUP.get(normalizeText(title));
				if (!product) continue;

				migrated.push({
					id: product.id,
					qty: parseQuantity(item?.qty ?? item?.quantity ?? 1, 1, product.stock),
					addedAt: Date.now()
				});
			}

			if (migrated.length) persist({ v: 1, items: migrated }, { silent: true });
		}

		storage.removeItem(LEGACY_CART_KEY);
		for (const key of LEGACY_DETAIL_KEYS) storage.removeItem(key);
	} catch {
		try {
			storage?.removeItem(LEGACY_CART_KEY);
		} catch {
			// Ignore storage failures; the cart simply starts empty.
		}
	}
}

export function getCart() {
	if (!storage) {
		migrateLegacyCart();
		return { v: 1, items: sanitizeItems(memoryCart.items) };
	}

	let raw = null;
	try {
		raw = storage.getItem(CART_KEY);
	} catch {
		storage = null;
		return { v: 1, items: sanitizeItems(memoryCart.items) };
	}

	if (!raw) {
		migrateLegacyCart();
		try {
			raw = storage.getItem(CART_KEY);
		} catch {
			storage = null;
		}
	}

	const parsed = parseCart(raw);
	if (parsed) return parsed;

	return { v: 1, items: [] };
}

export function getCartLines() {
	return getCart()
		.items.map((item) => {
			const product = getProductById(item.id);
			if (!product) return null;
			return {
				product,
				qty: item.qty,
				lineTotal: roundMoney(product.price * item.qty)
			};
		})
		.filter(Boolean);
}

export function getCartCount() {
	return getCartLines().reduce((total, line) => total + line.qty, 0);
}

export function getSubtotal() {
	return roundMoney(getCartLines().reduce((total, line) => total + line.lineTotal, 0));
}

export function getShipping(subtotal = getSubtotal()) {
	if (subtotal <= 0) return 0;
	return subtotal >= FREE_SHIPPING_AT ? 0 : FLAT_SHIPPING;
}

export function getTotals() {
	const lines = getCartLines();
	const subtotal = roundMoney(lines.reduce((total, line) => total + line.lineTotal, 0));
	const count = lines.reduce((total, line) => total + line.qty, 0);
	const shipping = getShipping(subtotal);

	return {
		count,
		subtotal,
		shipping,
		total: roundMoney(subtotal + shipping),
		lines
	};
}

export function addToCart(id, quantity = 1) {
	const product = getProductById(id);
	if (!product) return getCart();

	const cart = getCart();
	const existing = cart.items.find((item) => item.id === id);
	const requested = parseQuantity(quantity, 1, product.stock);

	if (existing) {
		existing.qty = Math.min(product.stock, existing.qty + requested);
	} else {
		cart.items.push({ id, qty: requested, addedAt: Date.now() });
	}

	return persist(cart);
}

export function setQuantity(id, quantity) {
	const product = getProductById(id);
	if (!product) return getCart();

	const cart = getCart();
	const qty = parseQuantity(quantity, 0, product.stock);
	const existing = cart.items.find((item) => item.id === id);

	if (!existing) return cart;

	if (qty <= 0) {
		cart.items = cart.items.filter((item) => item.id !== id);
	} else {
		existing.qty = qty;
	}

	return persist(cart);
}

export function removeFromCart(id) {
	const cart = getCart();
	cart.items = cart.items.filter((item) => item.id !== id);
	return persist(cart);
}

export function clearCart() {
	return persist(emptyCart());
}

function dateStamp(date = new Date()) {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, '0');
	const day = String(date.getDate()).padStart(2, '0');
	return `${year}${month}${day}`;
}

export function generateOrderNumber() {
	let token = '';

	try {
		const values = new Uint32Array(1);
		window.crypto.getRandomValues(values);
		token = values[0].toString(36).toUpperCase().padStart(4, '0').slice(-4);
	} catch {
		token = Math.random().toString(36).slice(2, 6).toUpperCase().padEnd(4, '0');
	}

	return `ISK-${dateStamp()}-${token}`;
}

export function saveOrder(customer) {
	const lines = getCartLines();
	if (!lines.length) return null;

	const subtotal = roundMoney(lines.reduce((total, line) => total + line.lineTotal, 0));
	const shipping = getShipping(subtotal);
	const order = {
		orderNumber: generateOrderNumber(),
		placedAt: new Date().toISOString(),
		customer: { ...customer },
		items: lines.map((line) => ({
			id: line.product.id,
			title: line.product.title,
			price: line.product.price,
			qty: line.qty,
			lineTotal: line.lineTotal
		})),
		count: lines.reduce((total, line) => total + line.qty, 0),
		subtotal,
		shipping,
		total: roundMoney(subtotal + shipping)
	};

	memoryOrder = order;

	if (storage) {
		try {
			storage.setItem(ORDER_KEY, JSON.stringify(order));
		} catch {
			storage = null;
		}
	}

	return order;
}

export function getLastOrder() {
	if (storage) {
		try {
			const raw = storage.getItem(ORDER_KEY);
			if (raw) {
				const parsed = JSON.parse(raw);
				if (parsed && typeof parsed.orderNumber === 'string' && Array.isArray(parsed.items)) {
					return parsed;
				}
			}
		} catch {
			return memoryOrder;
		}
	}

	return memoryOrder;
}

export function subscribeCart(listener) {
	const onCartChange = () => listener(getTotals());
	const onStorage = (event) => {
		if (event.key === CART_KEY || event.key === null) onCartChange();
	};

	window.addEventListener('isoko:cart-change', onCartChange);
	window.addEventListener('storage', onStorage);

	return () => {
		window.removeEventListener('isoko:cart-change', onCartChange);
		window.removeEventListener('storage', onStorage);
	};
}

// Kept for tests and diagnostics without exporting the raw storage object.
export function hasPersistentStorage() {
	return Boolean(storage);
}
