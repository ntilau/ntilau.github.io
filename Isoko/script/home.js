import { CATEGORIES, PRODUCTS, categoryCounts, getFeatured } from './catalog.js';
import { mountLayout } from './layout.js';
import { addToCart } from './store.js';
import { createCategoryTile, createImage, icon, renderProductGrid, showToast } from './ui.js';
import { createElement } from './utils.js';

mountLayout();

const counts = categoryCounts();
const totalCount = Object.values(counts).reduce((sum, count) => sum + count, 0);
const categoryGrid = document.getElementById('category-grid');
const featuredGrid = document.getElementById('featured-grid');
const moreGrid = document.getElementById('more-grid');
const heroCollage = document.getElementById('hero-collage');

function addProduct(product) {
	addToCart(product.id, 1);
	showToast(`${product.title} added to your cart.`, {
		actionLabel: 'View cart',
		actionHref: 'shoppingcart.html'
	});
}

if (categoryGrid) {
	for (const category of CATEGORIES) {
		categoryGrid.append(createCategoryTile(category, counts[category.slug] ?? 0));
	}

	const allTile = document.createElement('a');
	allTile.className = 'category-tile category-tile--all';
	allTile.href = 'shop.html';
	allTile.innerHTML = `
		<span class="category-tile__mark">${icon('package')}</span>
		<span class="category-tile__count">${totalCount} products</span>
		<h3>All products</h3>
		<p>Browse every shelf in the market, from everyday tech to car care.</p>
		<span class="category-tile__link">Shop the full market ${icon('arrow')}</span>
	`;
	categoryGrid.append(allTile);
}

const picks = getFeatured(8);

if (featuredGrid) {
	renderProductGrid(picks, featuredGrid, { onAdd: addProduct });
}

if (moreGrid) {
	const picksById = new Set(picks.map((product) => product.id));
	const more = PRODUCTS.filter((product) => !product.featured && !picksById.has(product.id)).slice(0, 8);
	renderProductGrid(more, moreGrid, { onAdd: addProduct });
}

if (heroCollage) {
	const collageProducts = getFeatured(3);

	for (const [index, product] of collageProducts.entries()) {
		const card = document.createElement('a');
		card.className = `collage-card${index === 0 ? ' collage-card--main' : ''}`;
		card.href = `openproduct.html?id=${encodeURIComponent(product.id)}`;
		card.append(
			createImage(product.images[0], product.title, {
				className: 'collage-card__image',
				eager: index === 0
			})
		);
		card.append(createElement('span', '', product.title));
		heroCollage.append(card);
	}
}
