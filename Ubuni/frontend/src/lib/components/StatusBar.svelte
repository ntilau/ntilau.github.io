<script lang="ts">
	import {
		activeTool,
		counts,
		cursorWorld,
		snapEnabled,
		statusMessage,
		viewMode,
		zoom2D
	} from '$lib/store';

	const hints: Record<string, string> = {
		select:
			'Click to select · drag furniture or selected wall/room handles · R rotate · Delete removes',
		wall: 'Click to start · click to chain · Enter or double-click to finish · Esc cancels',
		room: 'Click to add points · click the first point or press Enter to close · Esc cancels',
		door: 'Click on a wall to place a door · Esc cancels',
		window: 'Click on a wall to place a window · Esc cancels',
		furniture: 'Choose a catalog item, then click the plan to place · Esc stops placing',
		pan: 'Drag to pan · use the wheel to zoom · 0 fits the plan'
	};

	$: hint = $statusMessage || hints[$activeTool] || '';

	function countsText(value: {
		walls: number;
		rooms: number;
		doors: number;
		windows: number;
		furniture: number;
	}): string {
		return `${value.walls} walls · ${value.rooms} rooms · ${value.doors} doors · ${value.windows} windows · ${value.furniture} furniture`;
	}
</script>

<footer
	class="z-30 flex flex-wrap items-center gap-x-4 gap-y-1 border-t border-slate-200 bg-white px-3 py-1.5 text-[11px] text-slate-500"
>
	<span class="min-w-0 flex-1 truncate text-slate-600" title={hint}>{hint}</span>

	{#if $cursorWorld}
		<span class="hidden whitespace-nowrap font-mono sm:inline">
			X {$cursorWorld.x.toFixed(2)} m · Y {$cursorWorld.y.toFixed(2)} m
		</span>
	{/if}

	<span class="hidden whitespace-nowrap md:inline">
		{countsText($counts)}
	</span>

	<span class="whitespace-nowrap">
		Snap {$snapEnabled ? 'on' : 'off'}
	</span>

	<span class="hidden whitespace-nowrap sm:inline">
		{#if $viewMode === '2d'}
			{$zoom2D.toFixed(0)} px/m
		{:else}
			3D orbit
		{/if}
	</span>
</footer>
