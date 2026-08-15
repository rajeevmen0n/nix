# 🧊 My Nix Configuration

![Build Status](https://github.com/rajeevmen0n/nix/actions/workflows/ga605.yml/badge.svg)

Declarative, reproducible system configuration for personal machines running [NixOS](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager) — optimized for gaming laptops, self-hosted home servers, and daily development.

---

## 💻 Configured Systems

| Host | System Type | Architecture | Role / Hardware Specs |
| :--- | :--- | :--- | :--- |
| **`matrix`** (`ga605wi`) | Asus ROG G16 (GA605WI) | `x86_64-linux` | **Primary Laptop** — Gaming laptop & daily driver workstation |
| **`mainframe`** | Oracle Cloud Free Tier VM | `aarch64` | **Infrastructure Server** — Ampere A1 Compute (4 OCPUs, 24 GB RAM, 90 GB Storage) |

---

## ✨ Features & Architecture

### 🔐 Secrets Management & Security
- **[sops-nix](https://github.com/Mic92/sops-nix)**: Declarative, encrypted secret management via AGE keys (`/etc/ssh/ssh_host_ed25519_key`) integrated into both NixOS system modules and Home Manager.
- **Limine Bootloader**: Modern UEFI bootloader configured with native **Secure Boot** (`limine.secureBoot`) support and automatic Windows dual-boot chainloading.

### 🌐 Server & Infrastructure (`mainframe`)
- **Authelia**: Centralized Single Sign-On (SSO) and OpenID Connect (OIDC) identity provider backed by LLDAP, managing authentication and domain access control policies.
- **LLDAP**: Lightweight LDAP identity provider and user management directory.
- **Headscale & Headplane**: Self-hosted Tailscale control plane with embedded DERP relay and Headplane web dashboard, integrated with Authelia OIDC SSO, API key login, and admin access control.
- **Nginx Reverse Proxy**: Virtual hosting with SSL/TLS termination, WebSocket proxying, and Authelia forward-auth verification for administrative endpoints.
- **Cloudflare DDNS & DNS-01 ACME**: `ddclient` DDNS synchronization across domains and automated Cloudflare DNS-01 ACME wildcard certificate issuance using SOPS secrets.
- **Tailscale & Exit Node**: Automatic node registration and pre-approved default exit node routing (`0.0.0.0/0`, `::/0`) on `mainframe`.
- **Minecraft Server**: Nix-managed server instance powered by [`nix-minecraft`](https://github.com/Infinidoge/nix-minecraft).

### 🎮 Gaming & ROG Hardware Optimizations (`matrix`)
- **DSDT ACPI Patches**: Custom DSDT binary patches and dynamic iGPU PCI path detection to resolve ACPI issues on ROG hardware.
- **Hybrid GPU Switching**: NVIDIA driver integration paired with `supergfxd` and `asusd` for on-demand GPU switching.
- **Display & Audio Handling**: HDR display support under Plasma, `hypr-monitor-toggle` script for dynamic external display switching on lid events, and PipeWire audio tuned with EasyEffects DSP.
- **Gaming Ready**: Steam, Wine/Proton compatibility stack.

### 🖥️ Desktop Environments & Aesthetics
- **Hyprland (Wayland)**:
  - Pywal-based dynamic color generation across system components.
  - SwayNC notification center and control panel.
  - Custom Waybar, Wofi launcher, and custom `hyprlock` screen locker.
  - Idle management via `hypridle` and multi-touch workspace swipe gestures.
- **KDE Plasma 6**:
  - Declarative desktop configuration via [`plasma-manager`](https://github.com/nix-community/plasma-manager).
  - Fluent Dark theme via Kvantum.
- **Display Manager**: `greetd` login manager with asterisks password feedback.

### 🧑‍💻 Development & Tooling
- **Neovim (NVF)**: Modular Neovim configuration built with [`nvf`](https://github.com/notashelf/nvf) (LSP, Treesitter, nvim-cmp, Telescope, Git integration, Trouble).
- **Terminal & Shell**:
  - Declarative `zsh` with Pywal color palette integration.
  - Modern terminal emulators: Ghostty and WezTerm with declarative themes.
  - Development tools: `tmux`, `starship` prompt, `btop`, `fzf`, and `git` (managed via dedicated `git.nix` Home Manager module).
  - VS Code (FHS) and web browsers.

---

## 🧩 Repository Structure

This repository uses a clean, modular Nix Flake layout separating system concerns, host targets, and user environments:

```
.
├── flake.nix              # Main flake entrypoint (NixOS 26.05 + unstable overlays)
├── .sops.yaml             # SOPS encryption keys and path regex rules
├── config/                # Shared metadata & user definitions
│   ├── hosts.nix          # Host definitions (matrix, mainframe)
│   ├── users.nix          # User metadata
│   └── nvim/              # NVF Neovim configuration & plugins
├── hosts/                 # Per-host configurations
│   ├── ga605wi/           # Laptop host (matrix) configuration, DSDT patches & hardware modules
│   └── mainframe/         # Server host (mainframe) configuration, web services & secrets
├── nixos/                 # Modular NixOS system modules
│   ├── desktop/           # Hyprland, Plasma, Greetd display options
│   ├── hardware/          # Audio (PipeWire), AMD GPU, NVIDIA drivers
│   ├── system/            # Limine, SOPS, Podman, Plymouth, HDR
│   ├── gaming.nix         # Gaming utilities and Steam configuration
│   └── server.nix         # Server base configuration
└── home/                  # Home Manager modules
    ├── apps/              # Desktop apps (Ghostty, WezTerm, Media, Minecraft)
    ├── cli/               # Terminal apps (Zsh, Git, Tmux, Starship, Btop, Fzf)
    └── desktop/           # GTK, QT, Hyprland, and Plasma configs
```

---

## 🚀 Usage

### Link Files

Symlink configuration directories to `/etc/nixos` (on NixOS) or `~/.config/home-manager`:

```bash
./install.sh
```

### Rebuild System

Rebuild and switch to the configuration for your host:

```bash
# Laptop host (matrix)
sudo nixos-rebuild switch --flake .#matrix

# Server host (mainframe)
sudo nixos-rebuild switch --flake .#mainframe
```

