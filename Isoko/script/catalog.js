import { normalizeText, roundMoney, stripImageSize } from './utils.js';

export const CATEGORIES = Object.freeze([
	{
		slug: 'electronics',
		label: 'Electronics',
		blurb: 'Cameras, drones, printers, and useful everyday tech.',
		icon: 'camera',
		accent: '#2F6B5E'
	},
	{
		slug: 'apparel',
		label: 'Apparel & Textiles',
		blurb: 'Baby basics, modest wear, and garment-maker supplies.',
		icon: 'shirt',
		accent: '#B45D45'
	},
	{
		slug: 'car-parts',
		label: 'Car Parts & Accessories',
		blurb: 'Maintenance, lighting, cabin comfort, and car care.',
		icon: 'car',
		accent: '#A77C2E'
	}
]);

export const SORT_OPTIONS = Object.freeze([
	{ value: 'featured', label: 'Featured first' },
	{ value: 'price-asc', label: 'Price: low to high' },
	{ value: 'price-desc', label: 'Price: high to low' },
	{ value: 'name-asc', label: 'Name: A to Z' }
]);

const CATEGORY_BY_SLUG = new Map(CATEGORIES.map((category) => [category.slug, category]));

const CATEGORY_COPY = {
	electronics:
		'A practical electronics pick from the Isoko market, chosen for straightforward everyday use.',
	apparel:
		'An apparel and textiles pick from the Isoko market, chosen for comfortable wear and easy care.',
	'car-parts':
		'A car-parts pick from the Isoko market, chosen for practical maintenance and fitment-ready use.'
};

