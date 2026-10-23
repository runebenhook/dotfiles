# Changelog

All notable changes to this project will be documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)  
Versioning: [Semantic Versioning](https://semver.org/)

---

## [Unreleased]

### Planned

- Lock screen module
- Wallpaper picker UI

---

## [0.4.0] — 2026-06-12

### Added

- `config/Colors.qml` — now dynamic: properties are mutable and auto-reload
  from `~/.cache/wal/colors.json` (mtime polling every 2s, no restart needed)
- `scripts/wal-to-qml.sh` — converts pywal's `colors.json` into a debug/reference
  `config/ColorsWal.qml` snapshot (gitignored, not used at runtime)
- `scripts/wal-gen.sh` — now also exports the debug snapshot via `wal-to-qml.sh`
- `scripts/setup.sh` — added `jq`, `brightnessctl`, `hyprsunset` to dependency lists
- `components/GlowRect.qml` — reusable static glow/halo via `QtQuick.Effects.MultiEffect`
- `components/BlurPanel.qml` — reusable frosted-glass panel background
- `components/PulseGlow.qml` — animated pulsing glow with automatic fallback
  to `GlowRect` if the compiled shader is unavailable
- `assets/shaders/pulseglow.frag` — custom GLSL fragment shader (animated glow ring),
  with `qsb` compilation instructions in the file header
- `components/qmldir` — registered `GlowRect`, `BlurPanel`, `PulseGlow`
- `modules/ControlCenter/CCToggle.qml` — active toggles now show a `PulseGlow` halo
- `modules/ControlCenter/ControlCenter.qml` — background now uses `BlurPanel`
  (frosted glass, tinted with live `Colors.colSurface`)
- `modules/Notifications/NotificationItem.qml` — critical notifications (urgency 2)
  now pulse with a red `PulseGlow`
- `.gitignore` — corrected pattern to `config/ColorsWal.qml` (PascalCase)

### Changed

- All widgets importing `Colors` now receive live palette updates automatically —
  no per-widget changes required

---

## [0.3.0] — 2026-06-12

### Added

- `services/MediaService.qml` — MPRIS media control singleton via `playerctl`
  (status, title, artist, player name; play/pause/next/previous)
- `services/qmldir` — registered `MediaService` singleton
- `modules/Bar/MediaControl.qml` — MPRIS widget (track info + transport controls),
  fully collapses to zero width when no player is active
- `modules/Bar/MCButton.qml` — reusable circular icon button (prev/play-pause/next)
- `modules/Bar/Bar.qml` — wired `MediaControl` between Workspaces and Clock
- README — new "MediaControl" walkthrough sections (FR/EN), updated architecture
  diagrams, dependency tables, and roadmap

---

## [0.2.0] — 2026-06-11

### Added

- `modules/ControlCenter/ControlCenter.qml` — slide-down panel (top-right)
- `modules/ControlCenter/CCToggle.qml` — pill toggle (WiFi, Bluetooth, DND, Night)
- `modules/ControlCenter/CCSlider.qml` — draggable slider (audio, brightness)
- `modules/ControlCenter/CCNetworkInfo.qml` — SSID + local IP display
- `modules/ControlCenter/CCActionButton.qml` — power/reboot/logout actions
- `services/AudioService.qml` — PipeWire volume & mute singleton
- `services/BrightnessService.qml` — backlight control via brightnessctl
- `services/WifiService.qml` — NetworkManager wifi toggle singleton
- `services/BluetoothService.qml` — bluetoothctl power toggle singleton
- `services/NightService.qml` — hyprsunset night mode singleton
- `services/qmldir` — singleton registration for all services
- Bar toggle button to open/close ControlCenter
- `shell.qml` updated to wire ControlCenter ↔ Bar

---

## [0.1.0] — 2026-06-10

### Added

- Initial repository structure
- `shell.qml` — entry point (Bar, OSD, Notifications)
- `modules/Bar` — status bar with Workspaces, Clock, SystemStats
- `modules/OSD` — volume & brightness on-screen display
- `modules/Notifications` — DBus notification toasts
- `config/Colors.qml` — centralized color palette (Catppuccin Macchiato defaults)
- `config/Sizes.qml` — dimensions, spacing, animation durations
- `scripts/setup.sh` — automated install for Arch & Debian
- `scripts/reload.sh` — IPC-first QuickShell reload
- `scripts/wal-gen.sh` — pywal color generation helper
- `scripts/backup.sh` — config backup utility
- `hyprland-layer-config.conf` — layer rules & blur config
- GitHub Actions CI (ShellCheck, markdownlint, qmllint)
- Bilingual README (EN/FR)
