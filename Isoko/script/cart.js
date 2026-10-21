import { getLastOrder, getTotals, removeFromCart, saveOrder, setQuantity, clearCart, FREE_SHIPPING_AT } from './store.js';
import { createBreadcrumb, mountLayout } from './layout.js';
import { createImage, createQuantityStepper, icon, renderEmptyState, showToast } from './ui.js';
import { createElement, formatDate, formatMoney } from './utils.js';

mountLayout();

const root = document.getElementById('cart-root');

const FIELDS = [
	{
		name: 'fullName',
		label: 'Full name',
		type: 'text',
		autocomplete: 'name',
		placeholder: 'Amina Okafor',
		required: true,
		error: 'Enter the full name for delivery.',
		maxlength: 80
	},
	{
		name: 'email',
		label: 'Email',
		type: 'email',
		autocomplete: 'email',
		placeholder: 'you@example.com',
		required: true,
		error: 'Enter a valid email address.'
	},
	{
		name: 'address1',
		label: 'Address line 1',
		type: 'text',
		autocomplete: 'address-line1',
		placeholder: 'House or building, street, area',
		required: true,
		error: 'Enter the street address for delivery.',
		full: true,
		maxlength: 120
	},
	{
		name: 'address2',
		label: 'Address line 2',
		type: 'text',
		autocomplete: 'address-line2',
		placeholder: 'Apartment, landmark, or delivery note',
		required: false,
		full: true,
		maxlength: 120
	},
	{
		name: 'city',
		label: 'City or town',
		type: 'text',
		autocomplete: 'address-level2',
		placeholder: 'Bengaluru',
		required: true,
		error: 'Enter the city or town.',
		maxlength: 60
	},
	{
		name: 'state',
		label: 'State or region',
		type: 'text',
		autocomplete: 'address-level1',
		placeholder: 'Karnataka',
		required: true,
		error: 'Enter the state or region.',
		maxlength: 60
	},
	{
		name: 'postalCode',
		label: 'PIN / postal code',
		type: 'text',
		autocomplete: 'postal-code',
		placeholder: '560001',
		required: true,
		error: 'Enter a valid PIN or postal code (4–10 digits).',
		inputmode: 'numeric',
		maxlength: 12
	},
	{
		name: 'phone',
		label: 'Phone',
		type: 'tel',
		autocomplete: 'tel',
		placeholder: '+91 98765 43210',
		required: true,
		error: 'Enter a phone number with at least 7 digits.',
		maxlength: 24
	}
];

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const POSTAL_PATTERN = /^\d{4,10}$/;

function createPageHeader({ eyebrow = '', title, lede = '' }) {
	const header = createElement('div', 'page-header');
	const text = document.createElement('div');

	if (eyebrow) text.append(createElement('p', 'eyebrow', eyebrow));

	const heading = createElement('h1', '', title);
	heading.tabIndex = -1;
	text.append(heading);

	if (lede) text.append(createElement('p', '', lede));

	header.append(text);
	return header;
}

function focusRenderedHeading() {
	root.querySelector('h1')?.focus({ preventScroll: true });
}

function renderEmptyCart() {
	document.title = 'Your cart is empty — Isoko';
	root.replaceChildren(
		createBreadcrumb([
			{ label: 'Home', href: 'index.html' },
			{ label: 'Cart' }
		]),
		createPageHeader({
			eyebrow: 'Guest cart',
			title: 'Your cart is empty',
			lede: 'Your cart lives in this browser. Add something useful and it will be waiting here when you return.'
		})
	);

	const holder = document.createElement('div');
	renderEmptyState(holder, {
		title: 'No items yet',
		text: 'Browse the market, choose a category, or use a quick-add button on any product card.',
		actionLabel: 'Shop the market',
		actionHref: 'shop.html',
		iconName: 'bag'
	});
	root.append(holder);
}

function createSummaryRow(label, value, modifier = '') {
	const row = createElement('div', `summary-row${modifier ? ` ${modifier}` : ''}`);
	const labelNode = createElement('span', '', label);
	const valueNode = createElement('strong', '', value);
	row.append(labelNode, valueNode);
	return { row, labelNode, valueNode };
}

