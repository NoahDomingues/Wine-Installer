# Remove Wine wrapper and desktop entry
sudo rm -f /usr/local/bin/wine-wrap.sh
sudo rm -f /usr/share/applications/wine.desktop
sudo update-desktop-database /usr/share/applications || true

# Restore mimeapps.list backup if present
ls -1 /etc/xdg/mimeapps.list.bak*

# Optionally remove wine packages
sudo apt remove --purge -y wine64 wine32 winetricks
sudo apt autoremove -y
