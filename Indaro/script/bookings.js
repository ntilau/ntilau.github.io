import { parseNights, parseGuests, roundMoney } from './utils.js';

const BOOKING_KEY = 'indaro:booking:v1';

function orderNumber() {
	const today = new Date();
	const ymd = today.toISOString().slice(0, 10).replace(/-/g, '');
	const random = Math.floor(1000 + Math.random() * 9000);
	return `ZUN-${ymd}-${random}`;
}

function emptyBooking() {
	return {
		orderNumber: null,
		createdAt: null,
		checkIn: '',
		checkOut: '',
		nights: 0,
		guests: 2,
		listing: null,
		subtotal: 0,
		total: 0,
		customer: { name: '', email: '', phone: '' },
		notes: ''
	};
}

let listeners = [];

function notify() {
	const snapshot = getBooking();
	for (const listener of listeners) listener(snapshot);
}

export function createBooking({ listing, checkIn, checkOut, guests, customer, notes = '' } = {}) {
	const nights = parseNights(checkIn, checkOut) || 1;
	const subtotal = listing ? roundMoney(listing.pricePerNight * nights) : 0;
	const updated = {
		orderNumber: orderNumber(),
		createdAt: new Date().toISOString(),
		checkIn: checkIn || '',
		checkOut: checkOut || '',
		nights,
		guests: parseGuests(guests),
		listing: listing ? { ...listing } : null,
		subtotal,
		total: subtotal,
		customer: { name: '', email: '', phone: '', ...customer },
		notes: notes || ''
	};
	try {
		localStorage.setItem(BOOKING_KEY, JSON.stringify(updated));
	} catch {
		// storage unavailable; booking lives in memory only
	}
	notify();
	return updated;
}

export function getBooking() {
	try {
		const raw = localStorage.getItem(BOOKING_KEY);
		if (raw) return { ...JSON.parse(raw) };
	} catch {
		// fall through to empty
	}
	return { ...emptyBooking() };
}

export function clearBooking() {
	try {
		localStorage.removeItem(BOOKING_KEY);
	} catch {
		// ignore
	}
	notify();
}

export function updateCustomer(customer) {
	const booking = getBooking();
	const updated = { ...booking, customer: { ...booking.customer, ...customer } };
	try {
		localStorage.setItem(BOOKING_KEY, JSON.stringify(updated));
	} catch {
		// ignore
	}
	notify();
	return updated;
}

export function subscribeBooking(listener) {
	listeners.push(listener);
	listener(getBooking());
	return () => {
		listeners = listeners.filter((item) => item !== listener);
	};
}

export function hasPersistentStorage() {
	try {
		const test = '__indaro_test__';
		localStorage.setItem(test, test);
		localStorage.removeItem(test);
		return true;
	} catch {
		return false;
	}
}
