import { CATEGORIES, SORT_OPTIONS, categoryCounts, getCategory, isValidSort, queryProducts } from './catalog.js';
import { mountLayout } from './layout.js';
import { addToCart } from './store.js';
import { renderEmptyState, renderProductGrid, showToast } from './ui.js';
import { buildShopUrl, createElement, debounce, readShopState } from './utils.js';

mountLayout();

const searchForm = document.getElementById('shop-search');
const searchInput = document.getElementById('shop-query');
const categoryChips = document.getElementById('category-chips');
const sortSelect = document.getElementById('sort-select');
const resultsCount = document.getElementById('results-count');
const productGrid = document.getElementById('product-grid');
const clearFilters = document.getElementById('clear-filters');

const counts = categoryCounts();
const initial = readShopState();
const state = {
	q: initial.q,
	category: getCategory(initial.category) ? initial.category : '',
	sort: isValidSort(initial.sort) ? initial.sort : 'featured'
};

if (searchInput) searchInput.value = state.q;

for (const option of SORT_OPTIONS) {
	const item = document.createElement('option');
	item.value = option.value;
	item.textContent = option.label;
	sortSelect?.append(item);
}

function renderChips() {
	if (!categoryChips) return;
	categoryChips.replaceChildren();

	const all = createElement('a', 'chip', 'All products');
	all.href = buildShopUrl({ q: state.q, sort: state.sort });
	all.dataset.category = '';
	all.append(createElement('span', 'chip__count', String(Object.values(counts).reduce((sum, n) => sum + n, 0))));
	if (!state.category) all.setAttribute('aria-current', 'page');
	categoryChips.append(all);

	for (const category of CATEGORIES) {
		const chip = createElement('a', 'chip', category.label);
		chip.href = buildShopUrl({ q: state.q, category: category.slug, sort: state.sort });
		chip.dataset.category = category.slug;
		chip.append(createElement('span', 'chip__count', String(counts[category.slug] ?? 0)));
		if (state.category === category.slug) chip.setAttribute('aria-current', 'page');
		categoryChips.append(chip);
	}
}

function renderResults() {
	const products = queryProducts(state);
	const category = getCategory(state.category);
	const filtersActive = Boolean(state.q || state.category || state.sort !== 'featured');

	if (resultsCount) {
		if (products.length) {
			let summary = `${products.length} ${products.length === 1 ? 'product' : 'products'}`;
			if (category) summary += ` in ${category.label}`;
			if (state.q) summary += ` for “${state.q}”`;
			resultsCount.textContent = summary;
		} else {
			resultsCount.textContent = 'No products match these filters.';
		}
	}

	if (clearFilters) clearFilters.hidden = !filtersActive;

	if (!products.length) {
		renderEmptyState(productGrid, {
			title: 'Nothing on this shelf',
			text: state.q
				? `We could not find anything matching “${state.q}”. Try a broader word or clear the filters.`
				: 'Try another category or clear the filters to see the whole market.',
			actionLabel: 'Clear filters',
			actionHref: 'shop.html',
			iconName: 'search'
		});
		return;
	}

	renderProductGrid(products, productGrid, {
		onAdd: (product) => {
			addToCart(product.id, 1);
			showToast(`${product.title} added to your cart.`, {
				actionLabel: 'View cart',
				actionHref: 'shoppingcart.html'
			});
		}
	});
}

function syncUrl() {
	const next = buildShopUrl(state);
	const current = `${window.location.pathname.split('/').pop() || 'shop.html'}${window.location.search}`;
	if (current !== next) window.history.replaceState(null, '', next);

	const category = getCategory(state.category);
	document.title = category ? `${category.label} — Isoko` : 'Shop the market — Isoko';
}

function update({ updateUrl = true } = {}) {
	state.q = state.q.trim();
	if (!getCategory(state.category)) state.category = '';
	if (!isValidSort(state.sort)) state.sort = 'featured';

	if (searchInput && searchInput.value !== state.q) searchInput.value = state.q;
	if (sortSelect) sortSelect.value = state.sort;

	renderChips();
	renderResults();
	if (updateUrl) syncUrl();
}

const applySearch = debounce(() => {
	state.q = searchInput?.value ?? '';
	update();
}, 220);

searchForm?.addEventListener('submit', (event) => {
	event.preventDefault();
	state.q = searchInput?.value ?? '';
	update();
	searchInput?.focus({ preventScroll: true });
});

searchInput?.addEventListener('input', applySearch);

sortSelect?.addEventListener('change', () => {
	state.sort = sortSelect.value;
	update();
});

clearFilters?.addEventListener('click', (event) => {
	event.preventDefault();
	state.q = '';
	state.category = '';
	state.sort = 'featured';
	if (searchInput) searchInput.value = '';
	update();
	searchInput?.focus({ preventScroll: true });
});

update();