function createCartLine(line, refreshSummary) {
	const { product, qty } = line;
	const row = createElement('div', 'cart-line');
	row.dataset.productId = product.id;

	const media = document.createElement('a');
	media.className = 'cart-line__media';
	media.href = `openproduct.html?id=${encodeURIComponent(product.id)}`;
	media.setAttribute('aria-label', `View ${product.title}`);
	media.append(createImage(product.images[0], product.title, { className: 'cart-line__image' }));

	const body = createElement('div', 'cart-line__body');
	body.append(createElement('p', 'cart-line__eyebrow', `${product.categoryLabel} · ${product.subcategory}`));

	const title = document.createElement('h3');
	title.className = 'cart-line__title';
	const titleLink = document.createElement('a');
	titleLink.href = `openproduct.html?id=${encodeURIComponent(product.id)}`;
	titleLink.textContent = product.title;
	title.append(titleLink);

	const unit = createElement('p', 'cart-line__unit', `${formatMoney(product.price)} each`);
	const lineTotal = createElement('strong', 'cart-line__total', formatMoney(product.price * qty));

	const stepper = createQuantityStepper({
		value: qty,
		min: 1,
		max: Math.min(product.stock, 99),
		label: `Quantity for ${product.title}`,
		onChange: (nextQuantity) => {
			setQuantity(product.id, nextQuantity);
			lineTotal.textContent = formatMoney(product.price * nextQuantity);
			refreshSummary(getTotals());
		}
	});

	body.append(title, unit, stepper.element);

	const side = createElement('div', 'cart-line__side');

	const remove = document.createElement('button');
	remove.type = 'button';
	remove.className = 'cart-line__remove';
	remove.innerHTML = `${icon('trash')}<span>Remove</span>`;
	remove.setAttribute('aria-label', `Remove ${product.title} from cart`);
	remove.addEventListener('click', () => {
		removeFromCart(product.id);
		showToast(`${product.title} removed from your cart.`);
		renderCartPage({ focusHeading: true });
	});

	side.append(lineTotal, remove);
	row.append(media, body, side);
	return row;
}

function buildField(definition) {
	const wrapper = createElement('div', `field${definition.full ? ' field--full' : ''}`);
	const inputId = `field-${definition.name}`;
	const errorId = `error-${definition.name}`;

	const label = document.createElement('label');
	label.htmlFor = inputId;
	label.textContent = definition.label;
	if (!definition.required) label.append(' ', createElement('span', '', '(optional)'));

	const input = document.createElement('input');
	input.id = inputId;
	input.name = definition.name;
	input.type = definition.type;
	input.autocomplete = definition.autocomplete;
	input.placeholder = definition.placeholder ?? '';
	input.required = Boolean(definition.required);
	input.maxLength = definition.maxlength ?? 120;
	input.inputMode = definition.inputmode ?? 'text';
	input.setAttribute('aria-describedby', errorId);

	const error = createElement('p', 'field-error');
	error.id = errorId;
	error.setAttribute('aria-live', 'polite');

	wrapper.append(label, input, error);
	return { wrapper, input, error, definition };
}

function validateField(field) {
	const value = field.input.value.trim();
	let message = '';

	if (field.definition.required && !value) {
		message = field.definition.error;
	} else if (field.definition.name === 'email' && value && !EMAIL_PATTERN.test(value)) {
		message = field.definition.error;
	} else if (field.definition.name === 'phone' && value.replace(/\D/g, '').length < 7) {
		message = field.definition.error;
	} else if (field.definition.name === 'postalCode' && value && !POSTAL_PATTERN.test(value)) {
		message = field.definition.error;
	}

	field.input.setAttribute('aria-invalid', message ? 'true' : 'false');
	field.error.textContent = message;
	return !message;
}

function buildDeliverySection(fields) {
	const section = createElement('section', 'cart-form-section');
	const heading = createElement('h2', '', 'Delivery details');
	const note = createElement(
		'p',
		'',
		'These details are only used to build your demo order. They stay in this browser and are never sent anywhere.'
	);
	const grid = createElement('div', 'form-grid');

	for (const definition of FIELDS) {
		const field = buildField(definition);
		fields.push(field);
		grid.append(field.wrapper);
	}

	section.append(heading, note, grid);
	return section;
}

