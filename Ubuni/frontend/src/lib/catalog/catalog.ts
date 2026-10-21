import type { FurnitureTemplate } from '$lib/types';

// Sizes are stored in meters. The catalog UI converts them to centimeters.
export const furnitureLibrary: FurnitureTemplate[] = [
	{ id: 'sofa-1', name: 'Sofa', category: 'seating', size: { x: 0.9, y: 0.4 } },
	{ id: 'chair-1', name: 'Armchair', category: 'seating', size: { x: 0.35, y: 0.35 } },
	{ id: 'table-1', name: 'Dining Table', category: 'tables', size: { x: 0.6, y: 0.4 } },
	{ id: 'bed-1', name: 'Bed', category: 'beds', size: { x: 0.6, y: 0.8 } },
	{ id: 'desk-1', name: 'Desk', category: 'tables', size: { x: 0.5, y: 0.3 } },
	{ id: 'cabinet-1', name: 'Cabinet', category: 'storage', size: { x: 0.3, y: 0.2 } },
	{ id: 'shelf-1', name: 'Bookshelf', category: 'storage', size: { x: 0.4, y: 0.15 } },
	{ id: 'lamp-1', name: 'Floor Lamp', category: 'lighting', size: { x: 0.1, y: 0.1 } },
	{ id: 'plant-1', name: 'Potted Plant', category: 'decor', size: { x: 0.12, y: 0.12 } },
	{ id: 'rug-1', name: 'Area Rug', category: 'decor', size: { x: 0.8, y: 0.6 } }
];
