# Wine Installer

A simple Linux installation script for Wine. Also enables launching .exe executables using the right-click context menu. 🍷

## 📥 Installation

> [!IMPORTANT]
>
> The installation script will only install `wine` and `winetricks` _if they are not already installed._ If one or both programs are already installed, the script will continue with the remaining actions.

### 🖱 GUI

- Download the latest release from the [**Releases**](https://github.com/NoahDomingues/Wine-Installer) section
- Unzip the downloaded archive
- Right-click `wine-installer.sh` and click **Run**
- Enter the root password when prompted

### ⌨ Command line

- Download the latest release:

  ```
  set -euo pipefail
  
  # Download latest release tag
  LATEST_TAG=$(curl -s "https://api.github.com/repos/NoahDomingues/Wine-Installer/releases/latest" \
    | grep -Po '"tag_name":\s*"\K(.*?)(?=")')

  # Download, extract, enter folder, make installer executable and run it
  curl -L -o release.zip "https://github.com/NoahDomingues/Wine-Installer/archive/refs/tags/${LATEST_TAG}.zip"
  ```
- Unzip the downloaded archive:

  ```
  unzip -q release.zip
  ```
- Make the script executable and run it:

  ```
  cd "Wine-Installer-${LATEST_TAG}"
  chmod +x install-wine-handler.sh
  ./install-wine-handler.sh
  ```

## ❌ Uninstallation

Run `wine-uninstaller.sh` or run the following commands to revert all changes made by **Wine Installer** and remove Wine from your system:

```
# Remove Wine wrapper and desktop entry
sudo rm -f /usr/local/bin/wine-wrap.sh
sudo rm -f /usr/share/applications/wine.desktop
sudo update-desktop-database /usr/share/applications || true

# Restore mimeapps.list backup if present
ls -1 /etc/xdg/mimeapps.list.bak*

# Optionally remove wine packages
sudo apt remove --purge -y wine64 wine32 winetricks
sudo apt autoremove -y
```

---

> [!CAUTION]
>
> In order to install right-click context menu launching, the installer script needs to create a system-wide desktop entry for Wine and install a wrapper script. In order to do this, the script requires superuser (`sudo`) permissions. When running the installer via GUI, your system should prompt you to enter the superuser password; however, if this does not happen, open a terminal and run the script using the command `sudo ./wine-installer.sh`. 

> [!NOTE]
>
> **Wine Installer** runs the following actions:
>
> - Installs Wine
> - Installs Winetricks (Wine manager)
> - Sets up `wine` (`winecfg`)
> - Enables launching `.exe` executables using the Files right-click context menu (GUI launching)
>
> The log file `wine-launch.log` for GUI kaunching will be available in the `~/.cache` directory.

## 🤝 Support

If you run into issues or want to contribute, check out my **[Discord server](https://discord.gg/3zbfaTNN7V)** or open a GitHub issue! Contributions, feature suggestions, and pull requests are always welcome.

[<img src="https://github.com/user-attachments/assets/f61046f5-1dc5-4b0c-87f8-4a94d6cbac96">](https://discord.gg/3zbfaTNN7V)

## 👥 Contributors

[![Contributors][contributors-image]][contributors-link]

[contributors-image]: https://contrib.rocks/image?repo=NoahDomingues/Wine-Installer
[contributors-link]: https://github.com/NoahDomingues/Wine-Installer/graphs/contributors

**⭐ If this tool was of any use to you, please consider giving it a Star - it would make my day! ⭐**

[<img src="https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white">](https://discord.gg/3zbfaTNN7V)

<div align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&height=100&section=footer" />
</div>
