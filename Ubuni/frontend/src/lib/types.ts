export type Point = { x: number; y: number };

export type Wall = {
	id: string;
	start: Point;
	end: Point;
	thickness: number;
};

export type Room = {
	id: string;
	points: Point[];
	label: string;
	color: string;
};

export type Door = {
	id: string;
	position: Point;
	width: number;
	wallId: string;
};

export type Window = {
	id: string;
	position: Point;
	width: number;
	wallId: string;
};

export type FurnitureItem = {
	id: string;
	name: string;
	position: Point;
	size: Point;
	rotation: number;
	category: string;
};

export type FurnitureTemplate = {
	id: string;
	name: string;
	category: string;
	size: Point;
};

export type Design = {
	id: string;
	name: string;
	walls: Wall[];
	rooms: Room[];
	doors: Door[];
	windows: Window[];
	furniture: FurnitureItem[];
	createdAt: Date;
	updatedAt: Date;
};

export type CanvasTool =
	| 'select'
	| 'wall'
	| 'room'
	| 'door'
	| 'window'
	| 'furniture'
	| 'pan';

export type ViewMode = '2d' | '3d';

export type SelectionType = 'wall' | 'room' | 'door' | 'window' | 'furniture';

export type Selection = { type: SelectionType; id: string } | null;
