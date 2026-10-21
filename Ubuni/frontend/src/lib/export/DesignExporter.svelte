<script lang="ts">
	import { design } from '$lib/store';
	import { jsPDF } from 'jspdf';
	import type { Design } from '$lib/types';

	function exportAsJSON() {
		const d = $design;
		const dataStr = JSON.stringify(d, null, 2);
		const dataUri = 'data:application/json;charset=utf-8,' + encodeURIComponent(dataStr);
		const exportFileName = `${d.name.replace(/\s+/g, '_')}.json`;

		const linkElement = document.createElement('a');
		linkElement.setAttribute('href', dataUri);
		linkElement.setAttribute('download', exportFileName);
		linkElement.click();
	}

	function exportAsPDF() {
		const d = $design;
		const doc = new jsPDF();
		doc.text(`Floor Plan: ${d.name}`, 20, 20);
		doc.text(`Walls: ${d.walls.length}`, 20, 30);
		doc.text(`Rooms: ${d.rooms.length}`, 20, 40);
		doc.text(`Doors: ${d.doors.length}`, 20, 50);
		doc.text(`Windows: ${d.windows.length}`, 20, 60);
		doc.text(`Furniture: ${d.furniture.length}`, 20, 70);
		doc.save(`${d.name.replace(/\s+/g, '_')}.pdf`);
	}

	function exportAsSVG() {
		const d = $design;
		let svgContent = '<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600">';
		d.walls.forEach((wall) => {
			svgContent += `<line x1="${wall.start.x * 10}" y1="${wall.start.y * 10}" x2="${wall.end.x * 10}" y2="${wall.end.y * 10}" stroke="black" stroke-width="${wall.thickness * 10}" />`;
		});
		svgContent += '</svg>';

		const dataUri = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svgContent);
		const linkElement = document.createElement('a');
		linkElement.setAttribute('href', dataUri);
		linkElement.setAttribute('download', `${d.name.replace(/\s+/g, '_')}.svg`);
		linkElement.click();
	}
</script>

<div class="fixed bottom-6 right-6 flex gap-2 z-50">
	<button
		on:click={exportAsJSON}
		class="px-4 py-2 bg-gray-800 text-white rounded hover:bg-gray-900 transition-colors text-sm"
		title="Export JSON"
	>
		JSON
	</button>
	<button
		on:click={exportAsPDF}
		class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors text-sm"
		title="Export PDF"
	>
		PDF
	</button>
	<button
		on:click={exportAsSVG}
		class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition-colors text-sm"
		title="Export SVG"
	>
		SVG
	</button>
</div>
