import { writable } from 'svelte/store';
import type { Design, CanvasTool, ViewMode, FurnitureItem } from './types';

export const design = writable<Design>({
  id: crypto.randomUUID(),
  name: 'Untitled Design',
  walls: [],
  rooms: [],
  doors: [],
  windows: [],
  furniture: [],
  createdAt: new Date(),
  updatedAt: new Date()
});

export const activeTool = writable<CanvasTool>('select');
export const viewMode = writable<ViewMode>('2d');
export const isDrawing = writable(false);
export const currentPoint = writable<{ x: number; y: number } | null>(null);
export const selectedFurniture = writable<FurnitureItem | null>(null);
