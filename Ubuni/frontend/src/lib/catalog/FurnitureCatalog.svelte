<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import { furnitureLibrary } from './catalog';
	type FurnitureItem = import('$lib/types').FurnitureItem;

	const dispatch = createEventDispatcher<{ itemselect: { item: FurnitureItem } }>();

	export let selectedItem: FurnitureItem | null = null;

	const categoryIcons: Record<string, string> = {
		seating: '🪑',
		tables: '🪑',
		beds: '🛏️',
		storage: '🗄️',
		lighting: '💡',
		decor: '🌿'
	};

	function getItemIcon(category: string) {
		return categoryIcons[category] || '📦';
	}

	function selectItem(item: FurnitureItem) {
		selectedItem = item;
		dispatch('itemselect', { item });
	}
</script>

<div class="flex flex-col h-full bg-gray-50 border-r border-gray-200 p-4 gap-4">
	<h2 class="text-sm font-semibold text-gray-400 uppercase tracking-wider mb-3">Furniture Catalog</h2>

	<div class="flex flex-col gap-2 overflow-y-auto max-h-[60vh]">
		{#each furnitureLibrary as item}
			<button
				type="button"
				class="flex items-center gap-3 p-2 rounded border cursor-pointer hover:bg-gray-200 transition-colors text-left"
				class:border-blue-500={selectedItem?.id === item.id}
				class:bg-blue-50={selectedItem?.id === item.id}
				on:click={() => selectItem(item)}
				role="option"
				aria-selected={selectedItem?.id === item.id}
			>
				<div class="w-10 h-10 bg-gray-300 rounded flex items-center justify-center shrink-0 text-lg">
					{getItemIcon(item.category)}
				</div>
				<div class="flex-1 min-w-0">
					<div class="text-sm font-medium text-gray-700 truncate">{item.name}</div>
					<div class="text-xs text-gray-500 truncate">{item.category}</div>
				</div>
			</button>
		{/each}
	</div>

	{#if selectedItem}
		<div class="pt-2 border-t border-gray-200">
			<div class="text-xs font-medium text-gray-600 mb-1">Selected: {selectedItem.name}</div>
			<div class="text-xs text-gray-500">
				Size: {selectedItem.size.x}cm × {selectedItem.size.y}cm
			</div>
		</div>
	{/if}
</div>