function renderCart(totals) {
	document.title = 'Shopping cart — Isoko';

	const pageHeader = createPageHeader({
		eyebrow: 'Guest cart',
		title: 'Shopping cart',
		lede: `${totals.count} ${totals.count === 1 ? 'item' : 'items'} waiting in this browser. Update quantities, then add delivery details when you are ready.`
	});
	const cartLede = pageHeader.querySelector('p:not(.eyebrow)');

	const continueLink = document.createElement('a');
	continueLink.className = 'cart-continue';
	continueLink.href = 'shop.html';
	continueLink.textContent = 'Continue shopping';
	pageHeader.firstElementChild?.append(continueLink);

	root.replaceChildren(
		createBreadcrumb([
			{ label: 'Home', href: 'index.html' },
			{ label: 'Cart' }
		]),
		pageHeader
	);

	const form = document.createElement('form');
	form.id = 'checkout-form';
	form.className = 'cart-layout';
	form.noValidate = true;

	const main = createElement('div', 'cart-main');
	const linesSection = createElement('section', 'cart-lines');
	linesSection.setAttribute('aria-label', 'Cart items');

	const columnHead = createElement('div', 'cart-lines__head');
	columnHead.setAttribute('aria-hidden', 'true');
	columnHead.append(createElement('span', '', 'Items'), createElement('span', '', 'Price'));
	linesSection.append(columnHead);

	const fields = [];
	const summary = createElement('aside', 'cart-summary');
	const summaryTitle = createElement('h2', '', 'Order summary');
	const itemsRow = createSummaryRow(`Items (${totals.count})`, formatMoney(totals.subtotal));
	const shippingRow = createSummaryRow(
		'Delivery',
		totals.shipping === 0 ? 'Free' : formatMoney(totals.shipping)
	);
	const totalRow = createSummaryRow('Total', formatMoney(totals.total), 'summary-row--total');
	const shippingNote = createElement('p', 'free-shipping-note');

	const submit = document.createElement('button');
	submit.type = 'submit';
	submit.className = 'btn btn--primary';
	submit.innerHTML = `${icon('shield')}<span>Place demo order — no payment</span>`;

	const demoNote = createElement('p', 'demo-note');
	demoNote.innerHTML = `${icon('shield')}<span>No payment is taken. This demo order is saved only in this browser.</span>`;

	summary.append(
		summaryTitle,
		itemsRow.row,
		shippingRow.row,
		totalRow.row,
		shippingNote,
		submit,
		demoNote
	);

	function refreshSummary(nextTotals) {
		if (cartLede) {
			cartLede.textContent = `${nextTotals.count} ${nextTotals.count === 1 ? 'item' : 'items'} waiting in this browser. Update quantities, then add delivery details when you are ready.`;
		}
		itemsRow.labelNode.textContent = `Items (${nextTotals.count})`;
		itemsRow.valueNode.textContent = formatMoney(nextTotals.subtotal);
		shippingRow.valueNode.textContent =
			nextTotals.shipping === 0 ? 'Free' : formatMoney(nextTotals.shipping);
		totalRow.valueNode.textContent = formatMoney(nextTotals.total);
		updateShippingNote(nextTotals.subtotal);
	}

	function updateShippingNote(subtotal) {
		if (subtotal >= FREE_SHIPPING_AT) {
			shippingNote.textContent = 'Free delivery included on this order.';
		} else {
			shippingNote.textContent = `${formatMoney(FREE_SHIPPING_AT - subtotal)} away from free delivery.`;
		}
	}

	updateShippingNote(totals.subtotal);

	for (const line of totals.lines) {
		linesSection.append(createCartLine(line, refreshSummary));
	}

	main.append(linesSection, buildDeliverySection(fields));

	for (const field of fields) {
		field.input.addEventListener('input', () => {
			if (field.input.getAttribute('aria-invalid') === 'true') validateField(field);
		});
	}

	form.addEventListener('submit', (event) => {
		event.preventDefault();

		let firstInvalid = null;
		for (const field of fields) {
			const valid = validateField(field);
			if (!valid && !firstInvalid) firstInvalid = field;
		}

		if (firstInvalid) {
			firstInvalid.input.focus();
			return;
		}

		const customer = Object.fromEntries(
			fields.map((field) => [field.definition.name, field.input.value.trim()])
		);

		const order = saveOrder(customer);
		if (!order) {
			renderCartPage();
			return;
		}

		clearCart();
		window.history.replaceState(null, '', 'shoppingcart.html?ordered=1');
		renderConfirmation(order, { focus: true });
		window.scrollTo({ top: 0, behavior: 'auto' });
	});

	form.append(main, summary);
	root.append(form);
}

