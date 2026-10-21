import { CATEGORIES, categoryCounts, getFeatured } from './catalog.js';
import { mountLayout } from './layout.js';
import { addToCart } from './store.js';
import { createCategoryTile, createImage, renderProductGrid, showToast } from './ui.js';
import { createElement } from './utils.js';

mountLayout();

const counts = categoryCounts();
const categoryGrid = document.getElementById('category-grid');
const featuredGrid = document.getElementById('featured-grid');
const heroCollage = document.getElementById('hero-collage');

if (categoryGrid) {
	for (const category of CATEGORIES) {
		categoryGrid.append(createCategoryTile(category, counts[category.slug] ?? 0));
	}
}

const picks = getFeatured(8);

if (featuredGrid) {
	renderProductGrid(picks, featuredGrid, {
		onAdd: (product) => {
			addToCart(product.id, 1);
			showToast(`${product.title} added to your cart.`, {
				actionLabel: 'View cart',
				actionHref: 'shoppingcart.html'
			});
		}
	});
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
