sudo rm -f /usr/local/bin/wine-wrap.sh
sudo rm -f /usr/share/applications/wine.desktop
sudo update-desktop-database /usr/share/applications || true
# restore mimeapps.list backup if present
ls -1 /etc/xdg/mimeapps.list.bak*
# optionally remove wine packages
sudo apt remove --purge -y wine64 wine32 winetricks
sudo apt autoremove -y