function appendMetaRow(list, label, value) {
	const row = document.createElement('div');
	row.append(createElement('dt', '', label), createElement('dd', '', value));
	list.append(row);
}

function renderConfirmation(order, { focus = false } = {}) {
	document.title = `Order ${order.orderNumber} — Isoko`;

	const confirmation = createElement('section', 'confirmation');
	confirmation.dataset.confirmation = 'true';

	const head = createElement('div', 'confirmation__head');
	const mark = createElement('span', 'confirmation__icon');
	mark.innerHTML = icon('check');

	const heading = createElement('h1', '', 'Order placed.');
	heading.tabIndex = -1;

	const lede = createElement(
		'p',
		'confirmation__lede',
		`Thank you, ${order.customer?.fullName ?? 'guest'}. Your demo order is saved on this device — no payment was taken.`
	);
	head.append(mark, heading, lede);

	const meta = createElement('dl', 'order-meta');
	appendMetaRow(meta, 'Order number', order.orderNumber);
	appendMetaRow(meta, 'Placed', formatDate(order.placedAt));
	appendMetaRow(
		meta,
		'Deliver to',
		[order.customer?.fullName, order.customer?.city].filter(Boolean).join(' · ') || 'Guest'
	);

	const items = createElement('div', 'order-items');
	for (const item of order.items) {
		const row = createElement('div', 'order-item');
		const name = createElement('span', '', `${item.title} × ${item.qty}`);
		const total = document.createElement('strong');
		total.textContent = formatMoney(item.lineTotal);
		row.append(name, total);
		items.append(row);
	}

	const totals = createElement('div', 'order-totals');
	const subtotal = createSummaryRow('Subtotal', formatMoney(order.subtotal));
	const shipping = createSummaryRow('Delivery', order.shipping === 0 ? 'Free' : formatMoney(order.shipping));
	const total = createSummaryRow('Total', formatMoney(order.total), 'summary-row--total');
	totals.append(subtotal.row, shipping.row, total.row);

	const fineprint = createElement(
		'p',
		'confirmation__fineprint',
		'This is a local demo order. It was not sent to Isoko, no payment was processed, and no account was created. Reloading this page will show the same saved order.'
	);

	const actions = createElement('div', 'confirmation__actions');
	const continueLink = document.createElement('a');
	continueLink.className = 'btn btn--primary';
	continueLink.href = 'shop.html';
	continueLink.textContent = 'Continue shopping';

	const printButton = document.createElement('button');
	printButton.type = 'button';
	printButton.className = 'btn btn--secondary';
	printButton.innerHTML = `${icon('package')}<span>Print summary</span>`;
	printButton.addEventListener('click', () => window.print());

	actions.append(continueLink, printButton);
	confirmation.append(head, meta, items, totals, fineprint, actions);

	root.replaceChildren(
		createBreadcrumb([
			{ label: 'Home', href: 'index.html' },
			{ label: 'Order confirmation' }
		]),
		confirmation
	);

	if (focus) heading.focus({ preventScroll: true });
}

function renderCartPage({ focusHeading = false } = {}) {
	const totals = getTotals();
	if (!totals.lines.length) {
		renderEmptyCart();
	} else {
		renderCart(totals);
	}

	if (focusHeading) focusRenderedHeading();
}

const ordered = new URLSearchParams(window.location.search).get('ordered') === '1';

if (ordered) {
	const order = getLastOrder();
	if (order) {
		renderConfirmation(order);
	} else {
		window.history.replaceState(null, '', 'shoppingcart.html');
		renderCartPage();
	}
} else {
	renderCartPage();
}
