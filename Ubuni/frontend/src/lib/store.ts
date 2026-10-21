import { derived, get, writable } from 'svelte/store';
import type {
	CanvasTool,
	Design,
	Door,
	FurnitureTemplate,
	Point,
	Selection,
	ViewMode,
	Wall,
	Window
} from './types';
import {
	clamp,
	newId,
	normalizeAngle,
	pointAlongWall,
	projectPointOnSegment,
	wallLength
} from './geometry';

const HISTORY_LIMIT = 100;

function createDesign(name = 'Untitled Design'): Design {
	return {
		id: newId(),
		name,
		walls: [],
		rooms: [],
		doors: [],
		windows: [],
		furniture: [],
		createdAt: new Date(),
		updatedAt: new Date()
	};
}

export const design = writable<Design>(createDesign());
export const activeTool = writable<CanvasTool>('select');
export const viewMode = writable<ViewMode>('2d');
export const selection = writable<Selection>(null);
export const placementItem = writable<FurnitureTemplate | null>(null);
export const snapEnabled = writable<boolean>(true);
export const zoom2D = writable<number>(60);
export const cursorWorld = writable<Point | null>(null);
export const statusMessage = writable<string>('');
export const sidebarOpen = writable<boolean>(true);
export const fitRequest = writable<number>(0);

export const counts = derived(design, (current) => ({
	walls: current.walls.length,
	rooms: current.rooms.length,
	doors: current.doors.length,
	windows: current.windows.length,
	furniture: current.furniture.length
}));

const undoStack: Design[] = [];
const redoStack: Design[] = [];
export const canUndo = writable(false);
export const canRedo = writable(false);

let transactionSnapshot: Design | null = null;
let transactionDepth = 0;

function syncHistoryFlags() {
	canUndo.set(undoStack.length > 0);
	canRedo.set(redoStack.length > 0);
}

function pushUndo(snapshot: Design) {
	if (undoStack[undoStack.length - 1] === snapshot) return;
	undoStack.push(snapshot);
	if (undoStack.length > HISTORY_LIMIT) undoStack.shift();
	redoStack.length = 0;
	syncHistoryFlags();
}

function clearHistory() {
	undoStack.length = 0;
	redoStack.length = 0;
	transactionDepth = 0;
	transactionSnapshot = null;
	syncHistoryFlags();
}

function pruneSelection(current: Design) {
	const selected = get(selection);
	if (!selected) return;

	const exists =
		selected.type === 'wall'
			? current.walls.some((wall) => wall.id === selected.id)
			: selected.type === 'room'
				? current.rooms.some((room) => room.id === selected.id)
				: selected.type === 'door'
					? current.doors.some((door) => door.id === selected.id)
					: selected.type === 'window'
						? current.windows.some((window) => window.id === selected.id)
						: current.furniture.some((item) => item.id === selected.id);

	if (!exists) selection.set(null);
}

export function mutate(
	updater: (current: Design) => Design,
	options: { history?: boolean } = {}
): void {
	const previous = get(design);
	const draft = updater(previous);
	if (!draft || draft === previous) return;

	const next = { ...draft, updatedAt: new Date() };
	if (transactionDepth === 0 && options.history !== false) {
		pushUndo(previous);
	}
	design.set(next);
	pruneSelection(next);
}

export function beginTransaction(): void {
	if (transactionDepth === 0) transactionSnapshot = get(design);
	transactionDepth += 1;
}

export function endTransaction(): void {
	if (transactionDepth === 0) return;
	transactionDepth -= 1;
	if (transactionDepth > 0) return;

	const snapshot = transactionSnapshot;
	transactionSnapshot = null;
	if (snapshot && snapshot !== get(design)) pushUndo(snapshot);
}

export function undo(): void {
	const previous = undoStack.pop();
	if (!previous) return;
	redoStack.push(get(design));
	design.set(previous);
	syncHistoryFlags();
	pruneSelection(previous);
}

export function redo(): void {
	const next = redoStack.pop();
	if (!next) return;
	undoStack.push(get(design));
	design.set(next);
	syncHistoryFlags();
	pruneSelection(next);
}

export function newDesign(name = 'Untitled Design'): void {
	design.set(createDesign(name));
	selection.set(null);
	placementItem.set(null);
	statusMessage.set('');
	clearHistory();
}

