# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a simple web application for streaming Italian TV channels using HLS.js. The application loads a list of TV channel HLS streams and allows users to navigate between them using keyboard controls (arrow keys, PageUp/PageDown) or touch/swipe gestures. The video plays in fullscreen with an on-screen display showing the current channel name and position.

## Key Files

- `index.html`: Main application file containing HTML, CSS, and JavaScript
- `LICENSE`: MIT license file

## Development Commands

Since this is a static HTML application, there are no build steps required:

- **View the application**: Open `index.html` in any modern web browser
- **Test changes**: Simply reload the browser after saving changes to `index.html`
- **Debugging**: Use browser developer tools to inspect elements, check console logs, and monitor network requests

## Code Structure

The application consists of a single HTML file with embedded CSS and JavaScript:

1. **HTML Structure**: Basic layout with a video element and OSD (On-Screen Display) div
2. **CSS Styling**: Minimal styling for fullscreen video and semi-transparent OSD
3. **JavaScript Logic**:
   - Channel array containing TV station names and HLS stream URLs
   - HLS.js integration for streaming playback
   - Keyboard navigation (arrow keys, PageUp/PageDown)
   - Touch/swipe gesture support for mobile devices
   - Mouse click to unmute, play, and request fullscreen
   - Error handling for failed streams (automatically skips to next channel)

## Common Tasks

### Adding a New Channel
To add a new TV channel:
1. Find the `channels` array in the JavaScript section (around line 30)
2. Add a new object with `name` and `url` properties following the existing format
3. The application will automatically include it in the rotation

### Modifying Appearance
To change the OSD appearance:
1. Modify the CSS rules in the `<style>` section (lines 8-22)
2. Adjust colors, fonts, positioning, or animation timing as needed

### Changing Navigation Behavior
To modify how users navigate between channels:
1. Edit the event listeners in the JavaScript section:
   - Keyboard: lines 357-365 (keydown event)
   - Touch: lines 368-378 (touchstart/touchmove events)
   - Wheel: lines 381-391 (wheel event for horizontal scrolling)
   - Click: lines 393-397 (click to unmute/play/fullscreen)

## Testing

As a static HTML application, testing is done manually:
1. Open `index.html` in a browser
2. Verify that video loads and plays
3. Test keyboard navigation (left/right arrows, PageUp/PageDown)
4. Test touch/swipe gestures on mobile devices or touch-enabled screens
5. Verify that clicking the video unmutes, plays, and requests fullscreen
6. Check that failed streams are automatically skipped

## Dependencies

- [HLS.js](https://github.com/video-dev/hls.js) (loaded via CDN from jsDelivr)
- No build tools or package managers required

## Browser Support

The application works in any modern browser that supports:
- HTML5 video element
- CSS3 transitions and transforms
- Either HLS.js or native HLS playback (Safari)

## Notes

- The application starts in fullscreen mode automatically
- Streams that fail to load are automatically removed from the rotation
- The OSD (On-Screen Display) appears briefly when changing channels
- All TV channel URLs are sourced from public HLS streams