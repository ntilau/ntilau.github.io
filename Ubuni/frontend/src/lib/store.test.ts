import { beforeEach, describe, expect, it } from 'vitest';
import { get } from 'svelte/store';
import type { Design } from './types';
import {
	beginTransaction,
	canRedo,
	canUndo,
	deleteSelection,
	design,
	endTransaction,
	mutate,
	redo,
	replaceDesign,
	selection,
	undo
} from './store';

function baseDesign(): Design {
	return {
		id: 'design',
		name: 'Test',
		walls: [],
		rooms: [],
		doors: [],
		windows: [],
		furniture: [],
		createdAt: new Date(0),
		updatedAt: new Date(0)
	};
}

function rename(name: string) {
	mutate((current) => ({ ...current, name }));
}

describe('history', () => {
	beforeEach(() => {
		replaceDesign(baseDesign());
	});

	it('undoes and redoes a mutation', () => {
		rename('One');
		expect(get(design).name).toBe('One');
		expect(get(canUndo)).toBe(true);

		undo();
		expect(get(design).name).toBe('Test');
		expect(get(canRedo)).toBe(true);

		redo();
		expect(get(design).name).toBe('One');
	});

	it('clears redo when a new edit is committed', () => {
		rename('One');
		undo();
		rename('Two');
		expect(get(canRedo)).toBe(false);
	});

	it('coalesces a transaction into one undo step', () => {
		beginTransaction();
		mutate((current) => ({ ...current, name: 'Step' }));
		mutate((current) => ({ ...current, name: 'Final' }));
		endTransaction();

		expect(get(design).name).toBe('Final');
		undo();
		expect(get(design).name).toBe('Test');
	});

	it('caps history at 100 entries', () => {
		for (let index = 0; index < 105; index += 1) {
			rename(`Edit ${index}`);
		}
		for (let index = 0; index < 105; index += 1) {
			undo();
		}
		expect(get(design).name).toBe('Edit 4');
	});

	it('prunes a selection whose entity was removed', () => {
		mutate((current) => ({
			...current,
			walls: [{ id: 'wall-1', start: { x: 0, y: 0 }, end: { x: 1, y: 0 }, thickness: 0.15 }]
		}));
		selection.set({ type: 'wall', id: 'wall-1' });

		mutate((current) => ({ ...current, walls: [] }));
		expect(get(selection)).toBeNull();
	});

	it('cascades wall deletion to doors and windows', () => {
		mutate((current) => ({
			...current,
			walls: [{ id: 'wall-1', start: { x: 0, y: 0 }, end: { x: 4, y: 0 }, thickness: 0.15 }],
			doors: [{ id: 'door-1', position: { x: 2, y: 0 }, width: 0.9, wallId: 'wall-1' }],
			windows: [{ id: 'window-1', position: { x: 3, y: 0 }, width: 1.2, wallId: 'wall-1' }]
		}));
		selection.set({ type: 'wall', id: 'wall-1' });

		deleteSelection();

		expect(get(design).walls).toHaveLength(0);
		expect(get(design).doors).toHaveLength(0);
		expect(get(design).windows).toHaveLength(0);
	});
});
