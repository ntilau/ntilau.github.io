<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { get } from 'svelte/store';
	import * as THREE from 'three';
	import { design } from '$lib/store';
	import type { Wall, Point, FurnitureItem } from '$lib/types';

	export let width = 800;
	export let height = 600;

	let scene: THREE.Scene;
	let camera: THREE.PerspectiveCamera;
	let renderer: THREE.WebGLRenderer;
	let wallsGroup: THREE.Group;
	let furnitureGroup: THREE.Group;
	let container: HTMLDivElement;

	const WALL_HEIGHT = 3; // 3 meters

	onMount(() => {
		container = document.getElementById('canvas-3d') as HTMLDivElement;
		if (!container) return;

		scene = new THREE.Scene();
		scene.background = new THREE.Color(0x87ceeb); // Sky blue
		scene.fog = new THREE.Fog(0x87ceeb, 1, 1000);

		camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
		camera.position.set(10, 10, 10);
		camera.lookAt(0, 0, 0);

		renderer = new THREE.WebGLRenderer({ antialias: true });
		renderer.setSize(width, height);
		renderer.setPixelRatio(window.devicePixelRatio);
		renderer.shadowMap.enabled = true;
		container.appendChild(renderer.domElement);

		// Lights
		const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
		scene.add(ambientLight);

		const dirLight = new THREE.DirectionalLight(0xffffff, 0.8);
		dirLight.position.set(10, 20, 10);
		dirLight.castShadow = true;
		scene.add(dirLight);

		// Floor
		const floorGeometry = new THREE.PlaneGeometry(100, 100);
		const floorMaterial = new THREE.MeshStandardMaterial({ color: 0xe0e0e0 });
		const floor = new THREE.Mesh(floorGeometry, floorMaterial);
		floor.rotation.x = -Math.PI / 2;
		floor.receiveShadow = true;
		scene.add(floor);

		wallsGroup = new THREE.Group();
		scene.add(wallsGroup);

		furnitureGroup = new THREE.Group();
		scene.add(furnitureGroup);

		// Subscribe to design changes
		design.subscribe((d) => {
			renderWalls(d.walls);
			renderFurniture(d.furniture);
		});

		animate();
	});

	function renderWalls(walls: Wall[]) {
		// Clear existing walls
		while (wallsGroup.children.length > 0) {
			wallsGroup.remove(wallsGroup.children[0]);
		}

		walls.forEach((wall) => {
			const length = Math.sqrt(
				Math.pow(wall.end.x - wall.start.x, 2) +
				Math.pow(wall.end.y - wall.start.y, 2)
			);
			const geometry = new THREE.BoxGeometry(wall.thickness, WALL_HEIGHT, length);
			const material = new THREE.MeshStandardMaterial({ color: 0x555555 });
			const wallMesh = new THREE.Mesh(geometry, material);
			wallMesh.castShadow = true;
			wallMesh.receiveShadow = true;

			// Position wall at midpoint
			const midX = (wall.start.x + wall.end.x) / 2;
			const midY = (wall.start.y + wall.end.y) / 2;
			wallMesh.position.set(midX, WALL_HEIGHT / 2, -midY);

			// Rotate wall to align with start-end vector
			// In 3D, walls lie on the XZ plane, Y is up
			const angle = Math.atan2(wall.end.x - wall.start.x, wall.end.y - wall.start.y);
			wallMesh.rotation.y = angle;

			wallsGroup.add(wallMesh);
		});
	}

	function renderFurniture(furniture: FurnitureItem[]) {
		// Clear existing furniture
		while (furnitureGroup.children.length > 0) {
			furnitureGroup.remove(furnitureGroup.children[0]);
		}

		const categoryColors: Record<string, number> = {
			seating: 0xff6b6b,
			tables: 0x4ecdc4,
			beds: 0x45b7d1,
			storage: 0xf9c74f,
			lighting: 0xff9ff3,
			decor: 0x98d8c8
		};

		furniture.forEach((item) => {
			const geometry = new THREE.BoxGeometry(item.size.x / 100, WALL_HEIGHT / 4, item.size.y / 100);
			const color = categoryColors[item.category] || 0xcccccc;
			const material = new THREE.MeshStandardMaterial({ color });
			const mesh = new THREE.Mesh(geometry, material);
			mesh.castShadow = true;
			mesh.receiveShadow = true;

			// Position furniture (convert cm to meters, Y is up, Z is depth)
			mesh.position.set(item.position.x / 100, 0, -item.position.y / 100);
			mesh.rotation.y = item.rotation;

			furnitureGroup.add(mesh);
		});
	}

	function animate() {
		requestAnimationFrame(animate);
		renderer.render(scene, camera);
	}

	onDestroy(() => {
		if (container && renderer.domElement) {
			container.removeChild(renderer.domElement);
		}

		if (renderer) {
			renderer.dispose();
		}
	});
</script>

<div
	id="canvas-3d"
	class="w-full h-full bg-gradient-to-b from-blue-200 to-blue-400 rounded overflow-hidden"
	style:width={width + 'px'}
	style:height={height + 'px'}
></div>

<style>
	#canvas-3d canvas {
		display: block;
		width: 100%;
		height: 100%;
	}
</style>
