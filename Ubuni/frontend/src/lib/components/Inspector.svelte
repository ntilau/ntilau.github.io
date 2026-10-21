<script lang="ts">
	import { design, deleteSelection, mutate, selection } from '$lib/store';
	import type { Door, FurnitureItem, Room, Wall, Window } from '$lib/types';
	import {
		clampOpeningPosition,
		newId,
		polygonArea,
		wallLength
	} from '$lib/geometry';

	$: selected = $selection;
	$: wall =
		selected?.type === 'wall'
			? ($design.walls.find((candidate) => candidate.id === selected?.id) ?? null)
			: null;
	$: room =
		selected?.type === 'room'
			? ($design.rooms.find((candidate) => candidate.id === selected?.id) ?? null)
			: null;
	$: door =
		selected?.type === 'door'
			? ($design.doors.find((candidate) => candidate.id === selected?.id) ?? null)
			: null;
	$: windowItem =
		selected?.type === 'window'
			? ($design.windows.find((candidate) => candidate.id === selected?.id) ?? null)
			: null;
	$: furniture =
		selected?.type === 'furniture'
			? ($design.furniture.find((candidate) => candidate.id === selected?.id) ?? null)
			: null;

	function valueOf(event: Event): string {
		return (event.currentTarget as HTMLInputElement).value;
	}

	function numberOf(event: Event): number {
		const parsed = Number(valueOf(event));
		return Number.isFinite(parsed) ? parsed : 0;
	}

	function updateWall(target: Wall, patch: Partial<Wall>) {
		mutate((current) => ({
			...current,
			walls: current.walls.map((candidate) =>
				candidate.id === target.id ? { ...candidate, ...patch } : candidate
			)
		}));
	}

	function updateRoom(target: Room, patch: Partial<Room>) {
		mutate((current) => ({
			...current,
			rooms: current.rooms.map((candidate) =>
				candidate.id === target.id ? { ...candidate, ...patch } : candidate
			)
		}));
	}

	function updateDoor(target: Door, widthMeters: number) {
		const wallForDoor = $design.walls.find((candidate) => candidate.id === target.wallId);
		if (!wallForDoor) return;
		const width = Math.max(0.2, Math.min(widthMeters, wallLength(wallForDoor)));
		mutate((current) => ({
			...current,
			doors: current.doors.map((candidate) =>
				candidate.id === target.id
					? {
							...candidate,
							width,
							position: clampOpeningPosition(candidate.position, wallForDoor, width)
						}
					: candidate
			)
		}));
	}

	function updateWindow(target: Window, widthMeters: number) {
		const wallForWindow = $design.walls.find((candidate) => candidate.id === target.wallId);
		if (!wallForWindow) return;
		const width = Math.max(0.2, Math.min(widthMeters, wallLength(wallForWindow)));
		mutate((current) => ({
			...current,
			windows: current.windows.map((candidate) =>
				candidate.id === target.id
					? {
							...candidate,
							width,
							position: clampOpeningPosition(candidate.position, wallForWindow, width)
						}
					: candidate
			)
		}));
	}

	function updateFurniture(target: FurnitureItem, patch: Partial<FurnitureItem>) {
		mutate((current) => ({
			...current,
			furniture: current.furniture.map((candidate) =>
				candidate.id === target.id ? { ...candidate, ...patch } : candidate
			)
		}));
	}

	function duplicateFurniture(target: FurnitureItem) {
		const copy: FurnitureItem = {
			...target,
			id: newId(),
			position: { x: target.position.x + 0.2, y: target.position.y + 0.2 },
			size: { ...target.size }
		};
		mutate((current) => ({ ...current, furniture: [...current.furniture, copy] }));
		selection.set({ type: 'furniture', id: copy.id });
	}

	function wallFor(opening: Door | Window): Wall | null {
		return $design.walls.find((candidate) => candidate.id === opening.wallId) ?? null;
	}

	function wallLengthText(opening: Door | Window): string {
		const host = wallFor(opening);
		return host ? `${wallLength(host).toFixed(2)} m` : '';
	}
</script>

