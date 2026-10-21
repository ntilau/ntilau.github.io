import { getCategory, getProductById, getRelated } from './catalog.js';
import { mountLayout } from './layout.js';
import { addToCart } from './store.js';
import {
	createImage,
	createQuantityStepper,
	icon,
	renderProductGrid,
	showToast
} from './ui.js';
import { formatMoney } from './utils.js';

mountLayout();

const productView = document.getElementById('product-view');
const missingView = document.getElementById('product-missing');
const breadcrumbCategory = document.getElementById('breadcrumb-category');
const breadcrumbCategorySeparator = document.getElementById('breadcrumb-category-separator');
const breadcrumbCurrent = document.getElementById('breadcrumb-current');
const descriptionMeta = document.querySelector('meta[name="description"]');

const productId = new URLSearchParams(window.location.search).get('id');
const product = getProductById(productId);

function showMissing() {
	if (productView) productView.hidden = true;
	if (missingView) missingView.hidden = false;
	if (breadcrumbCurrent) breadcrumbCurrent.textContent = 'Not found';
	if (breadcrumbCategory) breadcrumbCategory.hidden = true;
	if (breadcrumbCategorySeparator) breadcrumbCategorySeparator.hidden = true;
	document.title = 'Product not found — Isoko';
}

if (!product) {
	showMissing();
} else {
	const category = getCategory(product.category);
	const stockLabel = product.stock <= 3 ? `Only ${product.stock} left` : `${product.stock} in stock`;

	document.title = `${product.title} — Isoko`;
	if (descriptionMeta) descriptionMeta.content = product.description;

	if (breadcrumbCategory && category) {
		breadcrumbCategory.href = `shop.html?category=${encodeURIComponent(category.slug)}`;
		breadcrumbCategory.textContent = category.label;
		breadcrumbCategory.hidden = false;
		if (breadcrumbCategorySeparator) breadcrumbCategorySeparator.hidden = false;
	}
	if (breadcrumbCurrent) breadcrumbCurrent.textContent = product.title;

	const categoryLink = document.getElementById('product-category');
	if (categoryLink && category) {
		categoryLink.href = `shop.html?category=${encodeURIComponent(category.slug)}`;
		categoryLink.textContent = category.label;
	}

	const subcategory = document.getElementById('product-subcategory');
	if (subcategory) subcategory.textContent = product.subcategory;

	const title = document.getElementById('product-title');
	if (title) title.textContent = product.title;

	const price = document.getElementById('product-price');
	if (price) price.textContent = formatMoney(product.price);

	const stock = document.getElementById('product-stock');
	if (stock) stock.textContent = stockLabel;

	const description = document.getElementById('product-description');
	if (description) description.textContent = product.description;

	const specs = {
		'spec-sku': `ISK-${product.id.toUpperCase()}`,
		'spec-category': category?.label ?? product.category,
		'spec-subcategory': product.subcategory,
		'spec-availability': stockLabel
	};
	for (const [id, value] of Object.entries(specs)) {
		const target = document.getElementById(id);
		if (target) target.textContent = value;
	}

	const galleryMain = document.getElementById('gallery-main');
	const galleryThumbs = document.getElementById('gallery-thumbs');
	const images = product.images.length ? product.images : [''];

	const showImage = (index) => {
		if (!galleryMain) return;
		galleryMain.replaceChildren(
			createImage(images[index], `${product.title} — image ${index + 1} of ${images.length}`, {
				eager: true
			})
		);
		galleryThumbs?.querySelectorAll('button').forEach((button, buttonIndex) => {
			button.setAttribute('aria-current', String(buttonIndex === index));
		});
	};

	if (galleryThumbs && images.length > 1) {
		for (const [index, src] of images.entries()) {
			const button = document.createElement('button');
			button.type = 'button';
			button.className = 'product-gallery__thumb';
			button.setAttribute('aria-label', `Show image ${index + 1} of ${images.length}`);
			button.append(createImage(src, '', { className: 'product-gallery__thumb-image' }));
			button.addEventListener('click', () => showImage(index));
			galleryThumbs.append(button);
		}
	}
	showImage(0);

	const quantitySlot = document.getElementById('quantity-slot');
	const stepper = createQuantityStepper({
		value: 1,
		min: 1,
		max: Math.min(product.stock, 99),
		label: 'Quantity'
	});
	quantitySlot?.append(stepper.element);

	const addButton = document.getElementById('add-to-cart');
	if (addButton) {
		addButton.innerHTML = `${icon('cart')}<span>Add to cart</span>`;
		addButton.addEventListener('click', () => {
			const quantity = stepper.getValue();
			addToCart(product.id, quantity);
			showToast(`${quantity} × ${product.title} added to your cart.`, {
				actionLabel: 'View cart',
				actionHref: 'shoppingcart.html'
			});
		});
	}

	const relatedGrid = document.getElementById('related-grid');
	const relatedLink = document.getElementById('related-link');
	const related = getRelated(product, 3);

	if (relatedLink && category) {
		relatedLink.href = `shop.html?category=${encodeURIComponent(category.slug)}`;
		relatedLink.textContent = `Browse ${category.label}`;
	}

	if (relatedGrid) {
		renderProductGrid(related, relatedGrid, {
			onAdd: (item) => {
				addToCart(item.id, 1);
				showToast(`${item.title} added to your cart.`, {
					actionLabel: 'View cart',
					actionHref: 'shoppingcart.html'
				});
			}
		});
	}

	if (productView) productView.hidden = false;
	if (missingView) missingView.hidden = true;
}
