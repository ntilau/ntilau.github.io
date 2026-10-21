import {
	deleteSelection,
	nudgeSelection,
	placementItem,
	redo,
	rotateSelection,
	selection,
	setTool,
	snapEnabled,
	undo
} from './store';

type KeyOptions = {
	cancel?: () => boolean;
	fit?: () => void;
};

export function isEditableTarget(target: EventTarget | null): boolean {
	const element = target as HTMLElement | null;
	if (!element || !element.tagName) return false;
	const tag = element.tagName.toUpperCase();
	return (
		tag === 'INPUT' ||
		tag === 'TEXTAREA' ||
		tag === 'SELECT' ||
		element.isContentEditable
	);
}

export function handleEditorKeydown(event: KeyboardEvent, options: KeyOptions = {}): void {
	if (isEditableTarget(event.target)) return;

	const modifier = event.metaKey || event.ctrlKey;
	const key = event.key.toLowerCase();

	if (modifier) {
		if (key === 'z') {
			event.preventDefault();
			if (event.shiftKey) redo();
			else undo();
		} else if (key === 'y') {
			event.preventDefault();
			redo();
		}
		return;
	}

	switch (key) {
		case 'v':
			setTool('select');
			break;
		case 'w':
			setTool('wall');
			break;
		case 'm':
			setTool('room');
			break;
		case 'd':
			setTool('door');
			break;
		case 'n':
			setTool('window');
			break;
		case 'f':
			setTool('furniture');
			break;
		case 'h':
			setTool('pan');
			break;
		case 'g':
			snapEnabled.update((enabled) => !enabled);
			break;
		case 'r':
			rotateSelection(event.shiftKey ? -15 : 15);
			break;
		case '0':
			options.fit?.();
			break;
		case 'delete':
		case 'backspace':
			event.preventDefault();
			deleteSelection();
			break;
		case 'escape':
			event.preventDefault();
			if (options.cancel?.()) return;
			placementItem.set(null);
			selection.set(null);
			setTool('select');
			break;
		case 'arrowleft':
			event.preventDefault();
			nudgeSelection(event.shiftKey ? -0.5 : -0.1, 0);
			break;
		case 'arrowright':
			event.preventDefault();
			nudgeSelection(event.shiftKey ? 0.5 : 0.1, 0);
			break;
		case 'arrowup':
			event.preventDefault();
			nudgeSelection(0, event.shiftKey ? 0.5 : 0.1);
			break;
		case 'arrowdown':
			event.preventDefault();
			nudgeSelection(0, event.shiftKey ? -0.5 : -0.1);
			break;
		default:
			break;
	}
}
