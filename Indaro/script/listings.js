export const LOCATIONS = Object.freeze([
	{ slug: 'kigali', label: 'Kigali', blurb: 'Capital city stays near the convention centre and event venues.' },
	{ slug: 'musanze', label: 'Musanze', blurb: 'Gateway to the volcanoes, with lodge and boutique options.' },
	{ slug: 'gisenyi', label: 'Gisenyi', blurb: 'Lakeside retreats on Lake Kivu with mountain views.' },
	{ slug: 'kibuye', label: 'Kibuye', blurb: 'Quiet hillside guesthouses and waterfront villas.' },
	{ slug: 'nyungwe', label: 'Nyungwe', blurb: 'Forest-edge lodges and canopy-stay cabins.' },
	{ slug: 'bugesera', label: 'Bugesera', blurb: 'Convenient airport-adjacent hotels and serviced apartments.' }
]);

export const PROPERTY_TYPES = Object.freeze([
	{ slug: 'hotel', label: 'Hotel' },
	{ slug: 'boutique-hotel', label: 'Boutique hotel' },
	{ slug: 'guesthouse', label: 'Guesthouse' },
	{ slug: 'serviced-apartment', label: 'Serviced apartment' },
	{ slug: 'villa', label: 'Villa' },
	{ slug: 'glamping', label: 'Glamping / campsite' }
]);

export const SORT_OPTIONS = Object.freeze([
	{ value: 'featured', label: 'Featured first' },
	{ value: 'price-asc', label: 'Price: low to high' },
	{ value: 'price-desc', label: 'Price: high to low' },
	{ value: 'name-asc', label: 'Name: A to Z' }
]);

const LOCATION_BY_SLUG = new Map(LOCATIONS.map((location) => [location.slug, location]));
const TYPE_BY_SLUG = new Map(PROPERTY_TYPES.map((type) => [type.slug, type]));