<section class="border-t border-slate-200 p-4">
	<h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-slate-400">Inspector</h2>

	{#if !selected}
		<p class="text-sm text-slate-600">Select an object on the plan to edit it.</p>
		<div class="mt-3 space-y-1 text-xs text-slate-500">
			<p><span class="font-medium text-slate-700">V</span> select · <span class="font-medium text-slate-700">W</span> wall · <span class="font-medium text-slate-700">M</span> room</p>
			<p><span class="font-medium text-slate-700">D</span> door · <span class="font-medium text-slate-700">N</span> window · <span class="font-medium text-slate-700">F</span> furniture</p>
			<p><span class="font-medium text-slate-700">R</span> rotate · <span class="font-medium text-slate-700">Delete</span> remove · <span class="font-medium text-slate-700">G</span> snap</p>
			<p><span class="font-medium text-slate-700">Space</span> or middle-drag to pan · wheel to zoom · <span class="font-medium text-slate-700">0</span> to fit</p>
		</div>
	{:else if wall}
		<div class="space-y-3">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-semibold text-slate-800">Wall</h3>
				<span class="text-xs text-slate-500">{wallLength(wall).toFixed(2)} m long</span>
			</div>
			<label class="block text-xs font-medium text-slate-600">
				Thickness (cm)
				<input
					type="number"
					min="5"
					max="50"
					step="1"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={Math.round(wall.thickness * 100)}
					on:change={(event) => {
						const thickness = Math.max(0.05, Math.min(0.5, numberOf(event) / 100));
						updateWall(wall, { thickness });
					}}
				/>
			</label>
			<button
				type="button"
				class="w-full rounded border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
				on:click={deleteSelection}
			>
				Delete wall and openings
			</button>
		</div>
	{:else if room}
		<div class="space-y-3">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-semibold text-slate-800">Room</h3>
				<span class="text-xs text-slate-500">{polygonArea(room.points).toFixed(2)} m²</span>
			</div>
			<label class="block text-xs font-medium text-slate-600">
				Label
				<input
					type="text"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={room.label}
					on:change={(event) => updateRoom(room, { label: valueOf(event) })}
				/>
			</label>
			<label class="block text-xs font-medium text-slate-600">
				Color
				<input
					type="color"
					class="mt-1 h-8 w-full rounded border border-slate-300"
					value={room.color}
					on:change={(event) => updateRoom(room, { color: valueOf(event) })}
				/>
			</label>
			<button
				type="button"
				class="w-full rounded border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
				on:click={deleteSelection}
			>
				Delete room
			</button>
		</div>
	{:else if door}
		<div class="space-y-3">
			<h3 class="text-sm font-semibold text-slate-800">Door</h3>
			<label class="block text-xs font-medium text-slate-600">
				Width (cm)
				<input
					type="number"
					min="20"
					step="5"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={Math.round(door.width * 100)}
					on:change={(event) => updateDoor(door, numberOf(event) / 100)}
				/>
			</label>
			{#if wallFor(door)}
				<p class="text-xs text-slate-500">Wall length: {wallLengthText(door)}</p>
			{/if}
			<button
				type="button"
				class="w-full rounded border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
				on:click={deleteSelection}
			>
				Delete door
			</button>
		</div>
	{:else if windowItem}
		<div class="space-y-3">
			<h3 class="text-sm font-semibold text-slate-800">Window</h3>
			<label class="block text-xs font-medium text-slate-600">
				Width (cm)
				<input
					type="number"
					min="20"
					step="5"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={Math.round(windowItem.width * 100)}
					on:change={(event) => updateWindow(windowItem, numberOf(event) / 100)}
				/>
			</label>
			{#if wallFor(windowItem)}
				<p class="text-xs text-slate-500">Wall length: {wallLengthText(windowItem)}</p>
			{/if}
			<button
				type="button"
				class="w-full rounded border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
				on:click={deleteSelection}
			>
				Delete window
			</button>
		</div>
	{:else if furniture}
		<div class="space-y-3">
			<div class="flex items-center justify-between">
				<h3 class="text-sm font-semibold text-slate-800">Furniture</h3>
				<span class="text-xs capitalize text-slate-500">{furniture.category}</span>
			</div>
			<label class="block text-xs font-medium text-slate-600">
				Name
				<input
					type="text"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={furniture.name}
					on:change={(event) => updateFurniture(furniture, { name: valueOf(event) })}
				/>
			</label>
			<div class="grid grid-cols-2 gap-2">
				<label class="block text-xs font-medium text-slate-600">
					Width (cm)
					<input
						type="number"
						min="5"
						step="5"
						class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
						value={Math.round(furniture.size.x * 100)}
						on:change={(event) => {
							const width = Math.max(0.05, numberOf(event) / 100);
							updateFurniture(furniture, { size: { ...furniture.size, x: width } });
						}}
					/>
				</label>
				<label class="block text-xs font-medium text-slate-600">
					Depth (cm)
					<input
						type="number"
						min="5"
						step="5"
						class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
						value={Math.round(furniture.size.y * 100)}
						on:change={(event) => {
							const depth = Math.max(0.05, numberOf(event) / 100);
							updateFurniture(furniture, { size: { ...furniture.size, y: depth } });
						}}
					/>
				</label>
				<label class="block text-xs font-medium text-slate-600">
					X (m)
					<input
						type="number"
						step="0.1"
						class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
						value={furniture.position.x.toFixed(2)}
						on:change={(event) =>
							updateFurniture(furniture, {
								position: { ...furniture.position, x: numberOf(event) }
							})}
					/>
				</label>
				<label class="block text-xs font-medium text-slate-600">
					Y (m)
					<input
						type="number"
						step="0.1"
						class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
						value={furniture.position.y.toFixed(2)}
						on:change={(event) =>
							updateFurniture(furniture, {
								position: { ...furniture.position, y: numberOf(event) }
							})}
					/>
				</label>
			</div>
			<label class="block text-xs font-medium text-slate-600">
				Rotation (degrees)
				<input
					type="number"
					step="15"
					class="mt-1 w-full rounded border border-slate-300 px-2 py-1.5 text-sm"
					value={Math.round((furniture.rotation * 180) / Math.PI)}
					on:change={(event) =>
						updateFurniture(furniture, {
							rotation: (numberOf(event) * Math.PI) / 180
						})}
				/>
			</label>
			<div class="flex gap-2">
				<button
					type="button"
					class="flex-1 rounded border border-slate-300 px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
					on:click={() => duplicateFurniture(furniture)}
				>
					Duplicate
				</button>
				<button
					type="button"
					class="flex-1 rounded border border-red-200 px-3 py-1.5 text-sm font-medium text-red-600 hover:bg-red-50"
					on:click={deleteSelection}
				>
					Delete
				</button>
			</div>
		</div>
	{/if}
</section>
