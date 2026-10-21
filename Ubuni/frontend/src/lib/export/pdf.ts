import type { Bounds } from '../geometry';
import type { Design, Point } from '../types';
import { buildPlan, paddedBounds } from '../plan';
import { slugify } from './download';

type PdfDocument = import('jspdf').jsPDF;

export type PageFit = {
	scale: number;
	offsetX: number;
	offsetY: number;
	contentWidth: number;
	contentHeight: number;
};

const HEADER_MM = 18;

export function fitPlanToPage(
	bounds: Bounds,
	pageWidth: number,
	pageHeight: number,
	margin = 12
): PageFit {
	const contentWidth = Math.max(1, pageWidth - margin * 2);
	const contentHeight = Math.max(1, pageHeight - margin * 2 - HEADER_MM);
	const width = Math.max(bounds.width, 1e-6);
	const height = Math.max(bounds.height, 1e-6);
	const scale = Math.min(contentWidth / width, contentHeight / height);

	return {
		scale,
		offsetX: margin + (contentWidth - width * scale) / 2,
		offsetY: margin + HEADER_MM + (contentHeight - height * scale) / 2,
		contentWidth,
		contentHeight
	};
}

function hexToRgb(hex: string): { r: number; g: number; b: number } {
	const normalized = hex.replace('#', '');
	const value =
		normalized.length === 3
			? normalized
					.split('')
					.map((character) => character + character)
					.join('')
			: normalized;
	if (!/^[0-9a-fA-F]{6}$/.test(value)) return { r: 100, g: 116, b: 139 };
	return {
		r: parseInt(value.slice(0, 2), 16),
		g: parseInt(value.slice(2, 4), 16),
		b: parseInt(value.slice(4, 6), 16)
	};
}

function drawPolygon(doc: PdfDocument, points: Point[], style: 'F' | 'S' | 'FD'): void {
	if (points.length < 3) return;
	const first = points[0];
	const deltas = points.slice(1).map((point) => [point.x - first.x, point.y - first.y]);
	doc.lines(deltas, first.x, first.y, [1, 1], style, true);
}

function drawPolyline(doc: PdfDocument, points: Point[]): void {
	if (points.length < 2) return;
	const first = points[0];
	const deltas = points.slice(1).map((point) => [point.x - first.x, point.y - first.y]);
	doc.lines(deltas, first.x, first.y, [1, 1], 'S', false);
}

export async function downloadDesignPdf(design: Design): Promise<void> {
	const { jsPDF } = await import('jspdf');
	const plan = buildPlan(design);
	const bounds = paddedBounds(plan.bounds, 0.4);
	const landscape = bounds.width >= bounds.height;

	const doc = new jsPDF({
		orientation: landscape ? 'landscape' : 'portrait',
		unit: 'mm',
		format: 'a4'
	});

	const pageWidth = doc.internal.pageSize.getWidth();
	const pageHeight = doc.internal.pageSize.getHeight();
	const fit = fitPlanToPage(bounds, pageWidth, pageHeight);
	const project = (point: Point): Point => ({
		x: fit.offsetX + (point.x - bounds.minX) * fit.scale,
		y: fit.offsetY + (bounds.maxY - point.y) * fit.scale
	});

	doc.setFont('helvetica', 'bold');
	doc.setFontSize(14);
	doc.setTextColor(15, 23, 42);
	doc.text(design.name, 12, 12);

	doc.setFont('helvetica', 'normal');
	doc.setFontSize(9);
	doc.setTextColor(100, 116, 139);
	doc.text(
		`Walls: ${design.walls.length}   Rooms: ${design.rooms.length}   Doors: ${design.doors.length}   Windows: ${design.windows.length}   Furniture: ${design.furniture.length}`,
		12,
		17
	);

	for (const entry of plan.rooms) {
		const points = entry.room.points.map(project);
		const color = hexToRgb(entry.room.color);
		doc.setFillColor(color.r, color.g, color.b);
		doc.setDrawColor(color.r, color.g, color.b);
		doc.setLineWidth(0.3);
		drawPolygon(doc, points, 'FD');
	}

	for (const wall of plan.walls) {
		const start = project(wall.start);
		const end = project(wall.end);
		doc.setDrawColor(15, 23, 42);
		doc.setLineWidth(Math.max(0.25, wall.thickness * fit.scale));
		doc.line(start.x, start.y, end.x, end.y);
	}

	doc.setDrawColor(180, 83, 9);
	doc.setLineWidth(0.35);
	for (const door of plan.doors) {
		const hinge = project(door.hinge);
		const leaf = project(door.leafEnd);
		doc.line(hinge.x, hinge.y, leaf.x, leaf.y);
		doc.setLineWidth(0.2);
		drawPolyline(doc, door.arc.map(project));
		doc.setLineWidth(0.35);
	}

	doc.setDrawColor(2, 132, 199);
	doc.setLineWidth(0.35);
	for (const window of plan.windows) {
		const offset = Math.max(0.03, window.thickness / 4);
		for (const side of [-1, 1]) {
			const shift = {
				x: window.normal.x * offset * side,
				y: window.normal.y * offset * side
			};
			const start = project({ x: window.start.x + shift.x, y: window.start.y + shift.y });
			const end = project({ x: window.end.x + shift.x, y: window.end.y + shift.y });
			doc.line(start.x, start.y, end.x, end.y);
		}
	}

	for (const entry of plan.furniture) {
		const points = entry.corners.map(project);
		doc.setFillColor(203, 213, 225);
		doc.setDrawColor(71, 85, 105);
		doc.setLineWidth(0.25);
		drawPolygon(doc, points, 'FD');
	}

	doc.setTextColor(51, 65, 85);
	doc.setFont('helvetica', 'bold');
	doc.setFontSize(9);
	for (const entry of plan.rooms) {
		const centroid = project(entry.centroid);
		doc.text(entry.room.label, centroid.x, centroid.y, { align: 'center', baseline: 'middle' });
	}

	const scaleLength = Math.min(fit.contentWidth * 0.3, 1 * fit.scale);
	if (scaleLength > 4) {
		const x = 12;
		const y = pageHeight - 8;
		doc.setDrawColor(71, 85, 105);
		doc.setLineWidth(0.4);
		doc.line(x, y, x + scaleLength, y);
		doc.setFont('helvetica', 'normal');
		doc.setFontSize(7);
		doc.setTextColor(100, 116, 139);
		doc.text('1 m', x + scaleLength / 2, y - 2, { align: 'center' });
	}

	doc.save(`${slugify(design.name)}.pdf`);
}
