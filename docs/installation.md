# NixOS Installation Guide

This guide walks you through installing NixOS using this flake-based configuration with disko for declarative disk partitioning and optional LUKS encryption.

## Prerequisites

- NixOS installation ISO (download from [nixos.org](https://nixos.org/download.html))
- USB drive (for bootable media)
- Your disk device name (e.g., `/dev/nvme0n1`, `/dev/sda`)

---

## Installation Steps

### 1. Boot NixOS Installation Media

Boot from the NixOS ISO (minimal or graphical).

### 2. Connect to Network

```bash
# For WiFi
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YourSSID"
> set_network 0 psk "YourPassword"
> enable_network 0
> quit

# Verify connection
ping -c 3 nixos.org
```

### 3. Identify Your Disk

```bash
lsblk
```

Note your target disk (e.g., `/dev/nvme0n1`, `/dev/sda`, `/dev/vda` for VMs).

### 4. Clone This Configuration

> **Note:** Throughout this guide, replace `<username>` with the value of `username` in `variables.nix`.

```bash
# Enable flakes
export NIX_CONFIG="experimental-features = nix-command flakes"

# Clone the configuration to the user's home directory
nix-shell -p git
sudo mkdir -p /mnt/home/<username>
sudo git clone https://github.com/JckL16/nixos-config.git /mnt/home/<username>/nixos-config
```

### 5. Set Up Your Host

#### Option A: Use an Existing Host

If reinstalling an existing host (e.g., `nixos-laptop`), uncomment and verify the diskoConfig:

```bash
sudo nano /mnt/home/<username>/nixos-config/hosts/<hostname>/configuration.nix
```

1. Uncomment the `diskoConfig` block
2. Verify `diskoConfig.device` matches your disk from `lsblk`

#### Option B: Create a New Host

Copy the example host:

```bash
sudo cp -r /mnt/home/<username>/nixos-config/hosts/nixos-example /mnt/home/<username>/nixos-config/hosts/<your-hostname>
```

Edit the configuration:

```bash
sudo nano /mnt/home/<username>/nixos-config/hosts/<your-hostname>/configuration.nix
```

Update:
- `diskoConfig.device` - Set to your disk device
- `diskoConfig.isBIOS` - Set to `true` for BIOS systems
- `networking.hostName` - Set to your hostname
- Enable desired modules (graphics drivers, desktop environment, etc.)

Then register the host in `flake.nix` (see step 8).

### 6. Run Disko

This partitions and formats your disk. **All data on the disk will be erased!**

```bash
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake /mnt/home/<username>/nixos-config#<hostname>
```

When prompted, enter your LUKS encryption password twice. **Remember this password** - you'll need it on every boot.

### 7. Restore Config and Generate Hardware Configuration

After disko mounts the new filesystem, restore the config and generate hardware config:

```bash
# Move config back to mounted filesystem
sudo mkdir -p /mnt/home/<username>
sudo mv /tmp/nixos-config /mnt/home/<username>/nixos-config 2>/dev/null || true

# If config was lost, re-clone it
if [ ! -d /mnt/home/<username>/nixos-config ]; then
  sudo git clone https://github.com/JckL16/nixos-config.git /mnt/home/<username>/nixos-config
fi

# Generate hardware config
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/<username>/nixos-config/hosts/<hostname>/hardware-configuration.nix

# Set correct ownership (replace 1000:1000 with your uid:gid if different)
sudo chown -R 1000:1000 /mnt/home/<username>/nixos-config
```

### 8. Register New Host in flake.nix (New Hosts Only)

If creating a new host, add an entry to `flake.nix`:

```bash
sudo nano /mnt/home/<username>/nixos-config/flake.nix
```

Add a new nixosConfigurations entry:

```nix
nixosConfigurations.<your-hostname> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit self home-manager inputs;
    variables = import ./variables.nix;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  };
  modules = [
    disko.nixosModules.disko
    ./hosts/<your-hostname>/hardware-configuration.nix
    ./hosts/<your-hostname>/configuration.nix
    ./modules/nixos
    home-manager.nixosModules.home-manager
  ];
};
```

### 9. Edit variables.nix (New Hosts Only)

Update global variables to match your setup:

```bash
sudo nano /mnt/home/<username>/nixos-config/variables.nix
```

Set your username, timezone, locale, keyboard layout, and git credentials.

### 10. Install NixOS

```bash
sudo nixos-install --root /mnt --flake /mnt/home/<username>/nixos-config#<hostname>
```

You'll be prompted to set the root password.

### 11. Reboot

```bash
sudo reboot
```

Remove the installation media when prompted. On boot, you'll be prompted for your LUKS encryption password.

---

## Post-Installation

### 12. Login as Your User

Login with:
- **Username:** The `username` value from `variables.nix`
- **Password:** `nixos` (initial password - change it immediately!)

```bash
passwd  # Change your password
```

### 13. Verify Config Location

Your config should already be in your home directory:

```bash
ls ~/nixos-config
```

Future rebuilds:

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#<hostname>
```

---

## Quick Reference

Complete installation commands for an existing host (replace `<username>` and `<hostname>`):

```bash
# 1. Set up environment
export NIX_CONFIG="experimental-features = nix-command flakes"

# 2. Clone config to user's home directory
nix-shell -p git
sudo mkdir -p /mnt/home/<username>
sudo git clone https://github.com/JckL16/nixos-config.git /mnt/home/<username>/nixos-config

# 3. Run disko (enter LUKS password when prompted)
sudo nix run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake /mnt/home/<username>/nixos-config#<hostname>

# 4. Restore config and generate hardware config
sudo mkdir -p /mnt/home/<username>
sudo git clone https://github.com/JckL16/nixos-config.git /mnt/home/<username>/nixos-config
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/<username>/nixos-config/hosts/<hostname>/hardware-configuration.nix
sudo chown -R 1000:1000 /mnt/home/<username>

# 5. Install
sudo nixos-install --root /mnt --flake /mnt/home/<username>/nixos-config#<hostname>

# 6. Reboot
sudo reboot

# 7. After reboot, login as your user (password: nixos) and change password
passwd
```

---

## Disko Configuration Options

Each host's `configuration.nix` includes a `diskoConfig` block:

```nix
diskoConfig = {
  enable = true;
  device = "/dev/nvme0n1";     # Your disk device
  encryption.enable = true;    # LUKS encryption
  swapSize = "16G";            # Swap partition size (optional)
  isBIOS = false;              # Set true for BIOS/MBR systems
};
```

| Option | Description |
|--------|-------------|
| `device` | Disk device path (from `lsblk`) |
| `encryption.enable` | Enable LUKS encryption |
| `swapSize` | Swap partition size (e.g., "8G", "16G"), omit for no swap |
| `isBIOS` | Use BIOS/MBR instead of UEFI/GPT |

---

## LUKS Encryption Notes

- **Password is never stored** - you must remember it
- **Prompted on every boot** - enter password to decrypt disk
- **Cannot be added later** - requires reinstall to enable encryption

## User Account Notes

- **Username:** Defined in `variables.nix` as `username`
- **Initial password:** `nixos` - change immediately after first login with `passwd`
- **Root password:** Set during `nixos-install`
- The user account and home directory are created automatically based on `variables.nix`
