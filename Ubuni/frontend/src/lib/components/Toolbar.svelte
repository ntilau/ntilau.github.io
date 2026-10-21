<script lang="ts">
	import { activeTool, viewMode } from '$lib/store';
	type CanvasTool = import('$lib/types').CanvasTool;

	function setTool(tool: CanvasTool) {
		activeTool.set(tool);
	}

	function toggleView() {
		viewMode.update((m) => (m === '2d' ? '3d' : '2d'));
	}
</script>

<div class="flex items-center gap-2 bg-white p-3 border-b border-gray-200 shadow-sm">
	<button
		on:click={() => setTool('select')}
		class="px-3 py-1 rounded text-sm font-medium transition-colors hover:bg-gray-100 active:bg-gray-200 {$activeTool === 'select' ? 'bg-blue-100 text-blue-700' : ''}"
	>
		Select
	</button>
	<button
		on:click={() => setTool('wall')}
		class="px-3 py-1 rounded text-sm font-medium transition-colors hover:bg-gray-100 active:bg-gray-200 {$activeTool === 'wall' ? 'bg-blue-100 text-blue-700' : ''}"
	>
		Wall
	</button>
	<div class="flex-1" />

	<button
		on:click={toggleView}
		class="px-3 py-1 rounded text-sm font-medium transition-colors hover:bg-gray-100 bg-indigo-100 text-indigo-700"
	>
		Toggle {$viewMode === '2d' ? '3D' : '2D'} View
	</button>
</div>
