# TV Streaming Application

![GitHub](https://img.shields.io/github/license/ntilau/ntilau.github.io)
![GitHub Repo Size](https://img.shields.io/github/repo-size/ntilau/ntilau.github.io)
![GitHub last commit](https://img.shields.io/github/last-commit/ntilau/ntilau.github.io)

Discover a seamless way to watch live TV streams from around the world. This lightweight web application leverages HLS.js to deliver reliable streaming with instant fullscreen playback and intuitive navigation across devices.

## 📺 Features

- **Multiple TV Channels**: Stream channels from various countries and genres
- **Instant Fullscreen**: Automatic fullscreen playback on launch
- **Intuitive Navigation**: 
  - Keyboard: Arrow keys, PageUp/PageDown
  - Touch/Swipe: Natural gestures on mobile devices
  - Mouse: Click to unmute, play, and request fullscreen
- **Smart OSD**: On-screen display showing current channel and position in list
- **Resilient Streaming**: Automatic removal of failed streams from rotation
- **Modern Technology**: Built with HLS.js for reliable HLS streaming
- **Zero Dependencies**: No build tools or package managers required

## 🚀 Usage

1. Simply open `index.html` in any modern web browser
2. The application begins playback in fullscreen mode automatically
3. An on-screen display shows the current channel name and position
4. Navigate between channels using:
   - **Keyboard**: Left/Right arrows or PageUp/PageDown
   - **Touch/Swipe**: Swipe left or right on touch-enabled devices
   - **Mouse**: Click on the video to unmute, play, and request fullscreen

## 📋 Channel Categories

The application includes a diverse selection of channels from various regions and categories:

- **News Channels**: International news networks
- **Entertainment & Lifestyle**: Various entertainment and lifestyle channels
- **Sports**: Sports channels
- **Kids**: Children's programming
- **Regional & Local**: Regional and local channels
- **Religious**: Religious channels
- **Educational**: Educational and documentary channels
- **Music**: Music channels
- **Government**: Government and parliamentary channels

## ⚙️ Technical Details

- **Built with**: HTML5, CSS3, JavaScript
- **Streaming technology**: HLS.js (HTTP Live Streaming)
- **Dependencies**: Browser only + HLS.js from jsDelivr CDN
- **License**: MIT License
- **Browser Support**: Any modern browser supporting HTML5 video and CSS3 transforms

## 🔧 Development

This is a static HTML application requiring zero build process:

1. Edit `index.html` to modify the application
2. Save your changes
3. Reload the browser to see updates

### Adding a New Channel

To add a TV channel to the rotation:

1. Locate the `channels` array in `index.html`'s JavaScript section
2. Add a new object following the existing format:
   ```javascript
   {name: "Channel Name", url: "https://example.com/stream.m3u8"}
   ```
3. Save the file and refresh your browser

### Supported Browsers

Works in any modern browser that supports:
- HTML5 video element
- CSS3 transitions and transforms
- Either HLS.js or native HLS playback (Safari has native HLS support)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This application provides links to publicly available HLS streams. The content is hosted by respective broadcasters and content providers. This application does not host, distribute, or make available any copyrighted content beyond providing a convenient interface to access publicly available streams.

---

*Developed with ❤️ for TV enthusiasts*