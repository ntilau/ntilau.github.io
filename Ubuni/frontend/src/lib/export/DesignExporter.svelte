<script lang="ts">
	import { design as designStore, replaceDesign, statusMessage } from '$lib/store';
	import { designFromImport, exportEnvelope } from '$lib/persistence';
	import { designToSvg } from './svg';
	import { downloadBlob, slugify } from './download';
	import { downloadDesignPdf } from './pdf';

	let fileInput: HTMLInputElement;
	let busy = false;

	function exportJson() {
		const current = $designStore;
		downloadBlob(
			JSON.stringify(exportEnvelope(current), null, 2),
			`${slugify(current.name)}.json`,
			'application/json'
		);
		statusMessage.set('Design exported as JSON');
	}

	function exportSvg() {
		const current = $designStore;
		const { svg } = designToSvg(current);
		downloadBlob(svg, `${slugify(current.name)}.svg`, 'image/svg+xml');
		statusMessage.set('Design exported as SVG');
	}

	async function exportPdf() {
		if (busy) return;
		busy = true;
		try {
			await downloadDesignPdf($designStore);
			statusMessage.set('Design exported as PDF');
		} catch (error) {
			statusMessage.set(
				error instanceof Error ? `PDF export failed: ${error.message}` : 'PDF export failed'
			);
		} finally {
			busy = false;
		}
	}

	function openImport() {
		fileInput?.click();
	}

	async function onFileChange(event: Event) {
		const input = event.currentTarget as HTMLInputElement;
		const file = input.files?.[0];
		if (!file) return;

		try {
			const parsed = JSON.parse(await file.text()) as unknown;
			const imported = designFromImport(parsed);
			if (!imported) throw new Error('not a valid Ubuni design file');
			replaceDesign(imported);
			statusMessage.set(`Imported ${imported.name}`);
		} catch (error) {
			statusMessage.set(
				error instanceof Error ? `Import failed: ${error.message}` : 'Import failed'
			);
		} finally {
			input.value = '';
		}
	}
</script>

<div class="absolute bottom-3 right-3 z-10 flex flex-wrap items-center gap-1 rounded-lg border border-slate-200 bg-white/95 p-1 shadow-lg backdrop-blur">
	<button
		type="button"
		class="rounded px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100"
		on:click={openImport}
		title="Import a Ubuni JSON design"
	>
		Import
	</button>
	<span class="h-4 w-px bg-slate-200" />
	<button
		type="button"
		class="rounded px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100"
		on:click={exportJson}
		title="Download the design as JSON"
	>
		JSON
	</button>
	<button
		type="button"
		class="rounded px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100"
		on:click={exportSvg}
		title="Download a vector SVG plan"
	>
		SVG
	</button>
	<button
		type="button"
		class="rounded px-2.5 py-1.5 text-xs font-medium text-slate-600 hover:bg-slate-100 disabled:opacity-50"
		on:click={exportPdf}
		disabled={busy}
		title="Download a vector PDF plan"
	>
		{busy ? 'PDF…' : 'PDF'}
	</button>
	<input
		bind:this={fileInput}
		type="file"
		accept="application/json,.json"
		class="hidden"
		on:change={onFileChange}
	/>
</div>
