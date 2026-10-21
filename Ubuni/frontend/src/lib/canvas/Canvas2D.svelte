<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
	import { get } from 'svelte/store';
	import * as THREE from 'three';
	import {
		activeTool,
		beginTransaction,
		cursorWorld,
		design,
		endTransaction,
		fitRequest,
		mutate,
		placementItem,
		selection,
		setTool,
		snapEnabled,
		statusMessage,
		zoom2D
	} from '$lib/store';
	import type {
		Design,
		Door,
		FurnitureItem,
		Point,
		Room,
		Selection,
		SelectionType,
		Wall,
		Window
	} from '$lib/types';
	import {
		clamp,
		clampOpeningPosition,
		closestWall,
		DEFAULT_DOOR_WIDTH,
		DEFAULT_WALL_THICKNESS,
		DEFAULT_WINDOW_WIDTH,
		designBounds,
		distance,
		newId,
		openingsForWall,
		pointAlongWall,
		repositionOpenings,
		snapPoint,
		snapToEndpoint,
		wallSegments
	} from '$lib/geometry';
	import { handleEditorKeydown, isEditableTarget } from '$lib/editorKeys';

	type HandleHit =
		| { kind: 'wall-start' | 'wall-end'; wallId: string }
		| { kind: 'room-vertex'; roomId: string; index: number };

	type DragState =
		| { mode: 'pan'; startClient: Point; startCenter: Point }
		| { mode: 'furniture'; id: string; offset: Point }
		| { mode: 'wall-endpoint'; wallId: string; endpoint: 'start' | 'end' }
		| { mode: 'room-vertex'; roomId: string; index: number }
		| { mode: 'opening'; kind: 'door' | 'window'; id: string; wallId: string };

	const BASE_PPM = 60;
	const MIN_PPM = 10;
	const MAX_PPM = 400;
	const HANDLE_RADIUS = 0.08;
	const ROOM_COLORS = ['#93c5fd', '#86efac', '#fcd34d', '#f9a8d4', '#c4b5fd', '#67e8f9'];

	const CATEGORY_COLORS: Record<string, number> = {
		seating: 0xf87171,
		tables: 0x2dd4bf,
		beds: 0x38bdf8,
		storage: 0xfacc15,
		lighting: 0xf0abfc,
		decor: 0x6ee7b7
	};

	let container!: HTMLDivElement;
	let scene!: THREE.Scene;
	let camera!: THREE.OrthographicCamera;
	let renderer!: THREE.WebGLRenderer;
	let raycaster!: THREE.Raycaster;
	let roomsGroup!: THREE.Group;
	let wallsGroup!: THREE.Group;
	let openingsGroup!: THREE.Group;
	let furnitureGroup!: THREE.Group;
	let handlesGroup!: THREE.Group;
	let previewGroup!: THREE.Group;
	let gridGroup!: THREE.Group;

	let widthPx = 1;
	let heightPx = 1;
	let center: Point = { x: 0, y: 0 };
	let ppm = BASE_PPM;

	let wallStart: Point | null = null;
	let roomPoints: Point[] = [];
	let pointerWorld: Point | null = null;
	let pointerShift = false;
	let spaceDown = false;
	let isPanning = false;
	let drag: DragState | null = null;
	let renderQueued = false;
	let frameRequest = 0;
	let resizeObserver: ResizeObserver | null = null;

	const unsubscribers: Array<() => void> = [];

	$: cursorClass = isPanning
		? 'cursor-grabbing'
		: $activeTool === 'pan'
			? 'cursor-grab'
			: $activeTool === 'select'
				? 'cursor-default'
				: 'cursor-crosshair';

	onMount(() => {
		if (!container) return;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0xf8fafc);

		camera = new THREE.OrthographicCamera(-1, 1, 1, -1, -1000, 1000);
		camera.position.set(0, 0, 100);

		renderer = new THREE.WebGLRenderer({ antialias: true });
		renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
		renderer.domElement.style.display = 'block';
		renderer.domElement.style.touchAction = 'none';
		container.appendChild(renderer.domElement);

		raycaster = new THREE.Raycaster();
		raycaster.params.Line = { threshold: 0.01 };

		roomsGroup = new THREE.Group();
		wallsGroup = new THREE.Group();
		openingsGroup = new THREE.Group();
		furnitureGroup = new THREE.Group();
		handlesGroup = new THREE.Group();
		previewGroup = new THREE.Group();
		gridGroup = new THREE.Group();
		scene.add(gridGroup, roomsGroup, wallsGroup, openingsGroup, furnitureGroup, handlesGroup, previewGroup);

		resizeObserver = new ResizeObserver(() => resize());
		resizeObserver.observe(container);

		container.addEventListener('pointerdown', onPointerDown);
		container.addEventListener('pointermove', onPointerMove);
		container.addEventListener('pointerup', onPointerUp);
		container.addEventListener('pointercancel', onPointerUp);
		container.addEventListener('wheel', onWheel, { passive: false });
		container.addEventListener('contextmenu', onContextMenu);
		container.addEventListener('dblclick', onDoubleClick);

		unsubscribers.push(
			design.subscribe(() => rebuild()),
			selection.subscribe(() => rebuild()),
			activeTool.subscribe(() => {
				statusMessage.set('');
				updatePreview();
			}),
			placementItem.subscribe(() => updatePreview()),
			fitRequest.subscribe(() => fitToDesign())
		);

		resize();
		fitToDesign();
	});

	onDestroy(() => {
		unsubscribers.forEach((unsubscribe) => unsubscribe());
		resizeObserver?.disconnect();

		if (container) {
			container.removeEventListener('pointerdown', onPointerDown);
			container.removeEventListener('pointermove', onPointerMove);
			container.removeEventListener('pointerup', onPointerUp);
			container.removeEventListener('pointercancel', onPointerUp);
			container.removeEventListener('wheel', onWheel);
			container.removeEventListener('contextmenu', onContextMenu);
			container.removeEventListener('dblclick', onDoubleClick);
		}

		if (frameRequest) cancelAnimationFrame(frameRequest);

		if (renderer) {
			if (renderer.domElement.parentElement) {
				renderer.domElement.parentElement.removeChild(renderer.domElement);
			}
			renderer.dispose();
		}

		for (const group of [
			gridGroup,
			roomsGroup,
			wallsGroup,
			openingsGroup,
			furnitureGroup,
			handlesGroup,
			previewGroup
		]) {
			if (group) clearGroup(group);
		}
	});

	function resize() {
		if (!container || !renderer || !camera) return;
		const rect = container.getBoundingClientRect();
		widthPx = Math.max(1, rect.width);
		heightPx = Math.max(1, rect.height);
		renderer.setSize(widthPx, heightPx);
		applyView();
		rebuildGrid();
		updatePreview();
		scheduleRender();
	}

	function applyView() {
		if (!camera) return;
		const halfWidth = widthPx / (2 * ppm);
		const halfHeight = heightPx / (2 * ppm);
		camera.left = -halfWidth;
		camera.right = halfWidth;
		camera.top = halfHeight;
		camera.bottom = -halfHeight;
		camera.position.set(center.x, center.y, 100);
		camera.updateProjectionMatrix();
	}

	function screenToWorld(clientX: number, clientY: number): Point {
		const rect = container.getBoundingClientRect();
		const nx = (clientX - rect.left) / Math.max(1, rect.width);
		const ny = (clientY - rect.top) / Math.max(1, rect.height);
		return {
			x: center.x + (nx - 0.5) * (rect.width / ppm),
			y: center.y - (ny - 0.5) * (rect.height / ppm)
		};
	}

	function ndcFromEvent(event: MouseEvent): THREE.Vector2 {
		const rect = container.getBoundingClientRect();
		return new THREE.Vector2(
			((event.clientX - rect.left) / Math.max(1, rect.width)) * 2 - 1,
			-(((event.clientY - rect.top) / Math.max(1, rect.height)) * 2 - 1)
		);
	}

	function setRaycaster(event: MouseEvent) {
		raycaster.setFromCamera(ndcFromEvent(event), camera);
	}

	function cursorSnapped(): Point | null {
		if (!pointerWorld) return null;
		let point = pointerWorld;
		const snapping = get(snapEnabled) && !pointerShift;
		const tool = get(activeTool);

		if (snapping) {
			point = snapPoint(point);
			if (tool === 'wall') {
				const endpoint = snapToEndpoint(point, get(design).walls, 0.25);
				if (endpoint) point = endpoint;
			}
			if (tool === 'room' && roomPoints.length >= 3) {
				if (distance(point, roomPoints[0]) <= 0.3) point = roomPoints[0];
			}
		}

		return point;
	}

	function rebuild() {
		if (!scene) return;
		clearGroup(roomsGroup);
		clearGroup(wallsGroup);
		clearGroup(openingsGroup);
		clearGroup(furnitureGroup);
		clearGroup(handlesGroup);

		const current = get(design);
		const selected = get(selection);

		current.rooms.forEach((room) => renderRoom(room, selected));
		current.walls.forEach((wall) => renderWall(current, wall, selected));
		current.doors.forEach((door) => renderDoor(current, door, selected));
		current.windows.forEach((window) => renderWindow(current, window, selected));
		current.furniture.forEach((item) => renderFurniture(item, selected));
		renderHandles(current, selected);

		rebuildGrid();
		updatePreview();
		scheduleRender();
	}

	function renderRoom(room: Room, selected: Selection) {
		const isSelected = selected?.type === 'room' && selected.id === room.id;
		const shape = new THREE.Shape();
		room.points.forEach((point, index) => {
			if (index === 0) shape.moveTo(point.x, point.y);
			else shape.lineTo(point.x, point.y);
		});
		shape.closePath();

		const geometry = new THREE.ShapeGeometry(shape);
		const material = new THREE.MeshBasicMaterial({
			color: new THREE.Color(room.color),
			transparent: true,
			opacity: isSelected ? 0.36 : 0.16,
			depthWrite: false,
			side: THREE.DoubleSide
		});
		const mesh = new THREE.Mesh(geometry, material);
		mesh.position.z = -0.02;
		mesh.userData = { type: 'room', id: room.id };
		roomsGroup.add(mesh);

		const outline = [...room.points, room.points[0]].map(
			(point) => new THREE.Vector3(point.x, point.y, 0.01)
		);
		const line = new THREE.Line(
			new THREE.BufferGeometry().setFromPoints(outline),
			new THREE.LineBasicMaterial({ color: isSelected ? 0x2563eb : room.color })
		);
		line.userData = { type: 'room', id: room.id };
		roomsGroup.add(line);
	}

	function renderWall(current: Design, wall: Wall, selected: Selection) {
		const isSelected = selected?.type === 'wall' && selected.id === wall.id;
		const openings = openingsForWall(current, wall);
		const segments = wallSegments(wall, openings);

		for (const segment of segments) {
			const length = distance(segment.start, segment.end);
			if (length < 1e-4) continue;
			const geometry = new THREE.BoxGeometry(length, wall.thickness, 0.05);
			const material = new THREE.MeshBasicMaterial({ color: isSelected ? 0x2563eb : 0x334155 });
			const mesh = new THREE.Mesh(geometry, material);
			mesh.position.set(
				(segment.start.x + segment.end.x) / 2,
				(segment.start.y + segment.end.y) / 2,
				0.02
			);
			mesh.rotation.z = Math.atan2(
				segment.end.y - segment.start.y,
				segment.end.x - segment.start.x
			);
			mesh.userData = { type: 'wall', id: wall.id };
			wallsGroup.add(mesh);
		}
	}

	function wallDirection(wall: Wall): Point {
		const length = Math.max(1e-9, distance(wall.start, wall.end));
		return {
			x: (wall.end.x - wall.start.x) / length,
			y: (wall.end.y - wall.start.y) / length
		};
	}

	function arcThrough(
		origin: Point,
		from: Point,
		to: Point,
		radius: number,
		z: number
	): THREE.Vector3[] {
		const startAngle = Math.atan2(from.y, from.x);
		const endAngle = Math.atan2(to.y, to.x);
		let delta = endAngle - startAngle;
		while (delta > Math.PI) delta -= Math.PI * 2;
		while (delta < -Math.PI) delta += Math.PI * 2;

		const points: THREE.Vector3[] = [];
		const steps = 20;
		for (let index = 0; index <= steps; index += 1) {
			const angle = startAngle + (delta * index) / steps;
			points.push(
				new THREE.Vector3(
					origin.x + Math.cos(angle) * radius,
					origin.y + Math.sin(angle) * radius,
					z
				)
			);
		}
		return points;
	}

	function addOpeningPickMesh(
		wall: Wall,
		start: Point,
		end: Point,
		width: number,
		type: 'door' | 'window',
		id: string
	) {
		const direction = wallDirection(wall);
		const geometry = new THREE.BoxGeometry(width, Math.max(wall.thickness, 0.1), 0.02);
		const material = new THREE.MeshBasicMaterial({
			transparent: true,
			opacity: 0,
			depthWrite: false
		});
		const mesh = new THREE.Mesh(geometry, material);
		mesh.position.set((start.x + end.x) / 2, (start.y + end.y) / 2, 0.03);
		mesh.rotation.z = Math.atan2(direction.y, direction.x);
		mesh.userData = { type, id };
		openingsGroup.add(mesh);
	}

	function renderDoor(current: Design, door: Door, selected: Selection) {
		const wall = current.walls.find((candidate) => candidate.id === door.wallId);
		if (!wall) return;
		const opening = openingsForWall(current, wall).find(
			(candidate) => candidate.kind === 'door' && candidate.id === door.id
		);
		if (!opening) return;

		const direction = wallDirection(wall);
		const normal = { x: -direction.y, y: direction.x };
		const gapStart = pointAlongWall(wall, opening.t - opening.width / 2);
		const gapEnd = pointAlongWall(wall, opening.t + opening.width / 2);
		const leafEnd = {
			x: gapStart.x + normal.x * opening.width,
			y: gapStart.y + normal.y * opening.width
		};
		const isSelected = selected?.type === 'door' && selected.id === door.id;
		const color = isSelected ? 0x2563eb : 0x92400e;

		openingsGroup.add(
			new THREE.Line(
				new THREE.BufferGeometry().setFromPoints([
					new THREE.Vector3(gapStart.x, gapStart.y, 0.04),
					new THREE.Vector3(leafEnd.x, leafEnd.y, 0.04)
				]),
				new THREE.LineBasicMaterial({ color })
			)
		);
		openingsGroup.add(
			new THREE.Line(
				new THREE.BufferGeometry().setFromPoints(
					arcThrough(gapStart, direction, normal, opening.width, 0.04)
				),
				new THREE.LineBasicMaterial({ color })
			)
		);

		addOpeningPickMesh(wall, gapStart, gapEnd, opening.width, 'door', door.id);
	}

	function renderWindow(current: Design, window: Window, selected: Selection) {
		const wall = current.walls.find((candidate) => candidate.id === window.wallId);
		if (!wall) return;
		const opening = openingsForWall(current, wall).find(
			(candidate) => candidate.kind === 'window' && candidate.id === window.id
		);
		if (!opening) return;

		const direction = wallDirection(wall);
		const normal = { x: -direction.y, y: direction.x };
		const gapStart = pointAlongWall(wall, opening.t - opening.width / 2);
		const gapEnd = pointAlongWall(wall, opening.t + opening.width / 2);
		const offset = Math.max(0.03, wall.thickness / 4);
		const isSelected = selected?.type === 'window' && selected.id === window.id;
		const color = isSelected ? 0x2563eb : 0x0284c7;

		for (const side of [-1, 1]) {
			const shift = { x: normal.x * offset * side, y: normal.y * offset * side };
			openingsGroup.add(
				new THREE.Line(
					new THREE.BufferGeometry().setFromPoints([
						new THREE.Vector3(gapStart.x + shift.x, gapStart.y + shift.y, 0.04),
						new THREE.Vector3(gapEnd.x + shift.x, gapEnd.y + shift.y, 0.04)
					]),
					new THREE.LineBasicMaterial({ color })
				)
			);
		}

		addOpeningPickMesh(wall, gapStart, gapEnd, opening.width, 'window', window.id);
	}

	function renderFurniture(item: FurnitureItem, selected: Selection) {
		const isSelected = selected?.type === 'furniture' && selected.id === item.id;
		const geometry = new THREE.BoxGeometry(item.size.x, item.size.y, 0.06);
		const material = new THREE.MeshBasicMaterial({
			color: isSelected ? 0xf59e0b : (CATEGORY_COLORS[item.category] ?? 0x64748b),
			transparent: true,
			opacity: isSelected ? 0.96 : 0.82
		});
		const mesh = new THREE.Mesh(geometry, material);
		mesh.position.set(item.position.x, item.position.y, 0.04);
		mesh.rotation.z = item.rotation;
		mesh.userData = { type: 'furniture', id: item.id };
		furnitureGroup.add(mesh);

		if (isSelected) {
			const outline = new THREE.LineSegments(
				new THREE.EdgesGeometry(new THREE.BoxGeometry(item.size.x, item.size.y, 0.07)),
				new THREE.LineBasicMaterial({ color: 0xb45309 })
			);
			outline.position.copy(mesh.position);
			outline.position.z = 0.07;
			outline.rotation.z = item.rotation;
			outline.userData = { type: 'furniture', id: item.id };
			furnitureGroup.add(outline);
		}
	}

	function renderHandles(current: Design, selected: Selection) {
		if (!selected) return;

		const addHandle = (point: Point, userData: Record<string, unknown>) => {
			const geometry = new THREE.CircleGeometry(HANDLE_RADIUS, 20);
			const material = new THREE.MeshBasicMaterial({ color: 0xf59e0b });
			const mesh = new THREE.Mesh(geometry, material);
			mesh.position.set(point.x, point.y, 0.09);
			mesh.userData = { type: 'handle', ...userData };
			handlesGroup.add(mesh);
		};

		if (selected.type === 'wall') {
			const wall = current.walls.find((candidate) => candidate.id === selected.id);
			if (!wall) return;
			addHandle(wall.start, { handle: 'wall-start', wallId: wall.id });
			addHandle(wall.end, { handle: 'wall-end', wallId: wall.id });
		}

		if (selected.type === 'room') {
			const room = current.rooms.find((candidate) => candidate.id === selected.id);
			if (!room) return;
			room.points.forEach((point, index) => {
				addHandle(point, { handle: 'room-vertex', roomId: room.id, index });
			});
		}

		refreshHandleScale();
	}

	function refreshHandleScale() {
		if (!handlesGroup) return;
		const targetRadius = 8 / ppm;
		const scale = targetRadius / HANDLE_RADIUS;
		handlesGroup.children.forEach((child) => child.scale.setScalar(scale));
	}

	function updatePreview() {
		if (!previewGroup) return;
		clearGroup(previewGroup);

		const tool = get(activeTool);
		const point = cursorSnapped();
		if (!point) return;

		if (tool === 'wall' && wallStart) {
			previewGroup.add(
				new THREE.Line(
					new THREE.BufferGeometry().setFromPoints([
						new THREE.Vector3(wallStart.x, wallStart.y, 0.1),
						new THREE.Vector3(point.x, point.y, 0.1)
					]),
					new THREE.LineBasicMaterial({ color: 0x2563eb })
				)
			);
			statusMessage.set(
				`Wall length ${distance(wallStart, point).toFixed(2)} m — click to add, Enter to finish`
			);
			return;
		}

		if (tool === 'room' && roomPoints.length > 0) {
			const points = [...roomPoints, point].map(
				(candidate) => new THREE.Vector3(candidate.x, candidate.y, 0.1)
			);
			if (roomPoints.length >= 2) points.push(points[0]);
			previewGroup.add(
				new THREE.Line(
					new THREE.BufferGeometry().setFromPoints(points),
					new THREE.LineBasicMaterial({ color: 0x2563eb })
				)
			);
			statusMessage.set(
				`${roomPoints.length} point${roomPoints.length === 1 ? '' : 's'} — click the first point or press Enter to close`
			);
			return;
		}

		if (tool === 'furniture') {
			const item = get(placementItem);
			if (!item) {
				statusMessage.set('Choose a furniture item from the catalog');
				return;
			}
			const ghost = new THREE.Mesh(
				new THREE.BoxGeometry(item.size.x, item.size.y, 0.04),
				new THREE.MeshBasicMaterial({
					color: 0x2563eb,
					transparent: true,
					opacity: 0.35
				})
			);
			ghost.position.set(point.x, point.y, 0.1);
			previewGroup.add(ghost);
			statusMessage.set(`Click to place ${item.name}`);
			return;
		}

		if (tool === 'door' || tool === 'window') {
			const hit = closestWall(get(design).walls, point, 0.6);
			if (!hit) {
				statusMessage.set(`Click on a wall to place a ${tool}`);
				return;
			}
			const width = tool === 'door' ? DEFAULT_DOOR_WIDTH : DEFAULT_WINDOW_WIDTH;
			const position = clampOpeningPosition(point, hit.wall, width);
			const direction = wallDirection(hit.wall);
			const ghost = new THREE.Mesh(
				new THREE.BoxGeometry(width, Math.max(hit.wall.thickness, 0.08), 0.03),
				new THREE.MeshBasicMaterial({
					color: tool === 'door' ? 0x92400e : 0x0284c7,
					transparent: true,
					opacity: 0.5
				})
			);
			ghost.position.set(position.x, position.y, 0.1);
			ghost.rotation.z = Math.atan2(direction.y, direction.x);
			previewGroup.add(ghost);
			statusMessage.set(`Click to place a ${tool}`);
		}
	}

	function rebuildGrid() {
		if (!gridGroup) return;
		clearGroup(gridGroup);

		const halfWidth = widthPx / (2 * ppm);
		const halfHeight = heightPx / (2 * ppm);
		const minX = center.x - halfWidth;
		const maxX = center.x + halfWidth;
		const minY = center.y - halfHeight;
		const maxY = center.y + halfHeight;

		let step = ppm >= 40 ? 0.5 : ppm >= 15 ? 1 : 5;
		while ((maxX - minX) / step > 400 || (maxY - minY) / step > 400) step *= 2;
		const majorStep = step * 5;

		const minor: number[] = [];
		const major: number[] = [];

		const pushLine = (target: number[], x1: number, y1: number, x2: number, y2: number) => {
			target.push(x1, y1, -0.05, x2, y2, -0.05);
		};

		for (let x = Math.floor(minX / step) * step; x <= maxX; x += step) {
			const isMajor = Math.abs(x % majorStep) < 1e-6;
			pushLine(isMajor ? major : minor, x, minY, x, maxY);
		}
		for (let y = Math.floor(minY / step) * step; y <= maxY; y += step) {
			const isMajor = Math.abs(y % majorStep) < 1e-6;
			pushLine(isMajor ? major : minor, minX, y, maxX, y);
		}

		const addLines = (positions: number[], color: number) => {
			if (positions.length === 0) return;
			const geometry = new THREE.BufferGeometry();
			geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
			gridGroup.add(new THREE.LineSegments(geometry, new THREE.LineBasicMaterial({ color })));
		};

		addLines(minor, 0xe2e8f0);
		addLines(major, 0xcbd5e1);
	}

	function scheduleRender() {
		if (renderQueued || !renderer) return;
		renderQueued = true;
		frameRequest = requestAnimationFrame(() => {
			renderQueued = false;
			renderer.render(scene, camera);
		});
	}

	function disposeObject(object: THREE.Object3D) {
		object.traverse((child) => {
			const mesh = child as THREE.Mesh;
			if (mesh.geometry) mesh.geometry.dispose();
			const material = (mesh as unknown as { material?: THREE.Material | THREE.Material[] }).material;
			if (Array.isArray(material)) material.forEach((entry) => entry.dispose());
			else material?.dispose();
		});
	}

	function clearGroup(group: THREE.Group) {
		while (group.children.length > 0) {
			const child = group.children[0];
			group.remove(child);
			disposeObject(child);
		}
	}

	function pickHandle(event: MouseEvent): HandleHit | null {
		setRaycaster(event);
		const hits = raycaster.intersectObjects(handlesGroup.children, false);
		const data = hits[0]?.object.userData as {
			type?: string;
			handle?: string;
			wallId?: string;
			roomId?: string;
			index?: number;
		};
		if (!data || data.type !== 'handle') return null;
		if ((data.handle === 'wall-start' || data.handle === 'wall-end') && data.wallId) {
			return { kind: data.handle, wallId: data.wallId };
		}
		if (data.handle === 'room-vertex' && data.roomId && typeof data.index === 'number') {
			return { kind: 'room-vertex', roomId: data.roomId, index: data.index };
		}
		return null;
	}

	function pickObject(event: MouseEvent): { type: SelectionType; id: string } | null {
		setRaycaster(event);
		const candidates = [
			...wallsGroup.children,
			...roomsGroup.children,
			...openingsGroup.children,
			...furnitureGroup.children
		].filter((child) => (child as THREE.Mesh).isMesh);

		const hits = raycaster.intersectObjects(candidates, false);
		for (const hit of hits) {
			const data = hit.object.userData as { type?: string; id?: string };
			if (data.type && data.id && data.type !== 'handle') {
				return { type: data.type as SelectionType, id: data.id };
			}
		}
		return null;
	}

	function onPointerDown(event: PointerEvent) {
		if (event.button === 2) return;
		const point = screenToWorld(event.clientX, event.clientY);
		pointerWorld = point;
		pointerShift = event.shiftKey;
		cursorWorld.set(point);

		const tool = get(activeTool);

		if (event.button === 1 || spaceDown || tool === 'pan') {
			event.preventDefault();
			drag = {
				mode: 'pan',
				startClient: { x: event.clientX, y: event.clientY },
				startCenter: { ...center }
			};
			isPanning = true;
			container.setPointerCapture(event.pointerId);
			return;
		}

		if (tool === 'select') {
			const handle = pickHandle(event);
			if (handle) {
				beginTransaction();
				drag =
					handle.kind === 'room-vertex'
						? { mode: 'room-vertex', roomId: handle.roomId, index: handle.index }
						: {
								mode: 'wall-endpoint',
								wallId: handle.wallId,
								endpoint: handle.kind === 'wall-start' ? 'start' : 'end'
							};
				container.setPointerCapture(event.pointerId);
				return;
			}

			const hit = pickObject(event);
			if (!hit) {
				selection.set(null);
				return;
			}

			selection.set({ type: hit.type, id: hit.id });
			const current = get(design);

			if (hit.type === 'furniture') {
				const item = current.furniture.find((candidate) => candidate.id === hit.id);
				if (!item) return;
				beginTransaction();
				drag = {
					mode: 'furniture',
					id: item.id,
					offset: { x: item.position.x - point.x, y: item.position.y - point.y }
				};
				container.setPointerCapture(event.pointerId);
			} else if (hit.type === 'door' || hit.type === 'window') {
				const opening =
					hit.type === 'door'
						? current.doors.find((candidate) => candidate.id === hit.id)
						: current.windows.find((candidate) => candidate.id === hit.id);
				if (!opening) return;
				beginTransaction();
				drag = {
					mode: 'opening',
					kind: hit.type,
					id: opening.id,
					wallId: opening.wallId
				};
				container.setPointerCapture(event.pointerId);
			}
			return;
		}

		if (tool === 'wall') {
			placeWallPoint(point);
			return;
		}
		if (tool === 'room') {
			placeRoomPoint(point);
			return;
		}
		if (tool === 'door' || tool === 'window') {
			placeOpening(tool, point);
			return;
		}
		if (tool === 'furniture') {
			placeFurniture(point);
		}
	}

	function onPointerMove(event: PointerEvent) {
		pointerShift = event.shiftKey;
		const point = screenToWorld(event.clientX, event.clientY);
		pointerWorld = point;
		cursorWorld.set(point);

		if (!drag) {
			updatePreview();
			scheduleRender();
			return;
		}

		if (drag.mode === 'pan') {
			center = {
				x: drag.startCenter.x - (event.clientX - drag.startClient.x) / ppm,
				y: drag.startCenter.y + (event.clientY - drag.startClient.y) / ppm
			};
			applyView();
			rebuildGrid();
			updatePreview();
			scheduleRender();
			return;
		}

		if (drag.mode === 'furniture') {
			const dragState = drag;
			const position = snapPoint(
				{ x: point.x + dragState.offset.x, y: point.y + dragState.offset.y },
				0.1,
				get(snapEnabled) && !event.shiftKey
			);
			mutate(
				(current) => ({
					...current,
					furniture: current.furniture.map((item) =>
						item.id === dragState.id ? { ...item, position } : item
					)
				}),
				{ history: false }
			);
			return;
		}

		if (drag.mode === 'opening') {
			const dragState = drag;
			const current = get(design);
			const wall = current.walls.find((candidate) => candidate.id === dragState.wallId);
			if (!wall) return;
			const opening =
				dragState.kind === 'door'
					? current.doors.find((candidate) => candidate.id === dragState.id)
					: current.windows.find((candidate) => candidate.id === dragState.id);
			if (!opening) return;
			const position = clampOpeningPosition(point, wall, opening.width);

			mutate(
				(state) =>
					dragState.kind === 'door'
						? {
								...state,
								doors: state.doors.map((candidate) =>
									candidate.id === dragState.id ? { ...candidate, position } : candidate
								)
							}
						: {
								...state,
								windows: state.windows.map((candidate) =>
									candidate.id === dragState.id ? { ...candidate, position } : candidate
								)
							},
				{ history: false }
			);
			return;
		}

		if (drag.mode === 'wall-endpoint') {
			const dragState = drag;
			const position = snapPoint(point, 0.1, get(snapEnabled) && !event.shiftKey);
			mutate(
				(current) => {
					const wall = current.walls.find((candidate) => candidate.id === dragState.wallId);
					if (!wall) return current;
					const moved: Wall = { ...wall, [dragState.endpoint]: position };
					return {
						...current,
						walls: current.walls.map((candidate) =>
							candidate.id === wall.id ? moved : candidate
						),
						doors: repositionOpenings(wall, moved, current.doors),
						windows: repositionOpenings(wall, moved, current.windows)
					};
				},
				{ history: false }
			);
			return;
		}

		if (drag.mode === 'room-vertex') {
			const dragState = drag;
			const position = snapPoint(point, 0.1, get(snapEnabled) && !event.shiftKey);
			mutate(
				(current) => ({
					...current,
					rooms: current.rooms.map((room) =>
						room.id === dragState.roomId
							? {
									...room,
									points: room.points.map((candidate, index) =>
										index === dragState.index ? position : candidate
									)
								}
							: room
					)
				}),
				{ history: false }
			);
		}
	}

	function onPointerUp(event: PointerEvent) {
		if (drag) {
			const hadHistory = drag.mode !== 'pan';
			drag = null;
			isPanning = false;
			if (hadHistory) endTransaction();
			try {
				container.releasePointerCapture(event.pointerId);
			} catch {
				// Pointer may already be released.
			}
			updatePreview();
			scheduleRender();
		}
	}

	function onWheel(event: WheelEvent) {
		event.preventDefault();
		const before = screenToWorld(event.clientX, event.clientY);
		const rect = container.getBoundingClientRect();
		const nx = (event.clientX - rect.left) / Math.max(1, rect.width);
		const ny = (event.clientY - rect.top) / Math.max(1, rect.height);
		const next = clamp(ppm * Math.exp(-event.deltaY * 0.0015), MIN_PPM, MAX_PPM);
		if (Math.abs(next - ppm) < 1e-6) return;

		ppm = next;
		center = {
			x: before.x - (nx - 0.5) * (rect.width / ppm),
			y: before.y + (ny - 0.5) * (rect.height / ppm)
		};
		zoom2D.set(ppm);
		applyView();
		rebuildGrid();
		refreshHandleScale();
		updatePreview();
		scheduleRender();
	}

	function onContextMenu(event: MouseEvent) {
		event.preventDefault();
		cancelOperation();
	}

	function onDoubleClick(event: MouseEvent) {
		const tool = get(activeTool);
		if (tool === 'wall' && wallStart) {
			event.preventDefault();
			finishWall();
		} else if (tool === 'room' && roomPoints.length >= 3) {
			event.preventDefault();
			finishRoom();
		}
	}

	function onKeyDown(event: KeyboardEvent) {
		if (isEditableTarget(event.target)) return;
		if (event.code === 'Space') {
			spaceDown = true;
			event.preventDefault();
			return;
		}
		if (event.key === 'Enter') {
			const tool = get(activeTool);
			if (tool === 'wall' && wallStart) {
				event.preventDefault();
				finishWall();
				return;
			}
			if (tool === 'room' && roomPoints.length >= 3) {
				event.preventDefault();
				finishRoom();
				return;
			}
		}
		handleEditorKeydown(event, { cancel: cancelOperation, fit: fitToDesign });
	}

	function onKeyUp(event: KeyboardEvent) {
		if (event.code === 'Space') spaceDown = false;
	}

	function cancelOperation(): boolean {
		if (drag) {
			const hadHistory = drag.mode !== 'pan';
			drag = null;
			isPanning = false;
			if (hadHistory) endTransaction();
			updatePreview();
			return true;
		}
		if (wallStart) {
			finishWall();
			return true;
		}
		if (roomPoints.length > 0) {
			roomPoints = [];
			statusMessage.set('');
			updatePreview();
			return true;
		}
		if (get(activeTool) === 'furniture' && get(placementItem)) {
			placementItem.set(null);
			setTool('select');
			return true;
		}
		return false;
	}

	function finishWall() {
		wallStart = null;
		statusMessage.set('');
		updatePreview();
	}

	function placeWallPoint(point: Point) {
		const snapped = cursorSnapped() ?? point;
		if (!wallStart) {
			wallStart = { ...snapped };
			statusMessage.set('Click to set the end of the wall');
			updatePreview();
			return;
		}

		if (distance(wallStart, snapped) < 0.05) return;

		const wall: Wall = {
			id: newId(),
			start: { ...wallStart },
			end: { ...snapped },
			thickness: DEFAULT_WALL_THICKNESS
		};

		mutate((current) => ({ ...current, walls: [...current.walls, wall] }));
		selection.set({ type: 'wall', id: wall.id });
		wallStart = { ...snapped };
		statusMessage.set('Click to continue the wall, Enter or Esc to finish');
		updatePreview();
	}

	function placeRoomPoint(point: Point) {
		const snapped = cursorSnapped() ?? point;

		if (roomPoints.length >= 3 && distance(snapped, roomPoints[0]) <= 0.3) {
			finishRoom();
			return;
		}

		const last = roomPoints[roomPoints.length - 1];
		if (last && distance(last, snapped) < 0.05) return;

		roomPoints = [...roomPoints, snapped];
		statusMessage.set(
			`${roomPoints.length} point${roomPoints.length === 1 ? '' : 's'} — click the first point or press Enter to close`
		);
		updatePreview();
	}

	function finishRoom() {
		if (roomPoints.length < 3) {
			roomPoints = [];
			statusMessage.set('');
			updatePreview();
			return;
		}

		const index = get(design).rooms.length;
		const room: Room = {
			id: newId(),
			points: roomPoints.map((point) => ({ ...point })),
			label: `Room ${index + 1}`,
			color: ROOM_COLORS[index % ROOM_COLORS.length]
		};

		mutate((current) => ({ ...current, rooms: [...current.rooms, room] }));
		selection.set({ type: 'room', id: room.id });
		roomPoints = [];
		statusMessage.set('');
		updatePreview();
	}

	function placeOpening(kind: 'door' | 'window', point: Point) {
		const hit = closestWall(get(design).walls, point, 0.6);
		if (!hit) {
			statusMessage.set(`Click directly on a wall to place a ${kind}`);
			return;
		}

		const width = kind === 'door' ? DEFAULT_DOOR_WIDTH : DEFAULT_WINDOW_WIDTH;
		const position = clampOpeningPosition(point, hit.wall, width);
		const id = newId();

		if (kind === 'door') {
			mutate((current) => ({
				...current,
				doors: [...current.doors, { id, position, width, wallId: hit.wall.id }]
			}));
		} else {
			mutate((current) => ({
				...current,
				windows: [...current.windows, { id, position, width, wallId: hit.wall.id }]
			}));
		}

		selection.set({ type: kind, id });
		statusMessage.set(`${kind === 'door' ? 'Door' : 'Window'} placed — click another wall or press Esc`);
		updatePreview();
	}

	function placeFurniture(point: Point) {
		const template = get(placementItem);
		if (!template) {
			statusMessage.set('Choose a furniture item from the catalog');
			return;
		}

		const snapped = cursorSnapped() ?? point;
		const item: FurnitureItem = {
			id: newId(),
			name: template.name,
			category: template.category,
			size: { ...template.size },
			position: { ...snapped },
			rotation: 0
		};

		mutate((current) => ({ ...current, furniture: [...current.furniture, item] }));
		selection.set({ type: 'furniture', id: item.id });
		statusMessage.set(`${template.name} placed — click to place another, Esc to stop`);
		updatePreview();
	}

	function fitToDesign() {
		const bounds = designBounds(get(design));
		if (bounds.width < 1e-6 && bounds.height < 1e-6) {
			center = { x: 0, y: 0 };
			ppm = BASE_PPM;
		} else {
			const padding = 1.5;
			const scaleX = widthPx / Math.max(1e-6, bounds.width + padding * 2);
			const scaleY = heightPx / Math.max(1e-6, bounds.height + padding * 2);
			ppm = clamp(Math.min(scaleX, scaleY), MIN_PPM, MAX_PPM);
			center = {
				x: (bounds.minX + bounds.maxX) / 2,
				y: (bounds.minY + bounds.maxY) / 2
			};
		}

		zoom2D.set(ppm);
		applyView();
		rebuildGrid();
		refreshHandleScale();
		updatePreview();
		scheduleRender();
	}
</script>

<svelte:window on:keydown={onKeyDown} on:keyup={onKeyUp} />

<div bind:this={container} class="absolute inset-0 {cursorClass}" />
