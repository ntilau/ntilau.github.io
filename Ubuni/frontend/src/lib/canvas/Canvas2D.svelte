<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { get } from 'svelte/store';
	import * as THREE from 'three';
	import { design, activeTool, isDrawing, currentPoint, selectedFurniture } from '$lib/store';
	import type { Wall, Point, FurnitureItem } from '$lib/types';

	export let width = 800;
	export let height = 600;

	let scene: THREE.Scene;
	let camera: THREE.OrthographicCamera;
	let renderer: THREE.WebGLRenderer;
	let wallsGroup: THREE.Group;
	let furnitureGroup: THREE.Group;
	let raycaster: THREE.Raycaster;
	let previewLine: THREE.Line | null = null;
	let wallStart: Point | null = null;
	let container: HTMLDivElement;

	const SCALE = 10; // pixels per unit
	const GRID_SIZE = 100;
	const WALL_THICKNESS = 0.15; // 15cm

	onMount(() => {
		container = document.getElementById('canvas-2d') as HTMLDivElement;
		if (!container) return;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0xf0f0f0);

		camera = new THREE.OrthographicCamera(
			width / -SCALE,
			width / SCALE,
			height / SCALE,
			height / -SCALE,
			-1000,
			1000
		);
		camera.position.set(0, 0, 100);

		renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
		renderer.setSize(width, height);
		renderer.setPixelRatio(window.devicePixelRatio);
		container.appendChild(renderer.domElement);

		wallsGroup = new THREE.Group();
		scene.add(wallsGroup);

		furnitureGroup = new THREE.Group();
		scene.add(furnitureGroup);

		raycaster = new THREE.Raycaster();

		// Draw grid
		const gridHelper = new THREE.GridHelper(GRID_SIZE * SCALE, GRID_SIZE, 0xcccccc, 0xeeeeee);
		scene.add(gridHelper);

		// Axes helper
		const axesHelper = new THREE.AxesHelper(50);
		scene.add(axesHelper);

		// Mouse event listeners
		container.addEventListener('mousedown', onMouseDown);
		container.addEventListener('mousemove', onMouseMove);

		// Subscribe to design changes to render walls
		design.subscribe((d) => {
			// Clear existing walls
			while (wallsGroup.children.length > 0) {
				wallsGroup.remove(wallsGroup.children[0]);
			}

			d.walls.forEach((wall) => {
				const geometry = new THREE.BoxGeometry(
					wall.thickness * SCALE,
					3 * SCALE,
					distance(wall.start, wall.end) * SCALE
				);
				const material = new THREE.MeshBasicMaterial({ color: 0x333333 });
				const wallMesh = new THREE.Mesh(geometry, material);

				// Position wall at midpoint
				const midX = (wall.start.x + wall.end.x) / 2;
				const midY = (wall.start.y + wall.end.y) / 2;
				wallMesh.position.set(midX * SCALE, midY * SCALE, 1.5 * SCALE);

				// Rotate wall to align with start-end vector
				const angle = Math.atan2(wall.end.y - wall.start.y, wall.end.x - wall.start.x);
				wallMesh.rotation.z = angle;

				wallsGroup.add(wallMesh);
			});

			// Clear existing furniture
			while (furnitureGroup.children.length > 0) {
				furnitureGroup.remove(furnitureGroup.children[0]);
			}

			d.furniture.forEach((item) => {
				const geometry = new THREE.BoxGeometry(item.size.x / 10, item.size.y / 10, 0.5 * SCALE);
				const material = new THREE.MeshBasicMaterial({ color: 0x4a90e2 });
				const furnitureMesh = new THREE.Mesh(geometry, material);
				furnitureMesh.position.set(item.position.x * SCALE, item.position.y * SCALE, 0.25 * SCALE);
				furnitureMesh.rotation.z = item.rotation;
				furnitureGroup.add(furnitureMesh);
			});
		});

		animate();
	});

	function getWorldCoords(clientX: number, clientY: number): Point {
		const rect = container.getBoundingClientRect();
		const mx = clientX - rect.left;
		const my = clientY - rect.top;

		const ndcX = (mx / rect.width) * 2 - 1;
		const ndcY = 1 - (my / rect.height) * 2;

		return {
			x: ndcX * (width / SCALE),
			y: ndcY * (height / SCALE)
		};
	}

	function snapToGrid(value: number): number {
		return Math.round(value);
	}

	function onMouseDown(e: MouseEvent) {
		const tool = get(activeTool);
		if (tool !== 'wall' && tool !== 'furniture') return;
		if (e.target !== renderer.domElement && e.target !== container) return;

		const point = getWorldCoords(e.clientX, e.clientY);
		const snapped = { x: snapToGrid(point.x), y: snapToGrid(point.y) };

		if (tool === 'furniture') {
			const item = get(selectedFurniture);
			if (!item) return;

			const furniture: FurnitureItem = {
				...item,
				id: crypto.randomUUID(),
				position: snapped,
				rotation: 0
			};

			design.update((d) => ({
				...d,
				furniture: [...d.furniture, furniture],
				updatedAt: new Date()
			}));

			selectedFurniture.set(null);
			activeTool.set('select');
			return;
		}

		if (!wallStart) {
			wallStart = snapped;
			isDrawing.set(true);
			currentPoint.set(snapped);
		} else {
			// Complete the wall
			const wall: Wall = {
				id: crypto.randomUUID(),
				start: wallStart,
				end: snapped,
				thickness: WALL_THICKNESS
			};

			design.update((d) => ({
				...d,
				walls: [...d.walls, wall],
				updatedAt: new Date()
			}));

			wallStart = null;
			isDrawing.set(false);
			currentPoint.set(null);

			// Remove preview
			if (previewLine) {
				scene.remove(previewLine);
				previewLine = null;
			}
		}
	}

	function onMouseMove(e: MouseEvent) {
		if (!wallStart || get(activeTool) !== 'wall') return;

		const point = getWorldCoords(e.clientX, e.clientY);
		const snapped = { x: snapToGrid(point.x), y: snapToGrid(point.y) };
		currentPoint.set(snapped);

		// Update preview line
		if (previewLine) {
			scene.remove(previewLine);
		}

		const geometry = new THREE.BufferGeometry().setFromPoints([
			new THREE.Vector3(wallStart.x * SCALE, wallStart.y * SCALE, 0),
			new THREE.Vector3(snapped.x * SCALE, snapped.y * SCALE, 0)
		]);
		const material = new THREE.LineBasicMaterial({ color: 0x0066ff });
		previewLine = new THREE.Line(geometry, material);
		scene.add(previewLine);
	}

	function animate() {
		requestAnimationFrame(animate);
		renderer.render(scene, camera);
	}

	function distance(a: Point, b: Point) {
		return Math.sqrt(Math.pow(b.x - a.x, 2) + Math.pow(b.y - a.y, 2));
	}

	onDestroy(() => {
		if (container) {
			container.removeEventListener('mousedown', onMouseDown);
			container.removeEventListener('mousemove', onMouseMove);
		}

		if (renderer) {
			renderer.dispose();
		}
	});
</script>

<div
	id="canvas-2d"
	class="w-full h-full bg-gray-100 border border-gray-300 rounded overflow-hidden cursor-crosshair"
	style:width={width + 'px'}
	style:height={height + 'px'}
></div>

<style>
	#canvas-2d canvas {
		display: block;
		width: 100%;
		height: 100%;
	}
</style>
