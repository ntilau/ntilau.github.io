import type { Design, FurnitureItem, Point, Room, Wall } from './types';
import type { Bounds } from './geometry';
import {
	designBounds,
	distance,
	furnitureCorners,
	openingsForWall,
	pointAlongWall,
	polygonCentroid,
	wallSegments
} from './geometry';

export type PlanWallSegment = {
	wallId: string;
	start: Point;
	end: Point;
	thickness: number;
};

export type PlanOpening = {
	id: string;
	kind: 'door' | 'window';
	wallId: string;
	width: number;
	thickness: number;
	center: Point;
	start: Point;
	end: Point;
	direction: Point;
	normal: Point;
	hinge: Point;
	leafEnd: Point;
	arc: Point[];
};

export type PlanRoom = {
	room: Room;
	centroid: Point;
};

export type PlanFurniture = {
	item: FurnitureItem;
	corners: Point[];
};

export type Plan = {
	design: Design;
	bounds: Bounds;
	walls: PlanWallSegment[];
	rooms: PlanRoom[];
	doors: PlanOpening[];
	windows: PlanOpening[];
	furniture: PlanFurniture[];
};

function unitDirection(wall: Wall): Point {
	const length = distance(wall.start, wall.end);
	if (length < 1e-9) return { x: 1, y: 0 };
	return {
		x: (wall.end.x - wall.start.x) / length,
		y: (wall.end.y - wall.start.y) / length
	};
}

function doorArc(hinge: Point, direction: Point, normal: Point, radius: number): Point[] {
	const startAngle = Math.atan2(direction.y, direction.x);
	const endAngle = Math.atan2(normal.y, normal.x);
	let delta = endAngle - startAngle;
	while (delta > Math.PI) delta -= Math.PI * 2;
	while (delta < -Math.PI) delta += Math.PI * 2;

	const points: Point[] = [];
	const steps = 16;
	for (let index = 0; index <= steps; index += 1) {
		const angle = startAngle + (delta * index) / steps;
		points.push({
			x: hinge.x + Math.cos(angle) * radius,
			y: hinge.y + Math.sin(angle) * radius
		});
	}
	return points;
}

export function buildPlan(design: Design): Plan {
	const walls: PlanWallSegment[] = [];
	const doors: PlanOpening[] = [];
	const windows: PlanOpening[] = [];

	for (const wall of design.walls) {
		const direction = unitDirection(wall);
		const normal = { x: -direction.y, y: direction.x };
		const openings = openingsForWall(design, wall);
		const segments = wallSegments(wall, openings);

		for (const segment of segments) {
			walls.push({
				wallId: wall.id,
				start: segment.start,
				end: segment.end,
				thickness: wall.thickness
			});
		}

		for (const opening of openings) {
			const start = pointAlongWall(wall, opening.t - opening.width / 2);
			const end = pointAlongWall(wall, opening.t + opening.width / 2);
			const hinge = start;
			const leafEnd = {
				x: hinge.x + normal.x * opening.width,
				y: hinge.y + normal.y * opening.width
			};
			const entry: PlanOpening = {
				id: opening.id,
				kind: opening.kind,
				wallId: wall.id,
				width: opening.width,
				thickness: wall.thickness,
				center: opening.position,
				start,
				end,
				direction,
				normal,
				hinge,
				leafEnd,
				arc: opening.kind === 'door' ? doorArc(hinge, direction, normal, opening.width) : []
			};
			if (opening.kind === 'door') doors.push(entry);
			else windows.push(entry);
		}
	}

	return {
		design,
		bounds: designBounds(design),
		walls,
		rooms: design.rooms.map((room) => ({ room, centroid: polygonCentroid(room.points) })),
		doors,
		windows,
		furniture: design.furniture.map((item) => ({
			item,
			corners: furnitureCorners(item)
		}))
	};
}

export function paddedBounds(bounds: Bounds, padding: number): Bounds {
	if (bounds.width === 0 && bounds.height === 0) {
		const width = Math.max(4, padding * 2);
		const height = Math.max(3, padding * 2);
		return {
			minX: -width / 2,
			minY: -height / 2,
			maxX: width / 2,
			maxY: height / 2,
			width,
			height
		};
	}
	return {
		minX: bounds.minX - padding,
		minY: bounds.minY - padding,
		maxX: bounds.maxX + padding,
		maxY: bounds.maxY + padding,
		width: bounds.width + padding * 2,
		height: bounds.height + padding * 2
	};
}
