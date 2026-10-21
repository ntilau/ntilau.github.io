<script lang="ts">
	import { onDestroy, onMount } from 'svelte';
	import { get } from 'svelte/store';
	import * as THREE from 'three';
	import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
	import { design, fitRequest, selection } from '$lib/store';
	import type { Design, Point, Selection, SelectionType } from '$lib/types';
	import {
		boundsCenter,
		designBounds,
		openingsForWall,
		pointAlongWall,
		wallSegments
	} from '$lib/geometry';

	const WALL_HEIGHT = 2.7;
	const DOOR_HEIGHT = 2.1;
	const WINDOW_SILL = 0.9;
	const WINDOW_HEIGHT = 1.2;

	const FURNITURE_HEIGHTS: Record<string, number> = {
		seating: 0.45,
		tables: 0.75,
		beds: 0.5,
		storage: 1.8,
		lighting: 1.5,
		decor: 0.3
	};

	let container!: HTMLDivElement;
	let scene!: THREE.Scene;
	let camera!: THREE.PerspectiveCamera;
	let renderer!: THREE.WebGLRenderer;
	let controls!: OrbitControls;
	let raycaster!: THREE.Raycaster;
	let modelGroup!: THREE.Group;
	let selectionGroup!: THREE.Group;
	let frameRequest = 0;
	let resizeObserver: ResizeObserver | null = null;
	let pointerStart: { x: number; y: number } | null = null;
	let pointerMoved = false;

	const unsubscribers: Array<() => void> = [];
	const pickables = new Map<string, THREE.Object3D>();

	function keyFor(type: SelectionType, id: string): string {
		return `${type}:${id}`;
	}

	onMount(() => {
		if (!container) return;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0xe2e8f0);
		scene.fog = new THREE.Fog(0xe2e8f0, 40, 90);

		camera = new THREE.PerspectiveCamera(55, 1, 0.1, 500);
		camera.position.set(9, 10, 12);

		renderer = new THREE.WebGLRenderer({ antialias: true });
		renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
		renderer.shadowMap.enabled = true;
		renderer.shadowMap.type = THREE.PCFSoftShadowMap;
		renderer.domElement.style.display = 'block';
		renderer.domElement.style.touchAction = 'none';
		container.appendChild(renderer.domElement);

		controls = new OrbitControls(camera, renderer.domElement);
		controls.enableDamping = true;
		controls.dampingFactor = 0.08;
		controls.maxPolarAngle = Math.PI / 2 - 0.03;
		controls.minDistance = 1.5;
		controls.maxDistance = 80;
		controls.target.set(0, 0.8, 0);

		raycaster = new THREE.Raycaster();

		const ambient = new THREE.HemisphereLight(0xffffff, 0x94a3b8, 1.6);
		scene.add(ambient);

		const directional = new THREE.DirectionalLight(0xffffff, 2.1);
		directional.position.set(10, 16, 8);
		directional.castShadow = true;
		directional.shadow.mapSize.set(1024, 1024);
		directional.shadow.camera.near = 0.5;
		directional.shadow.camera.far = 60;
		directional.shadow.camera.left = -20;
		directional.shadow.camera.right = 20;
		directional.shadow.camera.top = 20;
		directional.shadow.camera.bottom = -20;
		scene.add(directional);

		const ground = new THREE.Mesh(
			new THREE.PlaneGeometry(200, 200),
			new THREE.MeshStandardMaterial({ color: 0xf1f5f9, roughness: 1 })
		);
		ground.rotation.x = -Math.PI / 2;
		ground.position.y = -0.012;
		ground.receiveShadow = true;
		scene.add(ground);

		const grid = new THREE.GridHelper(80, 80, 0xcbd5e1, 0xe2e8f0);
		grid.position.y = -0.005;
		scene.add(grid);

		modelGroup = new THREE.Group();
		selectionGroup = new THREE.Group();
		scene.add(modelGroup, selectionGroup);

		resizeObserver = new ResizeObserver(() => resize());
		resizeObserver.observe(container);

		renderer.domElement.addEventListener('pointerdown', onPointerDown);
		renderer.domElement.addEventListener('pointermove', onPointerMove);
		renderer.domElement.addEventListener('pointerup', onPointerUp);

		unsubscribers.push(
			design.subscribe(() => rebuild()),
			selection.subscribe(() => refreshSelection()),
			fitRequest.subscribe(() => fitCamera())
		);

		resize();
		fitCamera();

		const animate = () => {
			frameRequest = requestAnimationFrame(animate);
			controls.update();
			renderer.render(scene, camera);
		};
		animate();
	});

	onDestroy(() => {
		unsubscribers.forEach((unsubscribe) => unsubscribe());
		resizeObserver?.disconnect();
		if (frameRequest) cancelAnimationFrame(frameRequest);

		if (renderer) {
			renderer.domElement.removeEventListener('pointerdown', onPointerDown);
			renderer.domElement.removeEventListener('pointermove', onPointerMove);
			renderer.domElement.removeEventListener('pointerup', onPointerUp);
		}
		controls?.dispose();

		if (renderer) {
			if (renderer.domElement.parentElement) {
				renderer.domElement.parentElement.removeChild(renderer.domElement);
			}
			renderer.dispose();
		}

		if (modelGroup) clearGroup(modelGroup);
		if (selectionGroup) clearGroup(selectionGroup);
		pickables.clear();
	});

	function resize() {
		if (!container || !renderer || !camera) return;
		const rect = container.getBoundingClientRect();
		const width = Math.max(1, rect.width);
		const height = Math.max(1, rect.height);
		renderer.setSize(width, height);
		camera.aspect = width / height;
		camera.updateProjectionMatrix();
	}

	function fitCamera() {
		if (!camera || !controls) return;
		const bounds = designBounds(get(design));
		const center = boundsCenter(bounds);
		const radius = Math.max(3, Math.max(bounds.width, bounds.height) * 0.75);

		controls.target.set(center.x, 0.8, -center.y);
		camera.position.set(center.x + radius * 1.2, radius * 1.15 + 2.5, -center.y + radius * 1.35);
		controls.update();
	}

	function rebuild() {
		if (!modelGroup) return;
		clearGroup(modelGroup);
		pickables.clear();

		const current = get(design);
		current.rooms.forEach((room) => addRoom(room));
		current.walls.forEach((wall) => addWall(current, wall));
		current.furniture.forEach((item) => addFurniture(item));

		refreshSelection();
	}

	function refreshSelection() {
		if (!selectionGroup) return;
		clearGroup(selectionGroup);

		const selected = get(selection);
		if (!selected) return;
		const object = pickables.get(keyFor(selected.type, selected.id));
		if (!object) return;

		const helper = new THREE.BoxHelper(object, 0x2563eb);
		selectionGroup.add(helper);
	}

	function clearGroup(group: THREE.Group) {
		while (group.children.length > 0) {
			const child = group.children[0];
			group.remove(child);
			disposeObject(child);
		}
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

	function register(type: SelectionType, id: string, object: THREE.Object3D) {
		object.userData = { type, id };
		pickables.set(keyFor(type, id), object);
		modelGroup.add(object);
		return object;
	}

	function addBox(
		parent: THREE.Object3D,
		options: {
			width: number;
			height: number;
			depth: number;
			center: Point;
			y: number;
			rotation: number;
			color: number;
			opacity?: number;
		}
	) {
		const geometry = new THREE.BoxGeometry(options.width, options.height, options.depth);
		const material = new THREE.MeshStandardMaterial({
			color: options.color,
			roughness: 0.82,
			metalness: 0.04,
			transparent: options.opacity !== undefined,
			opacity: options.opacity ?? 1
		});
		const mesh = new THREE.Mesh(geometry, material);
		mesh.position.set(options.center.x, options.y, -options.center.y);
		mesh.rotation.y = options.rotation;
		mesh.castShadow = true;
		mesh.receiveShadow = true;
		parent.add(mesh);
		return mesh;
	}

	function addRoom(room: { id: string; points: Point[]; color: string }) {
		const group = new THREE.Group();
		const shape = new THREE.Shape();
		room.points.forEach((point, index) => {
			if (index === 0) shape.moveTo(point.x, point.y);
			else shape.lineTo(point.x, point.y);
		});
		shape.closePath();

		const geometry = new THREE.ShapeGeometry(shape);
		const material = new THREE.MeshStandardMaterial({
			color: new THREE.Color(room.color),
			transparent: true,
			opacity: 0.45,
			side: THREE.DoubleSide,
			depthWrite: false,
			roughness: 1
		});
		const mesh = new THREE.Mesh(geometry, material);
		mesh.rotation.x = -Math.PI / 2;
		mesh.position.y = 0.006;
		mesh.receiveShadow = true;
		group.add(mesh);

		register('room', room.id, group);
	}

	function addWall(current: Design, wall: { id: string; start: Point; end: Point; thickness: number }) {
		const group = new THREE.Group();
		const openings = openingsForWall(current, wall);
		const segments = wallSegments(wall, openings);
		const dx = wall.end.x - wall.start.x;
		const dy = wall.end.y - wall.start.y;
		const rotation = Math.atan2(dy, dx);

		for (const segment of segments) {
			const length = Math.hypot(
				segment.end.x - segment.start.x,
				segment.end.y - segment.start.y
			);
			if (length < 1e-4) continue;
			addBox(group, {
				width: length,
				height: WALL_HEIGHT,
				depth: wall.thickness,
				center: {
					x: (segment.start.x + segment.end.x) / 2,
					y: (segment.start.y + segment.end.y) / 2
				},
				y: WALL_HEIGHT / 2,
				rotation,
				color: 0xf8fafc
			});
		}

		for (const opening of openings) {
			const center = pointAlongWall(wall, opening.t);
			if (opening.kind === 'door') {
				addBox(group, {
					width: opening.width,
					height: Math.max(0.1, WALL_HEIGHT - DOOR_HEIGHT),
					depth: wall.thickness,
					center,
					y: (WALL_HEIGHT + DOOR_HEIGHT) / 2,
					rotation,
					color: 0xf8fafc
				});
				addBox(group, {
					width: Math.max(0.1, opening.width - 0.1),
					height: DOOR_HEIGHT - 0.05,
					depth: 0.06,
					center,
					y: (DOOR_HEIGHT - 0.05) / 2,
					rotation,
					color: 0xa16207
				});
			} else {
				addBox(group, {
					width: opening.width,
					height: WINDOW_SILL,
					depth: wall.thickness,
					center,
					y: WINDOW_SILL / 2,
					rotation,
					color: 0xf8fafc
				});
				addBox(group, {
					width: opening.width,
					height: Math.max(0.1, WALL_HEIGHT - WINDOW_SILL - WINDOW_HEIGHT),
					depth: wall.thickness,
					center,
					y: (WALL_HEIGHT + WINDOW_SILL + WINDOW_HEIGHT) / 2,
					rotation,
					color: 0xf8fafc
				});
				addBox(group, {
					width: Math.max(0.1, opening.width - 0.08),
					height: WINDOW_HEIGHT,
					depth: 0.04,
					center,
					y: WINDOW_SILL + WINDOW_HEIGHT / 2,
					rotation,
					color: 0x7dd3fc,
					opacity: 0.45
				});
			}
		}

		register('wall', wall.id, group);
	}

	function addFurniture(item: {
		id: string;
		name: string;
		category: string;
		position: Point;
		size: Point;
		rotation: number;
	}) {
		const height = FURNITURE_HEIGHTS[item.category] ?? 0.5;
		const group = new THREE.Group();
		const color = categoryColor(item.category);
		addBox(group, {
			width: item.size.x,
			height,
			depth: item.size.y,
			center: item.position,
			y: height / 2,
			rotation: item.rotation,
			color
		});
		register('furniture', item.id, group);
	}

	function categoryColor(category: string): number {
		const colors: Record<string, number> = {
			seating: 0xef4444,
			tables: 0x14b8a6,
			beds: 0x3b82f6,
			storage: 0xeab308,
			lighting: 0xd946ef,
			decor: 0x10b981
		};
		return colors[category] ?? 0x64748b;
	}

	function onPointerDown(event: PointerEvent) {
		if (event.button !== 0) return;
		pointerStart = { x: event.clientX, y: event.clientY };
		pointerMoved = false;
	}

	function onPointerMove(event: PointerEvent) {
		if (!pointerStart) return;
		if (Math.hypot(event.clientX - pointerStart.x, event.clientY - pointerStart.y) > 5) {
			pointerMoved = true;
		}
	}

	function onPointerUp(event: PointerEvent) {
		if (!pointerStart) return;
		const moved = pointerMoved;
		pointerStart = null;
		pointerMoved = false;
		if (moved) return;

		const rect = renderer.domElement.getBoundingClientRect();
		const ndc = new THREE.Vector2(
			((event.clientX - rect.left) / Math.max(1, rect.width)) * 2 - 1,
			-(((event.clientY - rect.top) / Math.max(1, rect.height)) * 2 - 1)
		);
		raycaster.setFromCamera(ndc, camera);

		const hits = raycaster.intersectObjects(modelGroup.children, true);
		for (const hit of hits) {
			let object: THREE.Object3D | null = hit.object;
			while (object && !object.userData?.type) object = object.parent;
			if (!object) continue;
			const type = object.userData.type as SelectionType;
			const id = object.userData.id as string;
			if (type && id) {
				selection.set({ type, id });
				return;
			}
		}

		selection.set(null);
	}
</script>

<div bind:this={container} class="absolute inset-0 cursor-grab" />
