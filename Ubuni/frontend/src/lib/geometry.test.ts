import { describe, expect, it } from 'vitest';
import type { Design, Wall } from './types';
import {
	clampOpeningPosition,
	designBounds,
	mergedGapIntervals,
	openingsForWall,
	pointInPolygon,
	polygonArea,
	polygonCentroid,
	projectPointOnSegment,
	repositionOpenings,
	snapPoint,
	snapValue,
	wallSegments
} from './geometry';

function makeDesign(overrides: Partial<Design> = {}): Design {
	return {
		id: 'design',
		name: 'Test',
		walls: [],
		rooms: [],
		doors: [],
		windows: [],
		furniture: [],
		createdAt: new Date(0),
		updatedAt: new Date(0),
		...overrides
	};
}

const horizontalWall: Wall = {
	id: 'wall-1',
	start: { x: 0, y: 0 },
	end: { x: 4, y: 0 },
	thickness: 0.15
};

describe('snapping', () => {
	it('rounds to the nearest grid step, including negatives', () => {
		expect(snapValue(0.26)).toBeCloseTo(0.3);
		expect(snapValue(-0.26)).toBeCloseTo(-0.3);
		expect(snapValue(1.02)).toBeCloseTo(1);
	});

	it('returns the raw point when disabled', () => {
		expect(snapPoint({ x: 1.04, y: 2.97 }, 0.1, false)).toEqual({ x: 1.04, y: 2.97 });
	});

	it('snaps both axes when enabled', () => {
		expect(snapPoint({ x: 1.04, y: 2.97 })).toEqual({ x: 1, y: 3 });
	});
});

describe('projectPointOnSegment', () => {
	it('projects inside the segment', () => {
		const result = projectPointOnSegment({ x: 2, y: 2 }, { x: 0, y: 0 }, { x: 4, y: 0 });
		expect(result.t).toBeCloseTo(2);
		expect(result.point).toEqual({ x: 2, y: 0 });
		expect(result.distance).toBeCloseTo(2);
	});

	it('clamps beyond the end endpoint', () => {
		const result = projectPointOnSegment({ x: 8, y: 2 }, { x: 0, y: 0 }, { x: 4, y: 0 });
		expect(result.t).toBeCloseTo(4);
		expect(result.point).toEqual({ x: 4, y: 0 });
		expect(result.distance).toBeCloseTo(Math.hypot(4, 2));
	});

	it('handles zero-length segments', () => {
		const result = projectPointOnSegment({ x: 1, y: 1 }, { x: 0, y: 0 }, { x: 0, y: 0 });
		expect(result.t).toBe(0);
		expect(result.point).toEqual({ x: 0, y: 0 });
	});
});

describe('wall openings', () => {
	it('splits a wall around a centered door', () => {
		const design = makeDesign({
			walls: [horizontalWall],
			doors: [{ id: 'door-1', position: { x: 2, y: 0 }, width: 1, wallId: 'wall-1' }]
		});

		const openings = openingsForWall(design, horizontalWall);
		expect(openings).toHaveLength(1);
		expect(openings[0].t).toBeCloseTo(2);

		const segments = wallSegments(horizontalWall, openings);
		expect(segments).toHaveLength(2);
		expect(segments[0].start.x).toBeCloseTo(0);
		expect(segments[0].end.x).toBeCloseTo(1.5);
		expect(segments[1].start.x).toBeCloseTo(2.5);
		expect(segments[1].end.x).toBeCloseTo(4);
	});

	it('merges overlapping openings before splitting', () => {
		const design = makeDesign({
			walls: [horizontalWall],
			doors: [
				{ id: 'door-1', position: { x: 2, y: 0 }, width: 1.2, wallId: 'wall-1' },
				{ id: 'door-2', position: { x: 2.6, y: 0 }, width: 1.2, wallId: 'wall-1' }
			]
		});

		const openings = openingsForWall(design, horizontalWall);
		const merged = mergedGapIntervals(openings);
		expect(merged).toHaveLength(1);
		expect(merged[0].start).toBeCloseTo(1.4);
		expect(merged[0].end).toBeCloseTo(3.2);

		const segments = wallSegments(horizontalWall, openings);
		expect(segments).toHaveLength(2);
		expect(segments[0].end.x).toBeCloseTo(1.4);
		expect(segments[1].start.x).toBeCloseTo(3.2);
	});

	it('clamps an opening away from the wall ends', () => {
		const position = clampOpeningPosition({ x: 0.1, y: 0 }, horizontalWall, 1);
		expect(position.x).toBeCloseTo(0.5);
		expect(position.y).toBeCloseTo(0);
	});

	it('keeps the opening offset when the host wall is resized', () => {
		const door = { id: 'door-1', position: { x: 2, y: 0 }, width: 0.9, wallId: 'wall-1' };
		const longer: Wall = { ...horizontalWall, end: { x: 8, y: 0 } };
		const [moved] = repositionOpenings(horizontalWall, longer, [door]);
		expect(moved.position.x).toBeCloseTo(2);

		const shifted: Wall = { ...horizontalWall, start: { x: 1, y: 0 }, end: { x: 5, y: 0 } };
		const [shiftedDoor] = repositionOpenings(horizontalWall, shifted, [door]);
		expect(shiftedDoor.position.x).toBeCloseTo(3);
	});
});

describe('polygons', () => {
	const square = [
		{ x: 0, y: 0 },
		{ x: 2, y: 0 },
		{ x: 2, y: 2 },
		{ x: 0, y: 2 }
	];

	it('computes area and centroid', () => {
		expect(polygonArea(square)).toBeCloseTo(4);
		expect(polygonCentroid(square)).toEqual({ x: 1, y: 1 });
	});

	it('detects points inside and outside', () => {
		expect(pointInPolygon({ x: 1, y: 1 }, square)).toBe(true);
		expect(pointInPolygon({ x: 3, y: 1 }, square)).toBe(false);
	});
});

describe('designBounds', () => {
	it('includes a rotated furniture footprint', () => {
		const design = makeDesign({
			furniture: [
				{
					id: 'chair',
					name: 'Chair',
					category: 'seating',
					position: { x: 0, y: 0 },
					size: { x: 1, y: 2 },
					rotation: Math.PI / 2
				}
			]
		});

		const bounds = designBounds(design);
		expect(bounds.width).toBeCloseTo(2);
		expect(bounds.height).toBeCloseTo(1);
		expect(bounds.minX).toBeCloseTo(-1);
		expect(bounds.maxY).toBeCloseTo(0.5);
	});
});
