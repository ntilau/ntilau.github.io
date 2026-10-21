import type { Design, Door, FurnitureItem, Point, Room, Wall, Window } from './types';

export type Bounds = {
	minX: number;
	minY: number;
	maxX: number;
	maxY: number;
	width: number;
	height: number;
};

export type WallHit = {
	wall: Wall;
	point: Point;
	t: number;
	distance: number;
};

export type OpeningKind = 'door' | 'window';

export type OpeningPlacement = {
	id: string;
	kind: OpeningKind;
	width: number;
	t: number;
	position: Point;
	wallId: string;
};

export type WallSegment = {
	start: Point;
	end: Point;
	startT: number;
	endT: number;
};

export const SNAP_STEP = 0.1;
export const ENDPOINT_SNAP = 0.25;
export const DEFAULT_WALL_THICKNESS = 0.15;
export const DEFAULT_DOOR_WIDTH = 0.9;
export const DEFAULT_WINDOW_WIDTH = 1.2;

export function clamp(value: number, min: number, max: number): number {
	return Math.min(max, Math.max(min, value));
}

export function newId(): string {
	if (typeof crypto !== 'undefined' && typeof crypto.randomUUID === 'function') {
		return crypto.randomUUID();
	}
	return `id-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
}

function round(value: number, decimals = 4): number {
	const factor = 10 ** decimals;
	return Math.round(value * factor) / factor;
}

export function distance(a: Point, b: Point): number {
	return Math.hypot(b.x - a.x, b.y - a.y);
}

export function wallLength(wall: Wall): number {
	return distance(wall.start, wall.end);
}

export function normalizeAngle(angle: number): number {
	const full = Math.PI * 2;
	const wrapped = angle % full;
	return wrapped < 0 ? wrapped + full : wrapped;
}

export function snapValue(value: number, step = SNAP_STEP): number {
	if (step <= 0) return value;
	return round(Math.round(value / step) * step);
}

export function snapPoint(point: Point, step = SNAP_STEP, enabled = true): Point {
	if (!enabled) return { x: point.x, y: point.y };
	return { x: snapValue(point.x, step), y: snapValue(point.y, step) };
}

export function projectPointOnSegment(
	point: Point,
	start: Point,
	end: Point
): { point: Point; t: number; distance: number } {
	const dx = end.x - start.x;
	const dy = end.y - start.y;
	const lengthSq = dx * dx + dy * dy;

	if (lengthSq === 0) {
		return { point: { ...start }, t: 0, distance: distance(point, start) };
	}

	const raw = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSq;
	const u = clamp(raw, 0, 1);
	const projected = { x: start.x + dx * u, y: start.y + dy * u };
	return {
		point: projected,
		t: Math.sqrt(lengthSq) * u,
		distance: distance(point, projected)
	};
}

export function pointAlongWall(wall: Wall, t: number): Point {
	const length = wallLength(wall);
	if (length === 0) return { ...wall.start };
	const u = clamp(t / length, 0, 1);
	return {
		x: wall.start.x + (wall.end.x - wall.start.x) * u,
		y: wall.start.y + (wall.end.y - wall.start.y) * u
	};
}

export function closestWall(
	walls: Wall[],
	point: Point,
	maxDistance = Number.POSITIVE_INFINITY
): WallHit | null {
	let best: WallHit | null = null;
	for (const wall of walls) {
		const hit = projectPointOnSegment(point, wall.start, wall.end);
		if (hit.distance > maxDistance) continue;
		if (!best || hit.distance < best.distance) {
			best = { wall, point: hit.point, t: hit.t, distance: hit.distance };
		}
	}
	return best;
}

export function snapToEndpoint(
	point: Point,
	walls: Wall[],
	threshold = ENDPOINT_SNAP,
	excludeWallId?: string
): Point | null {
	let best: Point | null = null;
	let bestDistance = threshold;
	for (const wall of walls) {
		if (excludeWallId && wall.id === excludeWallId) continue;
		for (const endpoint of [wall.start, wall.end]) {
			const d = distance(point, endpoint);
			if (d <= bestDistance) {
				bestDistance = d;
				best = { ...endpoint };
			}
		}
	}
	return best;
}

export function clampOpeningPosition(point: Point, wall: Wall, width: number): Point {
	const length = wallLength(wall);
	if (length === 0) return { ...wall.start };
	const half = Math.min(width, length) / 2;
	if (length <= width) return pointAlongWall(wall, length / 2);
	const t = clamp(projectPointOnSegment(point, wall.start, wall.end).t, half, length - half);
	return pointAlongWall(wall, t);
}

export function openingsForWall(design: Design, wall: Wall): OpeningPlacement[] {
	const length = wallLength(wall);
	if (length === 0) return [];

	const raw: Array<{ id: string; kind: OpeningKind; width: number; t: number; wallId: string }> = [];

	for (const door of design.doors) {
		if (door.wallId !== wall.id) continue;
		const t = projectPointOnSegment(door.position, wall.start, wall.end).t;
		raw.push({ id: door.id, kind: 'door', width: door.width, t, wallId: wall.id });
	}
	for (const window of design.windows) {
		if (window.wallId !== wall.id) continue;
		const t = projectPointOnSegment(window.position, wall.start, wall.end).t;
		raw.push({ id: window.id, kind: 'window', width: window.width, t, wallId: wall.id });
	}

	return raw
		.map((opening) => {
			const width = Math.min(opening.width, length);
			const t =
				length <= width ? length / 2 : clamp(opening.t, width / 2, length - width / 2);
			return {
				id: opening.id,
				kind: opening.kind,
				width,
				t,
				wallId: opening.wallId,
				position: pointAlongWall(wall, t)
			};
		})
		.sort((a, b) => a.t - b.t);
}

export function mergedGapIntervals(openings: OpeningPlacement[]): Array<{ start: number; end: number }> {
	const intervals = openings
		.map((opening) => ({
			start: opening.t - opening.width / 2,
			end: opening.t + opening.width / 2
		}))
		.sort((a, b) => a.start - b.start);

	const merged: Array<{ start: number; end: number }> = [];
	for (const interval of intervals) {
		const last = merged[merged.length - 1];
		if (last && interval.start <= last.end + 1e-6) {
			last.end = Math.max(last.end, interval.end);
		} else {
			merged.push({ ...interval });
		}
	}
	return merged;
}

export function wallSegments(wall: Wall, openings: OpeningPlacement[]): WallSegment[] {
	const length = wallLength(wall);
	if (length === 0) return [];

	const gaps = mergedGapIntervals(openings);
	const segments: WallSegment[] = [];
	let cursor = 0;

	for (const gap of gaps) {
		const start = clamp(gap.start, 0, length);
		const end = clamp(gap.end, 0, length);
		if (start > cursor + 1e-6) {
			segments.push({
				start: pointAlongWall(wall, cursor),
				end: pointAlongWall(wall, start),
				startT: cursor,
				endT: start
			});
		}
		cursor = Math.max(cursor, end);
	}

	if (cursor < length - 1e-6) {
		segments.push({
			start: pointAlongWall(wall, cursor),
			end: pointAlongWall(wall, length),
			startT: cursor,
			endT: length
		});
	}

	return segments;
}

export function repositionOpenings<T extends Door | Window>(
	oldWall: Wall,
	newWall: Wall,
	openings: T[]
): T[] {
	return openings.map((opening) => {
		if (opening.wallId !== oldWall.id) return opening;
		const length = wallLength(newWall);
		const width = Math.min(opening.width, length);
		const oldT = projectPointOnSegment(opening.position, oldWall.start, oldWall.end).t;
		const t = length <= width ? length / 2 : clamp(oldT, width / 2, length - width / 2);
		return {
			...opening,
			width,
			position: pointAlongWall(newWall, t)
		};
	});
}

export function furnitureCorners(item: FurnitureItem): Point[] {
	const halfX = item.size.x / 2;
	const halfY = item.size.y / 2;
	const cos = Math.cos(item.rotation);
	const sin = Math.sin(item.rotation);
	const local: Point[] = [
		{ x: -halfX, y: -halfY },
		{ x: halfX, y: -halfY },
		{ x: halfX, y: halfY },
		{ x: -halfX, y: halfY }
	];
	return local.map((point) => ({
		x: item.position.x + point.x * cos - point.y * sin,
		y: item.position.y + point.x * sin + point.y * cos
	}));
}

export function polygonArea(points: Point[]): number {
	if (points.length < 3) return 0;
	let total = 0;
	for (let i = 0; i < points.length; i += 1) {
		const current = points[i];
		const next = points[(i + 1) % points.length];
		total += current.x * next.y - next.x * current.y;
	}
	return Math.abs(total) / 2;
}

export function polygonCentroid(points: Point[]): Point {
	if (points.length === 0) return { x: 0, y: 0 };
	if (points.length < 3) {
		return {
			x: points.reduce((sum, point) => sum + point.x, 0) / points.length,
			y: points.reduce((sum, point) => sum + point.y, 0) / points.length
		};
	}

	let twiceArea = 0;
	let cx = 0;
	let cy = 0;
	for (let i = 0; i < points.length; i += 1) {
		const current = points[i];
		const next = points[(i + 1) % points.length];
		const cross = current.x * next.y - next.x * current.y;
		twiceArea += cross;
		cx += (current.x + next.x) * cross;
		cy += (current.y + next.y) * cross;
	}

	if (Math.abs(twiceArea) < 1e-9) {
		return {
			x: points.reduce((sum, point) => sum + point.x, 0) / points.length,
			y: points.reduce((sum, point) => sum + point.y, 0) / points.length
		};
	}

	return { x: cx / (3 * twiceArea), y: cy / (3 * twiceArea) };
}

export function pointInPolygon(point: Point, polygon: Point[]): boolean {
	if (polygon.length < 3) return false;
	let inside = false;
	for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i, i += 1) {
		const a = polygon[i];
		const b = polygon[j];
		const intersects =
			a.y > point.y !== b.y > point.y &&
			point.x < ((b.x - a.x) * (point.y - a.y)) / (b.y - a.y || Number.EPSILON) + a.x;
		if (intersects) inside = !inside;
	}
	return inside;
}

export function designBounds(design: Design): Bounds {
	let minX = Number.POSITIVE_INFINITY;
	let minY = Number.POSITIVE_INFINITY;
	let maxX = Number.NEGATIVE_INFINITY;
	let maxY = Number.NEGATIVE_INFINITY;
	let hasPoint = false;

	const include = (point: Point, padding = 0) => {
		hasPoint = true;
		minX = Math.min(minX, point.x - padding);
		minY = Math.min(minY, point.y - padding);
		maxX = Math.max(maxX, point.x + padding);
		maxY = Math.max(maxY, point.y + padding);
	};

	for (const wall of design.walls) {
		const padding = wall.thickness / 2;
		include(wall.start, padding);
		include(wall.end, padding);
	}
	for (const room of design.rooms) {
		room.points.forEach((point) => include(point));
	}
	for (const item of design.furniture) {
		furnitureCorners(item).forEach((point) => include(point));
	}
	for (const opening of [...design.doors, ...design.windows]) {
		include(opening.position, opening.width / 2);
	}

	if (!hasPoint) {
		return { minX: 0, minY: 0, maxX: 0, maxY: 0, width: 0, height: 0 };
	}

	return {
		minX,
		minY,
		maxX,
		maxY,
		width: maxX - minX,
		height: maxY - minY
	};
}

export function boundsCenter(bounds: Bounds): Point {
	return {
		x: (bounds.minX + bounds.maxX) / 2,
		y: (bounds.minY + bounds.maxY) / 2
	};
}

export function isFinitePoint(value: unknown): value is Point {
	if (!value || typeof value !== 'object') return false;
	const point = value as Point;
	return Number.isFinite(point.x) && Number.isFinite(point.y);
}

export function roomPoints(room: Room): Point[] {
	return room.points;
}
