import { describe, expect, it } from 'vitest';
import type { Design } from './types';
import { buildPlan, paddedBounds } from './plan';
import { designToSvg, escapeXml } from './export/svg';
import { fitPlanToPage } from './export/pdf';
import { designFromImport, exportEnvelope } from './persistence';

function fixture(): Design {
	return {
		id: 'design',
		name: 'Sample Home',
		walls: [
			{ id: 'wall-1', start: { x: 0, y: 0 }, end: { x: 4, y: 0 }, thickness: 0.15 },
			{ id: 'wall-2', start: { x: 0, y: 0 }, end: { x: 0, y: 3 }, thickness: 0.15 }
		],
		rooms: [
			{
				id: 'room-1',
				points: [
					{ x: 0, y: 0 },
					{ x: 4, y: 0 },
					{ x: 4, y: 3 },
					{ x: 0, y: 3 }
				],
				label: 'Living Room',
				color: '#93c5fd'
			}
		],
		doors: [{ id: 'door-1', position: { x: 2, y: 0 }, width: 1, wallId: 'wall-1' }],
		windows: [],
		furniture: [
			{
				id: 'sofa-1',
				name: 'Sofa',
				category: 'seating',
				position: { x: 2, y: 2 },
				size: { x: 0.9, y: 0.4 },
				rotation: 0
			}
		],
		createdAt: new Date('2026-01-01T00:00:00.000Z'),
		updatedAt: new Date('2026-01-02T00:00:00.000Z')
	};
}

describe('plan', () => {
	it('leaves a gap for doors in wall segments', () => {
		const plan = buildPlan(fixture());
		const doorWallSegments = plan.walls.filter((segment) => segment.wallId === 'wall-1');
		expect(doorWallSegments).toHaveLength(2);
		expect(plan.doors).toHaveLength(1);
		expect(plan.doors[0].width).toBe(1);
		expect(plan.doors[0].arc.length).toBeGreaterThan(2);
	});
});

describe('SVG export', () => {
	it('produces a valid SVG with every entity type', () => {
		const { svg, width, height } = designToSvg(fixture());
		expect(svg.startsWith('<svg')).toBe(true);
		expect(svg).toContain('<polygon');
		expect(svg).toContain('<polyline');
		expect(svg).toContain('<text');
		expect(svg).toContain('Living Room');
		expect(svg).not.toContain('NaN');
		expect(width).toBeGreaterThan(0);
		expect(height).toBeGreaterThan(0);
	});

	it('produces a valid SVG for an empty design', () => {
		const empty: Design = {
			...fixture(),
			walls: [],
			rooms: [],
			doors: [],
			windows: [],
			furniture: []
		};
		const { svg, width, height } = designToSvg(empty);
		expect(svg).toContain('viewBox');
		expect(width).toBeGreaterThan(0);
		expect(height).toBeGreaterThan(0);
		expect(svg).not.toContain('NaN');
	});

	it('escapes XML text', () => {
		expect(escapeXml('A & B < C')).toBe('A &amp; B &lt; C');
	});
});

describe('JSON import/export', () => {
	it('round-trips through JSON with dates revived', () => {
		const source = fixture();
		const encoded = JSON.stringify(exportEnvelope(source));
		const normalized = designFromImport(JSON.parse(encoded));

		expect(normalized).not.toBeNull();
		expect(normalized?.name).toBe('Sample Home');
		expect(normalized?.walls).toHaveLength(2);
		expect(normalized?.doors[0].wallId).toBe('wall-1');
		expect(normalized?.createdAt).toBeInstanceOf(Date);
		expect(normalized?.createdAt.toISOString()).toBe('2026-01-01T00:00:00.000Z');
	});

	it('rejects malformed designs', () => {
		expect(designFromImport({ design: { walls: 'nope' } })).toBeNull();
		expect(designFromImport({ hello: 'world' })).toBeNull();
	});
});

describe('PDF layout', () => {
	it('fits the plan inside the page margins', () => {
		const bounds = paddedBounds(buildPlan(fixture()).bounds, 0.4);
		const fit = fitPlanToPage(bounds, 297, 210);

		expect(fit.scale).toBeGreaterThan(0);
		expect(fit.offsetX).toBeGreaterThanOrEqual(12);
		expect(fit.offsetY).toBeGreaterThan(12);
		expect(fit.offsetX + bounds.width * fit.scale).toBeLessThanOrEqual(285);
		expect(fit.offsetY + bounds.height * fit.scale).toBeLessThanOrEqual(210 - 12);
	});
});
