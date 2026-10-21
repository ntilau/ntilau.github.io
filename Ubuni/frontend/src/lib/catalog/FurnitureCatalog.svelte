<script lang="ts">
	import { furnitureLibrary } from './catalog';
	import { placementItem, setTool, viewMode } from '$lib/store';
	import type { FurnitureTemplate } from '$lib/types';

	const categoryIcons: Record<string, string> = {
		seating: '🪑',
		tables: '🍽️',
		beds: '🛏️',
		storage: '🗄️',
		lighting: '💡',
		decor: '🌿'
	};

	function choose(item: FurnitureTemplate) {
		setTool('furniture');
		placementItem.set(item);
		viewMode.set('2d');
	}
</script>

<section class="p-4">
	<h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-400">
		Furniture catalog
	</h2>

	<div class="grid grid-cols-2 gap-2" role="listbox" aria-label="Furniture catalog">
		{#each furnitureLibrary as item (item.id)}
			<button
				type="button"
				class="flex items-center gap-2 rounded-md border p-2 text-left transition-colors {$placementItem?.id ===
				item.id
					? 'border-blue-500 bg-blue-50'
					: 'border-slate-200 hover:border-slate-300 hover:bg-slate-50'}"
				on:click={() => choose(item)}
				aria-selected={$placementItem?.id === item.id}
				role="option"
			>
				<span
					class="flex h-9 w-9 shrink-0 items-center justify-center rounded bg-slate-100 text-base"
				>
					{categoryIcons[item.category] ?? '📦'}
				</span>
				<span class="min-w-0">
					<span class="block truncate text-xs font-medium text-slate-700">{item.name}</span>
					<span class="block text-[10px] text-slate-500">
						{Math.round(item.size.x * 100)} × {Math.round(item.size.y * 100)} cm
					</span>
				</span>
			</button>
		{/each}
	</div>

	{#if $placementItem}
		<p class="mt-3 text-xs leading-5 text-slate-500">
			Placing <span class="font-medium text-slate-700">{$placementItem.name}</span>. Click the plan
			to place; press Esc to stop.
		</p>
	{/if}
</section>
