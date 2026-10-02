# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a static web application for streaming TV channels using HLS.js. The application loads M3U8 playlist URLs and allows users to navigate between channels using keyboard controls (arrow keys, PageUp/PageDown) or touch/swipe gestures. Video plays with an on-screen display showing the current channel name and position.

## Key Files

- `index.html`: Contains all HTML, CSS, and JavaScript for the application

## Development Commands

Since this is a static HTML application with no build tools:
- **View the application**: Open `index.html` in any modern web browser
- **Test changes**: Save edits to `index.html` and reload the browser
- **Debugging**: Use browser developer tools (F12) to inspect elements, check console logs, and monitor network requests

## Code Structure

The application consists of a single HTML file with three main sections:

1. **HTML Structure** (lines 25-27):
   - Video element with `id="v"` for playback
   - OSD (On-Screen Display) div with `id="osd"` showing channel info

2. **CSS Styling** (lines 9-23):
   - Fullscreen layout with black background
   - Video styling to fill screen while maintaining aspect ratio
   - Semi-transparent OSD at top with fade-in/out transitions
   - Font styling using system fonts for consistency across platforms

3. **JavaScript Logic** (lines 30-456):
   - **Channel Array** (lines 31-153): Objects containing `name` and `url` properties for each TV channel
   - **HLS.js Integration** (lines 29, 397-409): 
     - Loads HLS.js from jsDelivr CDN
     - Uses HLS.js for browsers that support it (most modern browsers)
     - Falls back to native HLS playback in Safari via `canPlayType`
   - **Navigation System**:
     - Keyboard: Arrow keys and PageUp/PageDown (lines 413-421)
     - Touch/swipe: Horizontal gestures for channel changing (lines 424-434)
     - Mouse wheel: Horizontal scrolling for channel navigation (lines 436-447)
     - Click/tap: Unmutes, plays, and requests fullscreen (lines 449-453)
   - **Playback Functions**:
     - `load(i)`: Loads a channel at index `i`, handles HLS.js or native playback
     - `dropChannel(i)`: Removes failed streams from rotation and advances to next
     - Error handling: Automatically skips to next channel when streams fail
   - **OSD Display**: Shows briefly when changing channels (lines 382-386)

## Common Tasks

### Adding a New Channel
1. Locate the `channels` array (starts around line 31)
2. Add a new object following the format: `{name:"Channel Name",url:"https://example.com/stream.m3u8"}`
3. Save and reload - the channel will be automatically included in navigation

### Modifying OSD Appearance
Edit the CSS rules in the `<style>` section (lines 9-23):
- Adjust `background` property to change OSD transparency/color
- Modify `padding`, `font-size`, or `font-weight` for text appearance
- Change `transition` duration for faster/slower fade effects

### Changing Navigation Behavior
Edit the event listener sections:
- **Keyboard navigation** (lines 413-421): Modify key detection logic
- **Touch gestures** (lines 424-434): Adjust swipe threshold (`100`) or direction logic
- **Mouse wheel** (lines 436-447): Change sensitivity threshold (`200`) or timeout (`150`)
- **Click behavior** (lines 449-453): Modify actions on click/tap

## Testing

As a static HTML application, testing is manual:
1. Open `index.html` in a browser
2. Verify video loads and plays automatically
3. Test keyboard navigation (left/right arrows, PageUp/PageDown)
4. Test touch/swipe gestures on mobile devices or touch screens
5. Verify clicking video unmutes, plays, and attempts fullscreen
6. Test error handling by temporarily breaking a stream URL

## Dependencies

- **[HLS.js](https://github.com/video-dev/hls.js)**: Loaded via CDN from `https://cdn.jsdelivr.net/npm/hls.js@latest`
  - Provides HLS playback support in browsers without native HLS
  - Automatically falls back to native playback in Safari when available
  - No installation required - loaded directly from CDN

## Browser Support

Works in any modern browser that supports:
- HTML5 video element
- CSS3 transitions and transforms
- Either HLS.js playback or native HLS playback (Safari/iOS)

## Important Implementation Notes

1. **Fullscreen Behavior**: 
   - The application attempts to go fullscreen via `video.requestFullscreen()`
   - To support fullscreen on iOS Safari, the `playsinline` attribute is conditionally removed on iOS devices
   - On non-iOS platforms, the `playsinline` attribute is retained to prevent unwanted fullscreen transitions
   - If JavaScript is disabled, the video remains inline on all devices (graceful degradation)

2. **Error Handling**:
   - When a stream fails to load, it's automatically removed from rotation
   - The application advances to the next working channel
   - If all streams fail, displays "All streams failed" message

3. **Performance**:
   - HLS.js instances are properly destroyed before creating new ones (line 388)
   - Video element is reset between channel changes to prevent memory issues

4. **Channel Rotation**:
   - Uses modulo arithmetic to wrap around channel list (line 377)
   - Maintains correct index when channels are removed (lines 363-373)