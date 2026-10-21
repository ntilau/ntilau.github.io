<script lang="ts">
	import {
		activeTool,
		canRedo,
		canUndo,
		design,
		mutate,
		newDesign,
		placementItem,
		redo,
		requestFit,
		setTool,
		sidebarOpen,
		snapEnabled,
		statusMessage,
		undo,
		viewMode
	} from '$lib/store';
	import type { CanvasTool } from '$lib/types';

	type ToolDefinition = { id: CanvasTool; label: string; shortcut: string };

	const tools: ToolDefinition[] = [
		{ id: 'select', label: 'Select', shortcut: 'V' },
		{ id: 'wall', label: 'Wall', shortcut: 'W' },
		{ id: 'room', label: 'Room', shortcut: 'M' },
		{ id: 'door', label: 'Door', shortcut: 'D' },
		{ id: 'window', label: 'Window', shortcut: 'N' },
		{ id: 'furniture', label: 'Furniture', shortcut: 'F' },
		{ id: 'pan', label: 'Pan', shortcut: 'H' }
	];

	let nameDraft = '';

	$: nameDraft = $design.name;

	function chooseTool(tool: CanvasTool) {
		setTool(tool);
		if (tool !== 'select') viewMode.set('2d');
		if (tool === 'furniture' && !$placementItem) {
			statusMessage.set('Choose a furniture item from the sidebar');
		}
	}

	function commitName() {
		const next = nameDraft.trim();
		if (!next) {
			nameDraft = $design.name;
			return;
		}
		if (next !== $design.name) {
			mutate((current) => ({ ...current, name: next }));
		}
	}

	function startNewDesign() {
		if (
			typeof window !== 'undefined' &&
			!window.confirm('Start a new design? The current design will be replaced.')
		) {
			return;
		}
		newDesign();
		viewMode.set('2d');
	}
</script>

<header
	class="z-40 flex flex-wrap items-center gap-2 border-b border-slate-200 bg-white px-2 py-2 shadow-sm"
>
	<button
		type="button"
		class="rounded-md p-2 text-slate-600 hover:bg-slate-100 md:hidden"
		on:click={() => sidebarOpen.update((open) => !open)}
		aria-label="Toggle sidebar"
	>
		☰
	</button>

	<div class="flex items-center gap-2">
		<div
			class="flex h-7 w-7 items-center justify-center rounded-md bg-blue-600 text-sm font-bold text-white"
		>
			U
		</div>
		<input
			class="w-28 rounded-md border border-transparent bg-transparent px-1.5 py-1 text-sm font-semibold text-slate-800 hover:border-slate-200 focus:border-blue-400 focus:outline-none sm:w-44"
			bind:value={nameDraft}
			on:change={commitName}
			on:blur={commitName}
			aria-label="Design name"
		/>
	</div>

	<span class="hidden h-6 w-px bg-slate-200 md:block" />

	<div class="flex flex-wrap items-center gap-0.5" role="group" aria-label="Tools">
		{#each tools as tool (tool.id)}
			<button
				type="button"
				class="rounded-md px-2 py-1.5 text-xs font-medium transition-colors {$activeTool ===
				tool.id
					? 'bg-blue-600 text-white shadow-sm'
					: 'text-slate-600 hover:bg-slate-100'}"
				on:click={() => chooseTool(tool.id)}
				title={`${tool.label} (${tool.shortcut})`}
				aria-pressed={$activeTool === tool.id}
			>
				{tool.label}
			</button>
		{/each}
	</div>

	<span class="hidden h-6 w-px bg-slate-200 sm:block" />

	<div class="flex items-center gap-1">
		<button
			type="button"
			class="rounded-md px-2 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100 disabled:cursor-not-allowed disabled:opacity-40"
			on:click={undo}
			disabled={!$canUndo}
			title="Undo (Cmd/Ctrl+Z)"
		>
			Undo
		</button>
		<button
			type="button"
			class="rounded-md px-2 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100 disabled:cursor-not-allowed disabled:opacity-40"
			on:click={redo}
			disabled={!$canRedo}
			title="Redo (Cmd/Ctrl+Shift+Z)"
		>
			Redo
		</button>
	</div>

	<div class="min-w-0 flex-1" />

	<button
		type="button"
		class="rounded-md px-2 py-1.5 text-xs font-medium {$snapEnabled
			? 'bg-emerald-50 text-emerald-700'
			: 'text-slate-500 hover:bg-slate-100'}"
		on:click={() => snapEnabled.update((enabled) => !enabled)}
		title="Toggle grid and endpoint snapping (G)"
	>
		Snap {$snapEnabled ? 'On' : 'Off'}
	</button>

	<button
		type="button"
		class="rounded-md px-2 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100"
		on:click={requestFit}
		title="Fit the plan to the viewport (0)"
	>
		Fit
	</button>

	<div class="flex rounded-md bg-slate-100 p-0.5" role="group" aria-label="View mode">
		<button
			type="button"
			class="rounded px-2 py-1 text-xs font-medium {$viewMode === '2d'
				? 'bg-white text-slate-800 shadow-sm'
				: 'text-slate-500'}"
			on:click={() => viewMode.set('2d')}
			aria-pressed={$viewMode === '2d'}
		>
			2D
		</button>
		<button
			type="button"
			class="rounded px-2 py-1 text-xs font-medium {$viewMode === '3d'
				? 'bg-white text-slate-800 shadow-sm'
				: 'text-slate-500'}"
			on:click={() => viewMode.set('3d')}
			aria-pressed={$viewMode === '3d'}
		>
			3D
		</button>
	</div>

	<button
		type="button"
		class="rounded-md border border-slate-200 px-2 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100"
		on:click={startNewDesign}
	>
		New
	</button>
</header>
