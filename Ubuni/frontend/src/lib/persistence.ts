import type { Design, Door, FurnitureItem, Point, Room, Wall, Window } from './types';
import {
	DEFAULT_DOOR_WIDTH,
	DEFAULT_WALL_THICKNESS,
	DEFAULT_WINDOW_WIDTH,
	clampOpeningPosition,
	distance,
	newId
} from './geometry';
import { design } from './store';

export const STORAGE_KEY = 'ubuni:design:v1';
export const SCHEMA_VERSION = 1;

const ROOM_COLORS = ['#93c5fd', '#86efac', '#fcd34d', '#f9a8d4', '#c4b5fd', '#67e8f9'];

function hasStorage(): boolean {
	return typeof window !== 'undefined' && typeof localStorage !== 'undefined';
}

type RecordValue = Record<string, unknown>;

function isRecord(value: unknown): value is RecordValue {
	return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function asString(value: unknown, fallback: string): string {
	return typeof value === 'string' && value.length > 0 ? value : fallback;
}

function asNumber(value: unknown, fallback: number): number {
	return typeof value === 'number' && Number.isFinite(value) ? value : fallback;
}

function asPoint(value: unknown): Point | null {
	if (!isRecord(value)) return null;
	const x = value.x;
	const y = value.y;
	if (typeof x !== 'number' || typeof y !== 'number') return null;
	if (!Number.isFinite(x) || !Number.isFinite(y)) return null;
	return { x, y };
}

function asDate(value: unknown): Date {
	if (typeof value === 'string' || typeof value === 'number') {
		const parsed = new Date(value);
		if (!Number.isNaN(parsed.getTime())) return parsed;
	}
	return new Date();
}

function normalizeWall(value: unknown): Wall | null {
	if (!isRecord(value)) return null;
	const start = asPoint(value.start);
	const end = asPoint(value.end);
	const thickness = asNumber(value.thickness, DEFAULT_WALL_THICKNESS);
	if (!start || !end || thickness <= 0) return null;
	if (distance(start, end) < 1e-6) return null;
	return { id: asString(value.id, newId()), start, end, thickness };
}

function normalizeRoom(value: unknown, index: number): Room | null {
	if (!isRecord(value) || !Array.isArray(value.points)) return null;
	const points = value.points.map(asPoint).filter((point): point is Point => point !== null);
	if (points.length < 3) return null;
	return {
		id: asString(value.id, newId()),
		points,
		label: asString(value.label, `Room ${index + 1}`),
		color: asString(value.color, ROOM_COLORS[index % ROOM_COLORS.length])
	};
}

function normalizeDoor(value: unknown, walls: Wall[]): Door | null {
	if (!isRecord(value)) return null;
	const position = asPoint(value.position);
	const wallId = typeof value.wallId === 'string' ? value.wallId : '';
	const wall = walls.find((candidate) => candidate.id === wallId);
	if (!position || !wall) return null;
	const width = Math.max(0.1, asNumber(value.width, DEFAULT_DOOR_WIDTH));
	return {
		id: asString(value.id, newId()),
		position: clampOpeningPosition(position, wall, width),
		width,
		wallId
	};
}

function normalizeWindow(value: unknown, walls: Wall[]): Window | null {
	if (!isRecord(value)) return null;
	const position = asPoint(value.position);
	const wallId = typeof value.wallId === 'string' ? value.wallId : '';
	const wall = walls.find((candidate) => candidate.id === wallId);
	if (!position || !wall) return null;
	const width = Math.max(0.1, asNumber(value.width, DEFAULT_WINDOW_WIDTH));
	return {
		id: asString(value.id, newId()),
		position: clampOpeningPosition(position, wall, width),
		width,
		wallId
	};
}

function normalizeFurniture(value: unknown): FurnitureItem | null {
	if (!isRecord(value)) return null;
	const position = asPoint(value.position);
	const size = asPoint(value.size);
	if (!position || !size || size.x <= 0 || size.y <= 0) return null;
	return {
		id: asString(value.id, newId()),
		name: asString(value.name, 'Furniture'),
		position,
		size,
		rotation: asNumber(value.rotation, 0),
		category: asString(value.category, 'decor')
	};
}

export function normalizeDesign(input: unknown): Design | null {
	if (!isRecord(input)) return null;
	if (
		!Array.isArray(input.walls) ||
		!Array.isArray(input.rooms) ||
		!Array.isArray(input.doors) ||
		!Array.isArray(input.windows) ||
		!Array.isArray(input.furniture)
	) {
		return null;
	}

	const walls = input.walls
		.map(normalizeWall)
		.filter((wall): wall is Wall => wall !== null);
	const wallIds = new Set(walls.map((wall) => wall.id));

	const rooms = input.rooms
		.map((room, index) => normalizeRoom(room, index))
		.filter((room): room is Room => room !== null);

	const doors = input.doors
		.map((door) => normalizeDoor(door, walls))
		.filter((door): door is Door => door !== null && wallIds.has(door.wallId));

	const windows = input.windows
		.map((window) => normalizeWindow(window, walls))
		.filter((window): window is Window => window !== null && wallIds.has(window.wallId));

	const furniture = input.furniture
		.map(normalizeFurniture)
		.filter((item): item is FurnitureItem => item !== null);

	return {
		id: asString(input.id, newId()),
		name: asString(input.name, 'Untitled Design'),
		walls,
		rooms,
		doors,
		windows,
		furniture,
		createdAt: asDate(input.createdAt),
		updatedAt: asDate(input.updatedAt)
	};
}

export function loadPersistedDesign(): Design | null {
	if (!hasStorage()) return null;
	try {
		const raw = localStorage.getItem(STORAGE_KEY);
		if (!raw) return null;
		return normalizeDesign(JSON.parse(raw) as unknown);
	} catch {
		return null;
	}
}

export function savePersistedDesign(next: Design): void {
	if (!hasStorage()) return;
	try {
		localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
	} catch {
		// Storage can be unavailable (private mode, quota). Autosave is best-effort.
	}
}

export function startAutosave(): () => void {
	let timer: ReturnType<typeof setTimeout> | undefined;
	const unsubscribe = design.subscribe((current) => {
		if (timer) clearTimeout(timer);
		timer = setTimeout(() => savePersistedDesign(current), 400);
	});

	return () => {
		unsubscribe();
		if (timer) clearTimeout(timer);
	};
}

export function exportEnvelope(next: Design) {
	return {
		schemaVersion: SCHEMA_VERSION,
		exportedAt: new Date().toISOString(),
		design: next
	};
}

export function designFromImport(input: unknown): Design | null {
	if (!isRecord(input)) return null;
	const candidate = 'design' in input ? input.design : input;
	return normalizeDesign(candidate);
}
