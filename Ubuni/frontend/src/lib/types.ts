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

export type CanvasTool = 'select' | 'wall' | 'door' | 'window' | 'room' | 'furniture' | 'pan';

export type ViewMode = '2d' | '3d';