// Illustrative stays derived from the accommodation and hospitality sectors in
// the Rwanda Formula 1 & Tourism Investment Opportunities PDF. These are sample
// listings for demonstration only — not real, bookable properties.
const RAW_LISTINGS = [
	{
		id: 'kigali-hotel-1',
		name: 'Kigali Heights Hotel',
		type: 'hotel',
		location: 'kigali',
		locationLabel: 'Kigali',
		pricePerNight: 185,
		images: [
			'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1551882547-ff40c6468faa?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1578866713723-b3577e801085?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Modern hotel in the heart of Kigali, within walking distance of the convention centre and major event venues. Rooftop lounge, on-site dining, and 24-hour concierge.',
		amenities: ['Wi‑Fi', 'Pool', 'Gym', 'Restaurant', 'Bar', 'Airport shuttle', 'Conference rooms'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.6,
		reviewCount: 214,
		featured: true,
		badge: 'City centre'
	},
	{
		id: 'kigali-boutique-1',
		name: 'Coline Boutique Hotel',
		type: 'boutique-hotel',
		location: 'kigali',
		locationLabel: 'Kigali',
		pricePerNight: 240,
		images: [
			'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Intimate boutique hotel with Rwandan art throughout, a courtyard garden, and a celebrated coffee bar. Ideal for design-conscious travellers.',
		amenities: ['Wi‑Fi', 'Courtyard', 'Coffee bar', 'Spa', 'Laundry', 'Bicycle rental'],
		capacity: 2,
		guestsMax: 3,
		rating: 4.8,
		reviewCount: 98,
		featured: true,
		badge: 'Design focus'
	},
	{
		id: 'kigali-apartment-1',
		name: 'Urban Stay Serviced Apartments',
		type: 'serviced-apartment',
		location: 'kigali',
		locationLabel: 'Kigali',
		pricePerNight: 160,
		images: [
			'https://images.unsplash.com/photo-1502672260266-1c1ef0d93688?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Fully equipped serviced apartments with kitchenettes, ideal for longer stays during events. Weekly housekeeping and fast Wi‑Fi included.',
		amenities: ['Wi‑Fi', 'Kitchen', 'Washer', 'Workspace', 'Gym', 'Secure parking'],
		capacity: 4,
		guestsMax: 6,
		rating: 4.5,
		reviewCount: 132,
		badge: 'Long-stay friendly'
	},
	{
		id: 'musanze-lodge-1',
		name: 'Volcano Edge Lodge',
		type: 'hotel',
		location: 'musanze',
		locationLabel: 'Musanze',
		pricePerNight: 310,
		images: [
			'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1448375240586-882707db888b?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Lodge on the edge of Volcanoes National Park with sweeping mountain views, fireplace suites, and guided trek arrangements.',
		amenities: ['Wi‑Fi', 'Fireplace', 'Restaurant', 'Guided treks', 'Laundry', 'Parking'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.7,
		reviewCount: 156,
		featured: true,
		badge: 'Mountain views'
	},
	{
		id: 'gisenyi-villa-1',
		name: 'Kivu Shores Villa',
		type: 'villa',
		location: 'gisenyi',
		locationLabel: 'Gisenyi',
		pricePerNight: 420,
		images: [
			'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Lakeside villa on Lake Kivu with private terrace, infinity-edge pool, and sunset views over the water. Suitable for groups and celebratory stays.',
		amenities: ['Wi‑Fi', 'Pool', 'Kitchen', 'Terrace', 'Boat access', 'Housekeeping'],
		capacity: 6,
		guestsMax: 8,
		rating: 4.9,
		reviewCount: 67,
		badge: 'Lakefront'
	},
	{
		id: 'kibuye-guesthouse-1',
		name: 'Hillside Guesthouse',
		type: 'guesthouse',
		location: 'kibuye',
		locationLabel: 'Kibuye',
		pricePerNight: 95,
		images: [
			'https://images.unsplash.com/photo-1534447856017-e2bbf6a4c7c1?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Family-run guesthouse on the Kibuye hills with home-cooked Rwandan meals, garden seating, and quiet lake breezes.',
		amenities: ['Wi‑Fi', 'Garden', 'Home-cooked meals', 'Laundry', 'Parking'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.4,
		reviewCount: 89,
		badge: 'Local hospitality'
	},
	{
		id: 'nyungwe-cabin-1',
		name: 'Canopy Forest Cabins',
		type: 'glamping',
		location: 'nyungwe',
		locationLabel: 'Nyungwe',
		pricePerNight: 195,
		images: [
			'https://images.unsplash.com/photo-1446776812057-923939d799c3?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1469474958028-636391185466?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Elevated forest-edge cabins near Nyungwe National Park with canopy walks, birdwatching guides, and eco-friendly design.',
		amenities: ['Wi‑Fi', 'Canopy deck', 'Guided walks', 'Restaurant', 'Solar power'],
		capacity: 2,
		guestsMax: 3,
		rating: 4.6,
		reviewCount: 73,
		badge: 'Eco stay'
	},
	{
		id: 'bugesera-apartment-1',
		name: 'Airport Suites',
		type: 'serviced-apartment',
		location: 'bugesera',
		locationLabel: 'Bugesera',
		pricePerNight: 130,
		images: [
			'https://images.unsplash.com/photo-1493809842364-78817add7ffb?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1502672260266-1c1ef0d93688?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Convenient airport-adjacent suites with express check-in, work desks, and complimentary shuttle to the terminal.',
		amenities: ['Wi‑Fi', 'Airport shuttle', 'Workspace', 'Kitchenette', 'Laundry', '24-hour front desk'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.3,
		reviewCount: 111,
		badge: 'Airport access'
	},
	{
		id: 'kigali-glamping-1',
		name: 'Jalia Glamping Retreat',
		type: 'glamping',
		location: 'kigali',
		locationLabel: 'Kigali',
		pricePerNight: 155,
		images: [
			'https://images.unsplash.com/photo-1519378093730-f1c1e070579b?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Luxury glamping tents on the city outskirts with en-suite bathrooms, fire pits, and stargazing decks. A distinctive alternative to a hotel.',
		amenities: ['Wi‑Fi', 'En-suite bath', 'Fire pit', 'Restaurant', 'Laundry', 'Nature walks'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.5,
		reviewCount: 54,
		badge: 'Unique stay'
	},
	{
		id: 'musanze-guesthouse-1',
		name: 'Kinigi Village Guesthouse',
		type: 'guesthouse',
		location: 'musanze',
		locationLabel: 'Musanze',
		pricePerNight: 78,
		images: [
			'https://images.unsplash.com/photo-1533889774577-2b91d1e95bfb?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1534447856017-e2bbf6a4c7c1?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Warm village guesthouse near the park headquarters with local hosts, traditional meals, and easy access to gorilla trekking permits.',
		amenities: ['Wi‑Fi', 'Home-cooked meals', 'Permit desk', 'Laundry', 'Garden'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.3,
		reviewCount: 61,
		badge: 'Community run'
	},
	{
		id: 'kigali-hotel-2',
		name: 'Grand Pinnacle Hotel',
		type: 'hotel',
		location: 'kigali',
		locationLabel: 'Kigali',
		pricePerNight: 295,
		images: [
			'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=1200&auto=format&fit=crop',
			'https://images.unsplash.com/photo-1551882547-ff40c6468faa?q=80&w=1200&auto=format&fit=crop'
		],
		description:
			'Upscale hotel with ballroom, spa, and multiple restaurants, positioned for business travellers and event attendees.',
		amenities: ['Wi‑Fi', 'Pool', 'Spa', 'Ballroom', 'Restaurant', 'Bar', 'Conference rooms', 'Airport shuttle'],
		capacity: 2,
		guestsMax: 4,
		rating: 4.7,
		reviewCount: 187,
		badge: 'Event venue'
	}
];

const LISTINGS = Object.freeze(RAW_LISTINGS.map((listing) => ({ ...listing, images: [...listing.images] })));

export { LISTINGS };

export function getListingById(id) {
	return LISTINGS.find((listing) => listing.id === id);
}

export function getLocation(slug) {
	return LOCATION_BY_SLUG.get(slug);
}

export function getType(slug) {
	return TYPE_BY_SLUG.get(slug);
}

export function locationCounts() {
	const counts = {};
	for (const location of LOCATIONS) {
		counts[location.slug] = LISTINGS.filter((listing) => listing.location === location.slug).length;
	}
	return counts;
}

export function typeCounts() {
	const counts = {};
	for (const type of PROPERTY_TYPES) {
		counts[type.slug] = LISTINGS.filter((listing) => listing.type === type.slug).length;
	}
	return counts;
}

export function getFeatured(limit) {
	return LISTINGS.filter((listing) => listing.featured).slice(0, limit);
}

export function getRelated(listing, limit = 3) {
	return LISTINGS
		.filter((other) => other.id !== listing.id && (other.location === listing.location || other.type === listing.type))
		.slice(0, limit);
}

function matchesFilters(listing, { q, location, type, checkIn, checkOut, guests }) {
	if (location && listing.location !== location) return false;
	if (type && listing.type !== type) return false;
	if (guests && listing.guestsMax < Number(guests)) return false;

	if (q) {
		const tokens = normalizeText(q).split(/\s+/).filter(Boolean);
		if (tokens.length) {
			// norm imports utils; avoid circular by duplicating minimal normalization inline
			const haystack = normalizeText(
				`${listing.name} ${listing.locationLabel} ${listing.description} ${listing.amenities.join(' ')}`
			);
			if (!tokens.every((token) => haystack.includes(token))) return false;
		}
	}

	return true;
}

export function queryListings({ q = '', location = '', type = '', checkIn = '', checkOut = '', guests = '', sort = 'featured' } = {}) {
	let results = LISTINGS.filter((listing) => matchesFilters(listing, { q, location, type, checkIn, checkOut, guests }));

	const nights = checkIn && checkOut ? parseNights(checkIn, checkOut) : 0;

	switch (sort) {
		case 'price-asc':
			results = [...results].sort((a, b) => a.pricePerNight - b.pricePerNight);
			break;
		case 'price-desc':
			results = [...results].sort((a, b) => b.pricePerNight - a.pricePerNight);
			break;
		case 'name-asc':
			results = [...results].sort((a, b) => a.name.localeCompare(b.name));
			break;
		default:
			results = [...results].sort((a, b) => b.rating - a.rating || b.reviewCount - a.reviewCount || a.pricePerNight - b.pricePerNight);
			break;
	}

	return { results, nights };
}

export function listingTotalPrice(listing, checkIn, checkOut) {
	const nights = parseNights(checkIn, checkOut) || 1;
	return roundMoney(listing.pricePerNight * nights);
}