const RAW_PRODUCTS = [
	// Electronics
	{
		id: 'electronics-1',
		title: 'Pinhole 1/2.8" CCTV Lens, 1.8 mm Wide Angle, Low Distortion',
		category: 'electronics',
		subcategory: 'Camera Lenses',
		price: 685.38,
		keywords: ['cctv', 'security', 'wide angle', 'optics'],
		images: [
			'https://sc04.alicdn.com/kf/H64ed7e1732cc415b9f519ec657cb2b28b.jpg',
			'https://sc04.alicdn.com/kf/H6d011b913b6348ae94e727b8b33d26f6C.jpg',
			'https://sc04.alicdn.com/kf/Hfed98582f4d748118f663859b33800c9p.jpg'
		]
	},
	{
		id: 'electronics-2',
		title: 'Benro T980 Aluminum Camera Tripod with Carry Bag',
		category: 'electronics',
		subcategory: 'Tripods & Supports',
		price: 2804.64,
		keywords: ['photography', 'stand', 'camera support'],
		images: [
			'https://sc04.alicdn.com/kf/Hadcb3eb2388342cea3a4899e6e66b9113.jpg',
			'https://sc04.alicdn.com/kf/Hcdd6bd8ce3284a928569ecf22674940cx.jpg',
			'https://sc04.alicdn.com/kf/H08146a4cfc1f4c63adb1a12b52f35a0fI.jpg'
		]
	},
	{
		id: 'electronics-3',
		title: 'E99 Foldable RC Drone with 720P/4K Camera and WiFi FPV',
		category: 'electronics',
		subcategory: 'Drones & RC',
		price: 846.33,
		keywords: ['drone', 'quadcopter', 'aerial', 'remote control'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/H86db3d4c5c044e889cdf05a2020ddc932.jpg',
			'https://sc04.alicdn.com/kf/Hebe4154eee8142bda7adee60b56607dej.jpg',
			'https://sc04.alicdn.com/kf/H735e879f8fab4c9092fc53577b3add96B.jpg'
		]
	},
	{
		id: 'electronics-4',
		title: 'Aluminum Panoramic Tripod Ball Head for DSLR Cameras',
		category: 'electronics',
		subcategory: 'Tripods & Supports',
		price: 3542.38,
		keywords: ['photography', 'panorama', 'ball head', 'dslr'],
		images: [
			'https://sc04.alicdn.com/kf/H907d9d376f4b429fb625237f5b00d336T.jpg',
			'https://sc04.alicdn.com/kf/H3cdb7bc4578e417896b4b438f7a22581Z.jpg',
			'https://sc04.alicdn.com/kf/Hce06d8d51f1749178755fb105ed944aam.jpg'
		]
	},
	{
		id: 'electronics-5',
		title: 'PeriPage A9 Max 110 mm Wireless Thermal Photo Printer',
		category: 'electronics',
		subcategory: 'Printers',
		price: 4466.48,
		keywords: ['thermal printer', 'label', 'portable', 'photo'],
		images: [
			'https://sc04.alicdn.com/kf/Hf471a8e7747847f797ecb32825cfa5a36.jpg',
			'https://sc04.alicdn.com/kf/H43582b53ec064999ac5c8a06866ce939k.jpg',
			'https://sc04.alicdn.com/kf/H6173d084d82249c3a44392fa9c2eb52ap.jpg'
		]
	},
	{
		id: 'electronics-6',
		title: 'PULUZ Waterproof DSLR Camera Backpack',
		category: 'electronics',
		subcategory: 'Bags & Cases',
		price: 762.39,
		keywords: ['bag', 'backpack', 'camera bag', 'travel'],
		images: [
			'https://sc04.alicdn.com/kf/H83f0de491ffc47f08f96b7d16618c6760.jpg',
			'https://sc04.alicdn.com/kf/Haa4b13988e6941ca9f94b641b49f69653.jpg',
			'https://sc04.alicdn.com/kf/H99f9201cd4144995805c00492e186d30B.jpg'
		]
	},
	{
		id: 'electronics-7',
		title: 'Godox V850II 2.4G GN60 Li-ion Camera Flash Speedlite',
		category: 'electronics',
		subcategory: 'Flashes & Lighting',
		price: 6545.7,
		keywords: ['flash', 'speedlite', 'lighting', 'studio'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/H9521395442b84ffc8c0ab8082c05cfccf.jpg',
			'https://sc04.alicdn.com/kf/H22068bb4a376403fbfdc8f9e12ce6a3fC.jpg',
			'https://sc04.alicdn.com/kf/Hf878cfea710a4d8b9df84cc4d84190c73.jpg'
		]
	},
	{
		id: 'electronics-8',
		title: '3-in-1 Wide Angle, Macro, and Fisheye Phone Lens Kit',
		category: 'electronics',
		subcategory: 'Phone Lenses',
		price: 30.04,
		keywords: ['phone lens', 'macro', 'fisheye', 'mobile photography'],
		images: [
			'https://sc04.alicdn.com/kf/H1472c116665d4397940fdaa6c9817afe6.jpg',
			'https://sc04.alicdn.com/kf/Hb89454fb969648dd9fdd0ff7b3fe6fe9j.jpg',
			'https://sc04.alicdn.com/kf/H4cb751c525bf4f539887ee0d8002f45bA.jpg'
		]
	},
	{
		id: 'electronics-9',
		title: '4K Ultra HD Camcorder with 30X Zoom and Night Vision',
		category: 'electronics',
		subcategory: 'Camcorders',
		price: 15247.63,
		keywords: ['video camera', 'youtube', 'streaming', 'zoom'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/Hdf691402b048459cb36281a06c5082f0P.jpg',
			'https://sc04.alicdn.com/kf/Hec84e72787cf45be90de443e4bf077e3I.jpg',
			'https://sc04.alicdn.com/kf/H884ca434d9b74c65a2b84ead5acd4620O.jpg'
		]
	},
	{
		id: 'electronics-10',
		title: 'Kids Digital Camera with Cartoon Case',
		category: 'electronics',
		subcategory: 'Kids Cameras',
		price: 500.56,
		keywords: ['children', 'toy camera', 'kids gift'],
		images: [
			'https://sc04.alicdn.com/kf/Hf3966634bf7f4a4aa8d07fa595346736Q.jpg',
			'https://sc04.alicdn.com/kf/H1fac224f5e6b40c098d15bcdc9e7ff5fd.jpg',
			'https://sc04.alicdn.com/kf/H8f7eeb3f46ed43f7aba07d648890126dh.jpg'
		]
	},
	{
		id: 'electronics-11',
		title: 'AC3 4K Live Streaming Video Camera with Night Vision',
		category: 'electronics',
		subcategory: 'Camcorders',
		price: 19398.37,
		keywords: ['streaming', 'video', 'professional', 'night vision'],
		images: [
			'https://sc04.alicdn.com/kf/He458d157b21a49799953383b76ed6b46A.png',
			'https://sc04.alicdn.com/kf/H028fff2942fe451ab546c0468556cf680.jpg',
			'https://sc04.alicdn.com/kf/HTB14yqkdrus3KVjSZKbq6xqkFXaM.jpg'
		]
	},
	{
		id: 'electronics-12',
		title: 'GD99 RC Stunt Car with Gesture Sensing',
		category: 'electronics',
		subcategory: 'RC Vehicles',
		price: 1000.34,
		keywords: ['remote control', 'stunt car', 'toy', 'kids'],
		images: [
			'https://sc04.alicdn.com/kf/Hcad1f2325c464c2a9417f0644bb8d5b0P.jpg',
			'https://sc04.alicdn.com/kf/Ha71701e4367c4a5689f4c1326df63fc4t.jpg',
			'https://sc04.alicdn.com/kf/H00184557affd467c8f467740bf8b9feay.jpg'
		]
	},

	// Apparel and textiles
	{
		id: 'apparel-1',
		title: 'Baby Stroller Footmuff and Sleeping Bag',
		category: 'apparel',
		subcategory: 'Baby & Kids',
		price: 685.38,
		keywords: ['stroller', 'baby', 'sleeping bag', 'winter'],
		images: [
			'https://s.alicdn.com/@sc04/kf/Hc560d406452e41e6902beb258c45349c6.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-2',
		title: 'Waterproof Baby Bib with Sleeves',
		category: 'apparel',
		subcategory: 'Baby & Kids',
		price: 2804.64,
		keywords: ['bib', 'baby', 'feeding', 'weaning'],
		images: [
			'https://s.alicdn.com/@sc04/kf/H34899f77b37f4f4d9928861ffdd9c46fj.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-3',
		title: 'Custom Printed Disposable Baby Bibs',
		category: 'apparel',
		subcategory: 'Baby & Kids',
		price: 846.33,
		keywords: ['bib', 'baby', 'disposable', 'custom'],
		images: [
			'https://s.alicdn.com/@sc04/kf/Hc8d6b670439f45e88776fdb717ebf15ap.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-4',
		title: 'Long-Sleeve Waterproof Baby Apron Bib',
		category: 'apparel',
		subcategory: 'Baby & Kids',
		price: 3542.38,
		keywords: ['bib', 'apron', 'baby', 'waterproof'],
		images: [
			'https://s.alicdn.com/@sc04/kf/H2b34409f61974c31a733f15e016c2524G.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-5',
		title: 'Purple Beaded Moroccan Kaftan Evening Dress',
		category: 'apparel',
		subcategory: 'Dresses & Abayas',
		price: 4466.48,
		keywords: ['kaftan', 'dress', 'evening', 'moroccan', 'modest wear'],
		featured: true,
		images: [
			'https://s.alicdn.com/@sc04/kf/Ha7fe53c6379f49a3beca59997b2148a9p.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-6',
		title: 'Plus-Size Maxi Abaya Dress',
		category: 'apparel',
		subcategory: 'Dresses & Abayas',
		price: 762.39,
		keywords: ['abaya', 'maxi dress', 'modest wear', 'summer'],
		featured: true,
		images: [
			'https://s.alicdn.com/@sc04/kf/H414ac827bcd14dc88d9e5a126f8c4256H.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-7',
		title: 'Pink Turkish Long Dress Abaya',
		category: 'apparel',
		subcategory: 'Dresses & Abayas',
		price: 6545.7,
		keywords: ['abaya', 'turkish dress', 'modest wear', 'pink'],
		featured: true,
		images: [
			'https://s.alicdn.com/@sc04/kf/H7fc92335f35c44b68affe9eb8c025954z.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-8',
		title: 'Dubai Daffah Thawb',
		category: 'apparel',
		subcategory: "Men's Wear",
		price: 30.04,
		keywords: ['thawb', 'khamis', 'men', 'dubai', 'traditional'],
		images: [
			'https://s.alicdn.com/@sc04/kf/H2b28e95ac4bf4faf8ff3532eb82f0509Y.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-9',
		title: 'Sofa Elastic Webbing',
		category: 'apparel',
		subcategory: 'Garment Accessories',
		price: 15247.63,
		keywords: ['webbing', 'upholstery', 'elastic', 'furniture'],
		images: [
			'https://s.alicdn.com/@sc04/kf/H5fc5ac0a31a9477abbc40859c21c9aa5z.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-10',
		title: 'Manual KAM Snap Button Press for DK93/DK98',
		category: 'apparel',
		subcategory: 'Garment Accessories',
		price: 500.56,
		keywords: ['snap button', 'kam', 'sewing', 'garment tool'],
		images: [
			'https://s.alicdn.com/@sc04/kf/HTB1LkKDgS7PL1JjSZFHq6AciXXaF.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-11',
		title: 'Metal Suspender Clips',
		category: 'apparel',
		subcategory: 'Garment Accessories',
		price: 19398.37,
		keywords: ['suspender clips', 'metal clips', 'garment hardware'],
		images: [
			'https://s.alicdn.com/@sc04/kf/HTB1Hz.gc56guuRjy0Fmq6y0DXXaE.jpg_220x220.jpg'
		]
	},
	{
		id: 'apparel-12',
		title: 'Custom Soft PVC Rubber Patch',
		category: 'apparel',
		subcategory: 'Garment Accessories',
		price: 1000.34,
		keywords: ['pvc patch', 'rubber patch', 'custom logo', 'branding'],
		images: [
			'https://s.alicdn.com/@sc04/kf/H325ff3433c544f59b5c87175fda32427T.jpg_220x220.jpg'
		]
	},

	// Car parts and accessories
	{
		id: 'car-parts-1',
		title: '12V 5kW Diesel Parking Heater for Caravan and RV',
		category: 'car-parts',
		subcategory: 'Heating & Cooling',
		price: 6935.4,
		keywords: ['diesel heater', 'parking heater', 'caravan', 'rv', '12v'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/H5413e7cafb99486594dd8aae4081a342X.png',
			'https://sc04.alicdn.com/kf/HTB192NiXqL7gK0jSZFBq6xZZpXaP.jpg',
			'https://sc04.alicdn.com/kf/H2095907730c24f4c9c42e824c68366fbI.jpg'
		]
	},
	{
		id: 'car-parts-2',
		title: '8-Inch Rugged Android Tablet for Vehicle Tracking',
		category: 'car-parts',
		subcategory: 'Car Electronics',
		price: 26971,
		keywords: ['tablet', 'android', 'gps', 'tracking', 'fleet'],
		images: [
			'https://sc04.alicdn.com/kf/H7c99959d26f94e66a4e6d0560ccce2390.jpg',
			'https://sc04.alicdn.com/kf/H466cf5bede984c838ef8ad898662447cY.jpg',
			'https://sc04.alicdn.com/kf/Ha6b2e0ee3c3d4addb53545de65540c4eb.jpg'
		]
	},
	{
		id: 'car-parts-3',
		title: 'FM Transmitter and Bluetooth Car Kit',
		category: 'car-parts',
		subcategory: 'Car Electronics',
		price: 153.35,
		keywords: ['fm transmitter', 'bluetooth', 'audio', 'mp3'],
		images: [
			'https://sc04.alicdn.com/kf/He1e5eedda0644a54a2d1e244c1250246N.jpg',
			'https://sc04.alicdn.com/kf/H92aac69e86f0420fab27f08f622180dcG.jpg',
			'https://sc04.alicdn.com/kf/H79b48782bad74590bb69353c81954b29w.jpg'
		]
	},
	{
		id: 'car-parts-4',
		title: '12V 80Ah Lithium Car Battery',
		category: 'car-parts',
		subcategory: 'Batteries & Charging',
		price: 3542.38,
		keywords: ['battery', 'lithium', '12v', 'auto'],
		images: [
			'https://sc04.alicdn.com/kf/Hcede0d1effa74aa387ca2ec5c1aef9d0i.jpg_50x50.jpg',
			'https://sc04.alicdn.com/kf/He9b8eef0a10b41dd99e978ca79a43f553.jpg',
			'https://sc04.alicdn.com/kf/H5d5f82d1a01c4b14b2a50f161560bfffo.jpg'
		]
	},
	{
		id: 'car-parts-5',
		title: '171-Piece Auto Repair Tool Kit',
		category: 'car-parts',
		subcategory: 'Tools & Repair',
		price: 3066.99,
		keywords: ['tools', 'repair', 'toolbox', 'automotive'],
		images: [
			'https://sc04.alicdn.com/kf/H535bf24afb044aa79d7493a1bdabacaaC.jpg_50x50.jpg',
			'https://sc04.alicdn.com/kf/H445030017e8745629727f18d89efa1eaI.jpg',
			'https://sc04.alicdn.com/kf/He14b0532f11449ad9f388f0a620c1366W.jpg'
		]
	},
	{
		id: 'car-parts-6',
		title: 'PDR Dent Repair Puller with Suction Cup',
		category: 'car-parts',
		subcategory: 'Tools & Repair',
		price: 142.39,
		keywords: ['dent repair', 'pdr', 'bodywork', 'puller'],
		images: [
			'https://sc04.alicdn.com/kf/HTB1Vh7seQ5E3KVjSZFCq6zuzXXaT.jpg',
			'https://sc04.alicdn.com/kf/Hcbd67c1d9d914443a2d15216a190aadaq.jpg',
			'https://sc04.alicdn.com/kf/Hd3793226a45744c3a1c0cbf04ce62ba3Z.jpg'
		]
	},
	{
		id: 'car-parts-7',
		title: 'Water Pump for Toyota Prius 2004–2009',
		category: 'car-parts',
		subcategory: 'Cooling System',
		price: 1695.32,
		keywords: ['water pump', 'prius', 'toyota', 'cooling'],
		images: [
			'https://sc04.alicdn.com/kf/H67e7446624104cf39f52c0d2689056d3y.png',
			'https://sc04.alicdn.com/kf/H636698c6db464acaaf2fa92f4cd461095.png',
			'https://sc04.alicdn.com/kf/Hf71249410a984fa381c1bc49cbced198j.png'
		]
	},
	{
		id: 'car-parts-8',
		title: '12V/24V Dual USB 4.8A Car Charger',
		category: 'car-parts',
		subcategory: 'Chargers',
		price: 322.12,
		keywords: ['usb charger', '12v', '24v', 'marine', 'adapter'],
		images: [
			'https://sc04.alicdn.com/kf/Hce92c0da20a647ffbc9f94a7c4a247abh.jpg',
			'https://sc04.alicdn.com/kf/H7faafb3f1c05412baf83e1a2bd4740548.jpg',
			'https://sc04.alicdn.com/kf/H8383238e16d54c858b02875311d4e7b0a.jpg'
		]
	},
	{
		id: 'car-parts-9',
		title: 'Windshield Crack Repair Kit',
		category: 'car-parts',
		subcategory: 'Car Care',
		price: 122.53,
		keywords: ['windshield', 'glass repair', 'crack', 'diy'],
		images: [
			'https://sc04.alicdn.com/kf/Hfd40fe42613c40149a4e9b7337e884b1B.jpg',
			'https://sc04.alicdn.com/kf/H5aa2391d2cf94cae8fd0192b76d67035g.jpg',
			'https://sc04.alicdn.com/kf/H08a66799baba40f9b85cee3c3691919au.jpg'
		]
	},
	{
		id: 'car-parts-10',
		title: 'Hanging Tree Car Air Freshener',
		category: 'car-parts',
		subcategory: 'Car Care',
		price: 62.56,
		keywords: ['air freshener', 'scent', 'hanging tree', 'cabin'],
		images: [
			'https://sc04.alicdn.com/kf/H901b5f711c7b463eaa1f7691b53e99cdH.jpg',
			'https://sc04.alicdn.com/kf/H18aa5e23031344e68415398fae126a18Q.jpg',
			'https://sc04.alicdn.com/kf/H411b8f3efbab46ebb5574429dc615ddau.jpg'
		]
	},
	{
		id: 'car-parts-11',
		title: 'Full HD Dual-Lens Dash Camera with WiFi',
		category: 'car-parts',
		subcategory: 'Dash Cameras',
		price: 1695.37,
		keywords: ['dash cam', 'dvr', 'dashcam', 'wifi', 'dual lens'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/H10eaf657af93433a849bd12c0692f97ay.jpg',
			'https://sc04.alicdn.com/kf/H15bcdbb69e2a44a0a80003d0b4f3916eX.jpg',
			'https://sc04.alicdn.com/kf/Hbe9a19165f1b4582bea4422d0b456f0f3.jpg'
		]
	},
	{
		id: 'car-parts-12',
		title: '12V 7-Inch Android Car Monitor',
		category: 'car-parts',
		subcategory: 'Car Electronics',
		price: 2157.68,
		keywords: ['monitor', 'android', 'car screen', 'mp5'],
		images: [
			'https://sc04.alicdn.com/kf/Hc184b8e144bb48e3b1fa43ee89f701caC.jpg',
			'https://sc04.alicdn.com/kf/Hb429c6bab7ce4eb0b1312ec964099035U.jpg',
			'https://sc04.alicdn.com/kf/H5e475083992640c9841cf5476a6e9560Q.jpg'
		]
	},
	{
		id: 'car-parts-13',
		title: 'LED Headlight Bulbs, H1/H4/H7',
		category: 'car-parts',
		subcategory: 'Lighting',
		price: 84.77,
		keywords: ['headlight', 'led', 'bulb', 'headlamp', 'h4', 'h7'],
		images: [
			'https://sc04.alicdn.com/kf/H28e0dd8fbeca49019a34d16f94a75bcfn.jpg_50x50.jpg',
			'https://sc04.alicdn.com/kf/H5c57bda362f04969906e215a320ed8a8C.jpg',
			'https://sc04.alicdn.com/kf/H3f7823c3fb9642a69d227e5bed5d7260o.jpg'
		]
	},
	{
		id: 'car-parts-14',
		title: 'LED Headlights for Toyota, Lexus, and Camry',
		category: 'car-parts',
		subcategory: 'Lighting',
		price: 7706,
		keywords: ['headlight', 'toyota', 'lexus', 'camry', 'led'],
		images: [
			'https://sc04.alicdn.com/kf/H3fd0455f361442e9b10a6782dcd3bb9a5.jpg',
			'https://sc04.alicdn.com/kf/H399cf543c0af4a3e9b16f3bca7681120D.jpg',
			'https://sc04.alicdn.com/kf/H5c00e5b144f04c239c836fbd6423508av.jpg'
		]
	},
	{
		id: 'car-parts-15',
		title: 'Cordless 24V Car Pressure Washer',
		category: 'car-parts',
		subcategory: 'Car Care',
		price: 2003.56,
		keywords: ['pressure washer', 'car wash', 'cordless', 'foam gun'],
		featured: true,
		images: [
			'https://sc04.alicdn.com/kf/H1a002ff8445347bdbe7594c493375917H.jpg',
			'https://sc04.alicdn.com/kf/H57cbd02d7d7148159cad71baa2801a90P.jpg',
			'https://sc04.alicdn.com/kf/H7144e745e62241fc8621e146b399bf25i.jpg_50x50.jpg'
		]
	},
	{
		id: 'car-parts-16',
		title: '12V/24V Portable Jump Starter and Battery Charger',
		category: 'car-parts',
		subcategory: 'Batteries & Charging',
		price: 1386.52,
		keywords: ['jump starter', 'battery charger', 'portable', '12v'],
		images: [
			'https://sc04.alicdn.com/kf/H5987d9fbd2bd4101b57cbda33b5fbd5fH.jpg',
			'https://sc04.alicdn.com/kf/Hd6240ef6378a4ba88df99bfb454df449d.jpg'
		]
	},
	{
		id: 'car-parts-17',
		title: '7-Inch Flip-Down Car Monitor',
		category: 'car-parts',
		subcategory: 'Car Electronics',
		price: 1048.25,
		keywords: ['monitor', 'flip down', 'mp5', 'car screen'],
		images: [
			'https://sc04.alicdn.com/kf/H313cd05966554145bd576022b666bb18k.jpg',
			'https://sc04.alicdn.com/kf/Hbdb34cde0f1b4d0e90752c2d6d839d01A.jpg',
			'https://sc04.alicdn.com/kf/H307a2807e8404f86989cbdead8f10887T.jpg'
		]
	},
	{
		id: 'car-parts-18',
		title: 'Front CV Axle Drive Shaft Joint',
		category: 'car-parts',
		subcategory: 'Drivetrain',
		price: 649,
		keywords: ['cv axle', 'drive shaft', 'cv joint', 'drivetrain'],
		images: [
			'https://sc04.alicdn.com/kf/H40efaf67b1f44ca3a82a730edaf4ca4aK.jpg',
			'https://sc04.alicdn.com/kf/Had69516af69c447d95466e118f35e383H.jpg',
			'https://sc04.alicdn.com/kf/H0e6c40a5021b43b69d164790c0ffc581u.jpg'
		]
	},
	{
		id: 'car-parts-19',
		title: 'Turbo Sound Whistle Exhaust Simulator',
		category: 'car-parts',
		subcategory: 'Exhaust & Performance',
		price: 50.86,
		keywords: ['turbo', 'whistle', 'exhaust', 'sound simulator'],
		images: [
			'https://sc04.alicdn.com/kf/He892b05f44764de1a2f0db5319b2873ew.jpg',
			'https://sc04.alicdn.com/kf/H1780024833b84cfea86e6aaa26520b05a.jpg',
			'https://sc04.alicdn.com/kf/H8bf4057749bb4b4bbf56f65c1016b62eh.jpg_50x50.jpg'
		]
	},
	{
		id: 'car-parts-20',
		title: 'Effervescent Windshield Cleaning Tablets',
		category: 'car-parts',
		subcategory: 'Car Care',
		price: 1.55,
		keywords: ['windshield cleaner', 'tablet', 'glass', 'car care'],
		images: [
			'https://sc04.alicdn.com/kf/H7fd7604167e643c8ade4206606d553cbV.png',
			'https://sc04.alicdn.com/kf/H7afa1a8a925442c78cc4f16b41ad4df2p.png',
			'https://sc04.alicdn.com/kf/H5de17d66208140c59f7bd77031aa6181N.jpg'
		]
	}
];

function makeProduct(raw, index) {
	const category = CATEGORY_BY_SLUG.get(raw.category);
	const images = [...new Set((raw.images ?? []).map(stripImageSize).filter(Boolean))];

	return Object.freeze({
		id: raw.id,
		title: raw.title,
		category: raw.category,
		categoryLabel: category?.label ?? 'Market',
		subcategory: raw.subcategory,
		price: roundMoney(raw.price),
		images: Object.freeze(images),
		description: raw.description ?? `${raw.title}. ${CATEGORY_COPY[raw.category]}`,
		keywords: Object.freeze(raw.keywords ?? []),
		stock: raw.stock ?? 10,
		featured: Boolean(raw.featured),
		badge: raw.badge ?? (raw.featured ? 'Market pick' : null),
		order: index
	});
}

export const PRODUCTS = Object.freeze(RAW_PRODUCTS.map(makeProduct));

const PRODUCT_BY_ID = new Map(PRODUCTS.map((product) => [product.id, product]));

export function getProductById(id) {
	return PRODUCT_BY_ID.get(id) ?? null;
}

export function getCategory(slug) {
	return CATEGORY_BY_SLUG.get(slug) ?? null;
}

export function getCategoryCount(slug) {
	return PRODUCTS.filter((product) => product.category === slug).length;
}

export function categoryCounts() {
	return Object.fromEntries(CATEGORIES.map((category) => [category.slug, getCategoryCount(category.slug)]));
}

export function getFeatured(limit = 8) {
	return PRODUCTS.filter((product) => product.featured).slice(0, limit);
}

export function getRelated(product, limit = 4) {
	if (!product) return [];

	const sameCategory = PRODUCTS.filter(
		(candidate) => candidate.category === product.category && candidate.id !== product.id
	);
	const sameSubcategory = sameCategory.filter(
		(candidate) => candidate.subcategory === product.subcategory
	);
	const rest = sameCategory.filter((candidate) => candidate.subcategory !== product.subcategory);

	return [...sameSubcategory, ...rest].slice(0, limit);
}

export function isValidSort(value) {
	return SORT_OPTIONS.some((option) => option.value === value);
}

export function queryProducts({ q = '', category = '', sort = 'featured' } = {}) {
	const tokens = normalizeText(q).split(' ').filter(Boolean);
	const activeCategory = getCategory(category) ? category : '';
	const activeSort = isValidSort(sort) ? sort : 'featured';

	let matches = PRODUCTS.filter((product) => {
		if (activeCategory && product.category !== activeCategory) return false;
		if (!tokens.length) return true;

		const haystack = normalizeText(
			[
				product.title,
				product.subcategory,
				product.categoryLabel,
				...product.keywords,
				...product.description.split(/[.!?]/)
			].join(' ')
		);

		return tokens.every((token) => haystack.includes(token));
	});

	matches = [...matches];

	switch (activeSort) {
		case 'price-asc':
			matches.sort((a, b) => a.price - b.price || a.order - b.order);
			break;
		case 'price-desc':
			matches.sort((a, b) => b.price - a.price || a.order - b.order);
			break;
		case 'name-asc':
			matches.sort((a, b) => a.title.localeCompare(b.title));
			break;
		default:
			matches.sort((a, b) => Number(b.featured) - Number(a.featured) || a.order - b.order);
	}

	return matches;
}