export function replaceDesign(next: Design): void {
	design.set(next);
	selection.set(null);
	placementItem.set(null);
	statusMessage.set('');
	clearHistory();
}

export function setTool(tool: CanvasTool): void {
	activeTool.set(tool);
	if (tool !== 'furniture') placementItem.set(null);
}

export function requestFit(): void {
	fitRequest.update((value) => value + 1);
}

export function deleteSelection(): void {
	const selected = get(selection);
	if (!selected) return;

	mutate((current) => {
		switch (selected.type) {
			case 'wall':
				return {
					...current,
					walls: current.walls.filter((wall) => wall.id !== selected.id),
					doors: current.doors.filter((door) => door.wallId !== selected.id),
					windows: current.windows.filter((window) => window.wallId !== selected.id)
				};
			case 'room':
				return { ...current, rooms: current.rooms.filter((room) => room.id !== selected.id) };
			case 'door':
				return { ...current, doors: current.doors.filter((door) => door.id !== selected.id) };
			case 'window':
				return {
					...current,
					windows: current.windows.filter((window) => window.id !== selected.id)
				};
			case 'furniture':
				return {
					...current,
					furniture: current.furniture.filter((item) => item.id !== selected.id)
				};
			default:
				return current;
		}
	});

	selection.set(null);
}

export function rotateSelection(degrees: number): void {
	const selected = get(selection);
	if (!selected || selected.type !== 'furniture') return;
	const delta = (degrees * Math.PI) / 180;

	mutate((current) => ({
		...current,
		furniture: current.furniture.map((item) =>
			item.id === selected.id
				? { ...item, rotation: normalizeAngle(item.rotation + delta) }
				: item
		)
	}));
}

function translate(point: Point, dx: number, dy: number): Point {
	return { x: point.x + dx, y: point.y + dy };
}

function nudgeOpening<T extends Door | Window>(
	opening: T,
	walls: Wall[],
	dx: number,
	dy: number
): T {
	const wall = walls.find((candidate) => candidate.id === opening.wallId);
	if (!wall) return opening;

	const length = wallLength(wall);
	if (length === 0) return opening;

	const dirX = (wall.end.x - wall.start.x) / length;
	const dirY = (wall.end.y - wall.start.y) / length;
	const width = Math.min(opening.width, length);
	const rawT = projectPointOnSegment(opening.position, wall.start, wall.end).t + dx * dirX + dy * dirY;
	const t = length <= width ? length / 2 : clamp(rawT, width / 2, length - width / 2);

	return { ...opening, position: pointAlongWall(wall, t) };
}

export function nudgeSelection(dx: number, dy: number): void {
	const selected = get(selection);
	if (!selected) return;

	mutate((current) => {
		switch (selected.type) {
			case 'wall': {
				const wall = current.walls.find((candidate) => candidate.id === selected.id);
				if (!wall) return current;
				const movedWall: Wall = {
					...wall,
					start: translate(wall.start, dx, dy),
					end: translate(wall.end, dx, dy)
				};
				return {
					...current,
					walls: current.walls.map((candidate) =>
						candidate.id === selected.id ? movedWall : candidate
					),
					doors: current.doors.map((door) =>
						door.wallId === selected.id
							? { ...door, position: translate(door.position, dx, dy) }
							: door
					),
					windows: current.windows.map((window) =>
						window.wallId === selected.id
							? { ...window, position: translate(window.position, dx, dy) }
							: window
					)
				};
			}
			case 'room':
				return {
					...current,
					rooms: current.rooms.map((room) =>
						room.id === selected.id
							? { ...room, points: room.points.map((point) => translate(point, dx, dy)) }
							: room
					)
				};
			case 'door':
				return {
					...current,
					doors: current.doors.map((door) =>
						door.id === selected.id ? nudgeOpening(door, current.walls, dx, dy) : door
					)
				};
			case 'window':
				return {
					...current,
					windows: current.windows.map((window) =>
						window.id === selected.id
							? nudgeOpening(window, current.walls, dx, dy)
							: window
					)
				};
			case 'furniture':
				return {
					...current,
					furniture: current.furniture.map((item) =>
						item.id === selected.id
							? { ...item, position: translate(item.position, dx, dy) }
							: item
					)
				};
			default:
				return current;
		}
	});
}
