# 🧊 My Nix  Configuration

![Build Status](https://github.com/rajeevmen0n/nix/actions/workflows/ga605.yml/badge.svg)

Declarative, reproducible system configuration for my personal machines running [NixOS](https://nixos.org) or [Home Manager](https://github.com/nix-community/home-manager) — optimized for gaming, development, and daily use.


## 💻 Configured Systems

- Asus ROG G16 GA605WI - NixOS

## ✨ Features

### 🖥️ Desktop Environments
- **KDE Plasma 6**
  - Fluent Dark theme via Kvantum
  - Transparent blur using [`kwin-forceblur`](https://github.com/esjeon/kwin-forceblur)

- **Hyprland (Wayland)**
  - Pywal-based dynamic theming
  - Custom Waybar and Wofi configs
  - Swaync for notifications and control center

### 🎮 Gaming Ready
- Steam
- Wine/Proton for Windows compatibility
- Hybrid GPU setup for ROG laptops with Supergfxd for on-demand switching
- Custom-patched ROG/CachyOS kernel

### 🧑‍💻 Development
- **Neovim** with modular NVF-style config:
  - Treesitter, LSP, nvim-cmp, Telescope, Git integrations, etc.
- Terminal tools:
  - `zsh`, `tmux`, `btop`, `fzf`, `starship`
- Custom fonts and prompt theming
- Declarative shell environments via `home-manager`

### 🔐 Secure Boot & Secrets
- Secure Boot with [`lanzaboote`](https://github.com/nix-community/lanzaboote) + `sbctl`

### 💾 System Configuration
- Modular system components:
  - Audio via PipeWire
  - AMD/NVIDIA driver handling
  - Plymouth boot splash
  - Multiple display manager options (GDM, SDDM, greetd)
- System-wide settings broken into logical modules

### 🧩 Nix Flakes + Home Manager
- Flake-powered config with reproducible setup
- Isolated layers for:
  - `nixos/` — system-level modules
  - `home/` — user-facing apps and shell
  - `config/` — shared definitions and themes
- Per-host configuration with override support

### 🧼 Aesthetics & Theming
- Unified GTK and QT theming
- Plasma and Hyprland themed consistently
- Terminal emulators and widgets with declarative color configs
