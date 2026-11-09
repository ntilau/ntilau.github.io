# Snippets

Copy-paste shell scripts for macOS setup and utilities. Each script is self-contained: save it to a file and run it, or use the curl-to-bash pattern if preferred.

> **Safety:** several snippets below are destructive (they reset system preferences, change network configuration, create users, or edit boot config). Review a script before running it, and never commit real API keys or passwords.

## Contents

- [MacOS Dock](#macos-dock)
- [MacOS HotPlug disable](#macos-hotplug-disable)
- [Safari Custom User Agent](#safari-custom-user-agent)
- [Homebrew defaults](#homebrew-defaults)
- [Spoof a MAC address](#spoof-a-mac-address)
- [File exchange](#file-exchange)
- [Integrate DeepSeek with Claude Code](#integrate-deepseek-with-claude-code)
- [Linux Setup Utilities](#linux-setup-utilities)
- [Screen Mirror via scrcpy](#screen-mirror-via-scrcpy)
- [Serve Runinga locally](#serve-raininga-locally)

## MacOS Dock

Reset Mac Dock to its original factory layout and default settings. This kills and restarts the Dock.

```sh
defaults delete com.apple.dock; killall Dock
```

## MacOS HotPlug disable

Disable Image Capture's "HotPlug" behavior so connected cameras don't auto-launch imports.

```sh
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES
```

Remove the setting:

```sh
defaults delete com.apple.Safari CustomUserAgent
```

## Safari Custom User Agent

Set Safari's user agent to appear as Chrome on Linux.

```sh
USER_AGENT="'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.8059.39 Safari/537.36'"
defaults write com.apple.Safari CustomUserAgent $USER_AGENT
```

Remove the custom setting:

```sh
defaults delete com.apple.Safari CustomUserAgent
```

## Homebrew defaults

Installs Homebrew, adds it to `PATH`, and sets up a standard set of packages.

```sh
## central installer
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## add to path
grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile

## default installation
brew install git gh sevenzip tree
brew install --cask claude-code

# cleaning up temp repositories
brew cleanup --prune=all
```

Installs: `git`, `gh`, `sevenzip`, `tree`, Claude Code.

## Spoof a MAC address

Spoofs a network interface's MAC address and bounces the interface up/down so the change takes effect. Requires `sudo`.

Usage:

```sh
# ./mac-spoof.sh <interface> <mac>
sudo ./mac-spoof.sh "$INTERFACE" "$MAC"
```

```sh
#!/bin/zsh
if [ "$#" -ne 2 ]; then
  echo "usage: $0 <interface> <mac>" >&2
  exit 1
fi

if=$1
mac=$2
a=${mac//:/}
sudo ifconfig "$if" ether "${a:0:2}:${a:2:2}:${a:4:2}:${a:6:2}:${a:8:2}:${a:10:2}"
sudo ifconfig "$if" down
sudo ifconfig "$if" up
```

Use `en0` for Wi-Fi on modern Macs; check interface names with `networksetup -listallhardwareports`.

## File exchange

P2P file sharing directly between devices — no upload, no server.

```sh
open https://neardrop.me/
```

## Integrate DeepSeek with Claude Code

Add this to your `~/.bash_aliases` or `~/.zshrc`. Replace the placeholder values with real ones before sourcing, and never commit a file containing actual keys.

```sh
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-your-real-token
export ANTHROPIC_MODEL=deepseek-v4-flash
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
```

## Linux Setup Utilities

Installs Google Chrome, configures RTC to local time, adds a sudo user, and disables the GRUB OS probe.

**Warning:** this script is destructive — it sets a user password, edits `/etc/default/grub`, and runs `update-grub`. It is intended for Debian/Ubuntu systems only. Review before running.

```sh
wget -P /tmp/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install /tmp/google-chrome-stable_current_amd64.deb -y

timedatectl set-local-rtc 1 --adjust-system-clock

sudo apt install ecryptfs-utils -y
# set ADMIN_USER and ADMIN_PASS before running, or run useradd interactively
useradd -m -g sudo "$ADMIN_USER"
echo "$ADMIN_USER:$ADMIN_PASS" | sudo chpasswd

sudo sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
sudo update-grub
```

## Screen Mirror via scrcpy

Installs scrcpy and Android platform tools via Homebrew, connects to the default gateway, and launches screen mirroring.

```sh
brew install --cask android-platform-tools
brew install scrcpy
adb connect "$(route -n get default | grep gateway | awk '{print $2}')"
scrcpy -Swe
```

Requires an Android device with USB debugging enabled or connected over the network.

## Serve Runinga locally

Serve this repository's root so the Runinga app at `index.html` can be tested in a browser.

```sh
python3 -m http.server 8080
# http://localhost:8080/
```

Save edits to `index.html` and reload; debug with browser dev tools (F12). Port 8080 can be changed if it is already in use.
