<script lang="ts">
	import { onMount } from 'svelte';
	import Canvas2D from '$lib/canvas/Canvas2D.svelte';
	import Canvas3D from '$lib/canvas/Canvas3D.svelte';
	import FurnitureCatalog from '$lib/catalog/FurnitureCatalog.svelte';
	import Toolbar from '$lib/components/Toolbar.svelte';
	import Inspector from '$lib/components/Inspector.svelte';
	import StatusBar from '$lib/components/StatusBar.svelte';
	import DesignExporter from '$lib/export/DesignExporter.svelte';
	import { loadPersistedDesign, startAutosave } from '$lib/persistence';
	import { replaceDesign, sidebarOpen, viewMode } from '$lib/store';

	onMount(() => {
		const saved = loadPersistedDesign();
		if (saved) replaceDesign(saved);
		if (window.innerWidth < 768) sidebarOpen.set(false);

		const desktop = window.matchMedia('(min-width: 768px)');
		const onViewportChange = (event: MediaQueryListEvent) => {
			if (!event.matches) sidebarOpen.set(false);
		};
		desktop.addEventListener('change', onViewportChange);

		const stopAutosave = startAutosave();
		return () => {
			stopAutosave();
			desktop.removeEventListener('change', onViewportChange);
		};
	});
</script>

<svelte:head>
	<title>ubuni.app | Floor Plan Editor</title>
	<link rel="icon" type="image/svg+xml" href="favicon.svg" />
</svelte:head>

<div class="flex h-dvh flex-col overflow-hidden bg-slate-100">
	<Toolbar />

	<div class="relative flex min-h-0 flex-1">
		{#if $sidebarOpen}
			<button
				type="button"
				class="absolute inset-0 z-20 bg-slate-900/30 md:hidden"
				on:click={() => sidebarOpen.set(false)}
				aria-label="Close sidebar"
			></button>
		{/if}

		<aside
			class="{$sidebarOpen
				? 'flex'
				: 'hidden'} absolute inset-y-0 left-0 z-30 w-80 max-w-[85vw] shrink-0 flex-col overflow-y-auto border-r border-slate-200 bg-white md:static md:flex"
		>
			<div class="border-b border-slate-200 p-4">
				<h2 class="mb-2 text-xs font-semibold uppercase tracking-wider text-slate-400">
					View
				</h2>
				<div class="flex rounded-md bg-slate-100 p-0.5" role="group" aria-label="View mode">
					<button
						type="button"
						class="flex-1 rounded px-2 py-1.5 text-xs font-medium {$viewMode === '2d'
							? 'bg-white text-slate-800 shadow-sm'
							: 'text-slate-500'}"
						on:click={() => viewMode.set('2d')}
						aria-pressed={$viewMode === '2d'}
					>
						2D plan
					</button>
					<button
						type="button"
						class="flex-1 rounded px-2 py-1.5 text-xs font-medium {$viewMode === '3d'
							? 'bg-white text-slate-800 shadow-sm'
							: 'text-slate-500'}"
						on:click={() => viewMode.set('3d')}
						aria-pressed={$viewMode === '3d'}
					>
						3D view
					</button>
				</div>
				<p class="mt-2 text-[11px] leading-4 text-slate-500">
					2D is the editing canvas. Use 3D to orbit, inspect, and select.
				</p>
			</div>

			<FurnitureCatalog />
			<Inspector />
		</aside>

		<main class="relative min-w-0 flex-1 overflow-hidden">
			{#if $viewMode === '2d'}
				<Canvas2D />
			{:else}
				<Canvas3D />
			{/if}
			<DesignExporter />
		</main>
	</div>

	<StatusBar />
</div>
