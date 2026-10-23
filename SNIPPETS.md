# Snippets

Copy-paste shell scripts for macOS setup and utilities. Each script is presented here as a self-contained block; you can save it to a file and run it, or use the curl-to-bash pattern if preferred.

## Scripts

### MacOS Dock

Reset Mac Dock to its original factory layout and default settings

```sh
defaults delete com.apple.dock; killall Dock
```

### MacOS HotPlug disable

```sh
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool YES
```

### Safari Custom User Agent

Set as Chrome on Linux

```sh
USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.8059.39 Safari/537.36'
defaults write com.apple.Safari CustomUserAgent \'$USER_AGENT\'
```

Remove custom setting

```sh
defaults delete com.apple.Safari CustomUserAgent
```

### Homebrew defaults

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

### Screen mirror

Installs `scrcpy` and `adb`, connects to a Samsung device over the local network, and launches screen mirroring.

```sh
#if=$1
#mac=$2
if=en5
mac=cc:96:e5:d8:47:98
a=${mac//:}
sudo ifconfig $if ether ${a:0:2}:${a:2:2}:${a:4:2}:${a:6:2}:${a:8:2}:${a:10:2}
sudo ifconfig $if down
sudo ifconfig $if up
```

Requires USB debugging already enabled on the Android device.

The `_` is a placeholder for `$0` — the script reads the interface and MAC from `$1` and `$2`. Use `en0` for Wi-Fi on modern Macs; check with `networksetup -listallhardwareports` if unsure.

### File exchange

P2P file sharing directly between devices — no upload, no server.

```sh
open https://neardrop.me/
```

### Integrate DeepSeek with Claude Code

Add this to your ~/.bash_aliases or ~/.zshrc

```sh
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-***
export ANTHROPIC_MODEL=deepseek-v4-flash
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
```

### Linux Setup Utilities

Installs Google Chrome, configures RTC to use local time, adds a sudo user, and disables OS probe in GRUB.

```sh
wget -P /tmp/ https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install /tmp/google-chrome-stable_current_amd64.deb -y

timedatectl set-local-rtc 1 --adjust-system-clock

sudo apt install ecryptfs-utils -y
useradd -m -g sudo -p t3st admin

#sudo pkill -u admin
#sudo deluser --remove-home admin
#sudo apt install smbclient cifs-utils -y

sudo sed -i 's/\#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
sudo update-grub
```

Note: This script is intended for Linux systems (Debian/Ubuntu). Review the script before running.

### Screen Mirror via scrcpy

Installs scrcpy and Android platform tools via Homebrew, connects to the default gateway, and launches screen mirroring.

```sh
brew install --cask android-platform-tools
brew install scrcpy
adb connect `route -n get default | grep gateway | awk '{print $2}'`
scrcpy -Swe
```

Requires Android device with USB debugging enabled or connected over network.
