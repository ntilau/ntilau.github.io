import type { Design, Point } from '../types';
import { buildPlan, paddedBounds } from '../plan';

const UNITS_PER_METER = 100;
const PADDING_METERS = 0.5;

export function escapeXml(value: string): string {
	return value
		.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/"/g, '&quot;')
		.replace(/'/g, '&apos;');
}

function number(value: number): string {
	return Number.isFinite(value) ? value.toFixed(2) : '0';
}

function pointList(points: Point[], project: (point: Point) => Point): string {
	return points
		.map((point) => {
			const projected = project(point);
			return `${number(projected.x)},${number(projected.y)}`;
		})
		.join(' ');
}

export function designToSvg(design: Design): { svg: string; width: number; height: number } {
	const plan = buildPlan(design);
	const bounds = paddedBounds(plan.bounds, PADDING_METERS);
	const width = Math.max(1, Math.ceil(bounds.width * UNITS_PER_METER));
	const height = Math.max(1, Math.ceil(bounds.height * UNITS_PER_METER));

	const project = (point: Point): Point => ({
		x: (point.x - bounds.minX) * UNITS_PER_METER,
		y: (bounds.maxY - point.y) * UNITS_PER_METER
	});

	const parts: string[] = [];
	parts.push(
		`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-label="${escapeXml(design.name)} floor plan">`
	);
	parts.push(`<title>${escapeXml(design.name)}</title>`);
	parts.push('<rect width="100%" height="100%" fill="#ffffff" />');

	for (const entry of plan.rooms) {
		const points = pointList(entry.room.points, project);
		parts.push(
			`<polygon points="${points}" fill="${escapeXml(entry.room.color)}" fill-opacity="0.35" stroke="${escapeXml(entry.room.color)}" stroke-width="2" />`
		);
	}

	for (const wall of plan.walls) {
		const start = project(wall.start);
		const end = project(wall.end);
		parts.push(
			`<line x1="${number(start.x)}" y1="${number(start.y)}" x2="${number(end.x)}" y2="${number(end.y)}" stroke="#0f172a" stroke-width="${number(wall.thickness * UNITS_PER_METER)}" stroke-linecap="butt" />`
		);
	}

	for (const door of plan.doors) {
		const hinge = project(door.hinge);
		const leaf = project(door.leafEnd);
		parts.push(
			`<line x1="${number(hinge.x)}" y1="${number(hinge.y)}" x2="${number(leaf.x)}" y2="${number(leaf.y)}" stroke="#b45309" stroke-width="3" />`
		);
		const arc = pointList(door.arc, project);
		parts.push(`<polyline points="${arc}" fill="none" stroke="#b45309" stroke-width="2" />`);
		parts.push(
			`<circle cx="${number(hinge.x)}" cy="${number(hinge.y)}" r="3" fill="#b45309" />`
		);
	}

	for (const window of plan.windows) {
		const offset = Math.max(0.03, window.thickness / 4);
		for (const side of [-1, 1]) {
			const shift = {
				x: window.normal.x * offset * side,
				y: window.normal.y * offset * side
			};
			const start = project({ x: window.start.x + shift.x, y: window.start.y + shift.y });
			const end = project({ x: window.end.x + shift.x, y: window.end.y + shift.y });
			parts.push(
				`<line x1="${number(start.x)}" y1="${number(start.y)}" x2="${number(end.x)}" y2="${number(end.y)}" stroke="#0284c7" stroke-width="3" />`
			);
		}
	}

	for (const entry of plan.furniture) {
		const points = pointList(entry.corners, project);
		parts.push(
			`<polygon points="${points}" fill="#cbd5e1" fill-opacity="0.9" stroke="#475569" stroke-width="2" />`
		);
		const center = project(entry.item.position);
		const smallest = Math.min(entry.item.size.x, entry.item.size.y) * UNITS_PER_METER;
		if (smallest >= 35) {
			parts.push(
				`<text x="${number(center.x)}" y="${number(center.y)}" font-family="system-ui, sans-serif" font-size="11" fill="#1e293b" text-anchor="middle" dominant-baseline="middle">${escapeXml(entry.item.name)}</text>`
			);
		}
	}

	for (const entry of plan.rooms) {
		const centroid = project(entry.centroid);
		parts.push(
			`<text x="${number(centroid.x)}" y="${number(centroid.y)}" font-family="system-ui, sans-serif" font-size="14" font-weight="600" fill="#334155" text-anchor="middle" dominant-baseline="middle">${escapeXml(entry.room.label)}</text>`
		);
	}

	parts.push('</svg>');
	return { svg: parts.join('\n'), width, height };
}
