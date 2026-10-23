# Installation Guide

## Arch Linux (recommended)

```bash
yay -S quickshell qt6-base qt6-declarative qt6-wayland hyprland \
        python-pywal pipewire wireplumber networkmanager \
        bluez bluez-utils upower grim slurp playerctl
```

## Ubuntu / Debian — compile from source

```bash
# 1. Build dependencies
sudo apt update
sudo apt install -y cmake ninja-build git pkg-config \
  qt6-base-dev qt6-declarative-dev qt6-wayland-dev \
  libwayland-dev wayland-protocols \
  libpipewire-0.3-dev libdbus-1-dev libxkbcommon-dev \
  python3-pywal playerctl grim slurp

# 2. Build QuickShell
git clone https://github.com/quickshell-mirror/quickshell.git /tmp/qs
cmake -B /tmp/qs-build -G Ninja -S /tmp/qs
cmake --build /tmp/qs-build
sudo cmake --install /tmp/qs-build
```

## Manual config deployment

```bash
git clone https://github.com/valorisa/quickshell-hyprland.git ~/.config/quickshell
wal -i ~/wallpaper.jpg
echo "exec-once = quickshell" >> ~/.config/hypr/hyprland.conf
echo "source = ~/.config/quickshell/hyprland-layer-config.conf" >> ~/.config/hypr/hyprland.conf
quickshell
```
