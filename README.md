# La7 720p - Italian TV Streaming Application

A simple web application for streaming Italian TV channels using HLS.js. This application provides access to various Italian television streams with keyboard, touch, and mouse navigation.

## Features

- Stream multiple Italian TV channels including La7, France 24, Arte, Rai channels, and many more
- Fullscreen video playback with automatic start
- Keyboard navigation (Arrow keys, PageUp/PageDown)
- Touch/swipe gesture support for mobile devices
- Mouse click to unmute, play, and request fullscreen
- On-screen display showing current channel and position in the list
- Automatic removal of failed streams from rotation
- Built with HLS.js for reliable HLS streaming

## Usage

Simply open `index.html` in any modern web browser to start streaming. The application will:

1. Begin playback in fullscreen mode automatically
2. Show an on-screen display with the current channel name and position
3. Allow navigation between channels using:
   - Keyboard: Left/Right arrows or PageUp/PageDown
   - Touch/Swipe: Swipe left or right on touch-enabled devices
   - Mouse: Click on the video to unmute, play, and request fullscreen

## Channel List

The application includes a wide variety of Italian and international channels available in Italy, including:

- National broadcasters (La7, Rai channels, Mediaset channels)
- News channels (France 24, Euronews, TGCom24, etc.)
- Entertainment and lifestyle channels
- Sports channels
- Kids channels
- Regional and local channels
- Religious channels
- International channels available in Italy

## Technical Details

- **Built with**: HTML5, CSS3, JavaScript
- **Streaming technology**: HLS.js (HTTP Live Streaming)
- **Dependencies**: None beyond the browser and HLS.js CDN
- **License**: MIT License

## Development

This is a static HTML application with no build process required:

1. Edit `index.html` to modify the application
2. Save your changes
3. Reload the browser to see the updates

### Adding a New Channel

To add a new TV channel to the rotation:

1. Find the `channels` array in the JavaScript section of `index.html`
2. Add a new object following the existing format:
   ```javascript
   {name:"Channel Name",url:"https://example.com/stream.m3u8"}
   ```
3. Save the file and reload the browser

### Supported Browsers

The application works in any modern browser that supports:
- HTML5 video element
- CSS3 transitions and transforms
- Either HLS.js or native HLS playback (Safari has native HLS support)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This application provides links to publicly available HLS streams. The content is hosted by the respective broadcasters and content providers. This application does not host, distribute, or otherwise make available any copyrighted content beyond providing a convenient interface to access publicly available streams.

---
*Developed with ❤️ for Italian TV enthusiasts*