<script lang="ts">
	import Canvas2D from '$lib/canvas/Canvas2D.svelte';
	import Canvas3D from '$lib/canvas/Canvas3D.svelte';
	import FurnitureCatalog from '$lib/catalog/FurnitureCatalog.svelte';
	import Toolbar from '$lib/components/Toolbar.svelte';
	import DesignExporter from '$lib/export/DesignExporter.svelte';
	import { viewMode, activeTool, selectedFurniture } from '$lib/store';

	function onItemSelect(e: CustomEvent<{ item: import('$lib/types').FurnitureItem }>) {
		selectedFurniture.set(e.detail.item);
		activeTool.set('furniture');
	}
</script>

<svelte:head>
	<title>ubuni.app | Floor Plan Editor</title>
	<link rel="icon" type="image/svg+xml" href="favicon.svg" />
</svelte:head>

<div class="flex flex-col h-screen overflow-hidden bg-gray-50">
	<Toolbar />

	<div class="flex flex-1 overflow-hidden">
		<aside class="w-72 bg-gray-50 border-r border-gray-200 flex flex-col">
			<div class="p-4 border-b border-gray-200">
				<h2 class="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-3">Canvas</h2>
				<div class="flex gap-2">
					<button
						class="flex-1 px-2 py-1 rounded text-sm transition-colors {$viewMode === '2d' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-600'}"
						on:click={() => ($viewMode = '2d')}
					>
						2D
					</button>
					<button
						class="flex-1 px-2 py-1 rounded text-sm transition-colors {$viewMode === '3d' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-600'}"
						on:click={() => ($viewMode = '3d')}
					>
						3D
					</button>
				</div>
			</div>
			<FurnitureCatalog on:itemselect={onItemSelect} />
		</aside>

		<div class="flex-1 relative overflow-hidden w-full h-full">
			{#if $viewMode === '2d'}
				<Canvas2D />
			{:else}
				<Canvas3D />
			{/if}
		</div>
	</div>

	<DesignExporter />
</div>
