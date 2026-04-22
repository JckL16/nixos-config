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

### 4. Set Up Environment

```bash
# Set your username (must match 'username' in variables.nix)
export USER_NAME="jack"

# Set your hostname (must match a host in hosts/ directory)
export HOST_NAME="nixos-desktop"
```

### 5. Clone This Configuration

```bash
nix-shell -p git --run "git clone https://github.com/JckL16/nixos-config.git /tmp/nixos-config"
```

### 6. Set Up Your Host

#### Option A: Use an Existing Host

If reinstalling an existing host (e.g., `nixos-laptop`), verify the diskoConfig:

```bash
nano /tmp/nixos-config/hosts/$HOST_NAME/configuration.nix
```

1. Ensure `diskoConfig.enable = true`
2. Verify `diskoConfig.device` matches your disk from `lsblk`

#### Option B: Create a New Host

Copy the example host:

```bash
cp -r /tmp/nixos-config/hosts/nixos-example /tmp/nixos-config/hosts/<your-hostname>
```

Edit the configuration:

```bash
nano /tmp/nixos-config/hosts/<your-hostname>/configuration.nix
```

Update:
- `diskoConfig.device` - Set to your disk device
- `networking.hostName` - Set to your hostname
- Enable desired modules (graphics drivers, desktop environment, etc.)

Then register the host in `flake.nix` (see step 9). For BIOS systems, set `isBIOS = true` in flake.nix (see step 9).

### 7. Run Disko

This partitions and formats your disk. **All data on the disk will be erased!**

#### With encryption (diskoConfig.encryption.enable = true):

```bash
# Write your LUKS password to a file (visible, so you can verify it's correct)
echo -n "your-password-here" > /tmp/secret.key

# Partition and format disk
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake /tmp/nixos-config#$HOST_NAME
```

**Remember this password** - you'll need it on every boot.

#### Without encryption (diskoConfig.encryption.enable = false):

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake /tmp/nixos-config#$HOST_NAME
```

### 8. Copy Config and Generate Hardware Configuration

After disko mounts the new filesystem at `/mnt`, copy the config and generate hardware config:

```bash
# Copy config to user's home directory on mounted filesystem
sudo mkdir -p /mnt/home/$USER_NAME
sudo cp -r /tmp/nixos-config /mnt/home/$USER_NAME/nixos-config

# Generate hardware config
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/$USER_NAME/nixos-config/hosts/$HOST_NAME/hardware-configuration.nix

# Set correct ownership (replace 1000:1000 with your uid:gid if different)
sudo chown -R 1000:1000 /mnt/home/$USER_NAME
```

### 9. Register New Host in flake.nix (New Hosts Only)

If creating a new host, add an entry to `flake.nix`:

```bash
sudo nano /mnt/home/$USER_NAME/nixos-config/flake.nix
```

Add a new nixosConfigurations entry:

```nix
nixosConfigurations.<your-hostname> = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit self home-manager inputs;
    # For BIOS systems, add: // { isBIOS = true; bootDevice = "/dev/sda"; }
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

For BIOS/legacy boot systems, override variables:

```nix
variables = (import ./variables.nix) // {
  isBIOS = true;
  bootDevice = "/dev/sda";  # Your boot disk
};
```

### 10. Edit variables.nix (New Hosts Only)

Update global variables to match your setup:

```bash
sudo nano /mnt/home/$USER_NAME/nixos-config/variables.nix
```

Set your username, timezone, locale, keyboard layout, and git credentials.

### 11. Install NixOS

The live ISO runs entirely in RAM, so larger configurations can run out of memory. Create a temporary swapfile on the target disk and bind-mount `/tmp`:

```bash
# Bind-mount /tmp to target disk
sudo mkdir -p /mnt/tmp
sudo mount --bind /mnt/tmp /tmp

# Create 8GB temporary swapfile
sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192 status=progress
sudo chmod 600 /mnt/swapfile
sudo mkswap /mnt/swapfile
sudo swapon /mnt/swapfile

# Install NixOS (--max-jobs 1 reduces peak memory usage)
sudo NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-install --root /mnt --max-jobs 1 \
  --flake /mnt/home/$USER_NAME/nixos-config#$HOST_NAME

# Clean up temporary swapfile
sudo swapoff /mnt/swapfile
sudo rm /mnt/swapfile
```

You'll be prompted to set the root password.

### 12. Reboot

```bash
sudo reboot
```

Remove the installation media when prompted. On boot, you'll be prompted for your LUKS encryption password.

---

## Post-Installation

### 13. Login as Your User

Login with:
- **Username:** The `username` value from `variables.nix`
- **Password:** `nixos` (initial password - change it immediately!)

```bash
passwd  # Change your password
```

### 14. Verify Config Location

Your config should already be in your home directory:

```bash
ls ~/nixos-config
```

Future rebuilds use the shell aliases defined in `zsh.nix`:

| Alias | Command |
|-------|---------|
| `switch` | Rebuild and switch to new configuration |
| `test` | Test configuration without switching |
| `dry-run` | Show what would be built |
| `update` | Update flake inputs and rebuild |
| `clean` | Run garbage collection |
| `install-bootloader` | Reinstall bootloader |

```bash
switch    # Apply changes
update    # Update flake inputs and apply
```

---

## Quick Reference

Complete installation commands for an existing host (set `USER_NAME` and replace `$HOST_NAME`):

```bash
# 1. Set up environment
export USER_NAME="jack"       # Must match 'username' in variables.nix
export HOST_NAME="nixos-vm"   # Must match a host in hosts/ directory

# 2. Clone config to /tmp
nix-shell -p git --run "git clone https://github.com/JckL16/nixos-config.git /tmp/nixos-config"

# 3. Verify diskoConfig.device in hosts/$HOST_NAME/configuration.nix, then run disko
nano /tmp/nixos-config/hosts/$HOST_NAME/configuration.nix
echo -n "your-password-here" > /tmp/secret.key  # Only if encryption.enable = true
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  --flake /tmp/nixos-config#$HOST_NAME

# 4. Copy config to mounted filesystem and generate hardware config
sudo mkdir -p /mnt/home/$USER_NAME
sudo cp -r /tmp/nixos-config /mnt/home/$USER_NAME/nixos-config
sudo nixos-generate-config --no-filesystems --root /mnt
sudo mv /mnt/etc/nixos/hardware-configuration.nix \
        /mnt/home/$USER_NAME/nixos-config/hosts/$HOST_NAME/hardware-configuration.nix
sudo chown -R 1000:1000 /mnt/home/$USER_NAME

# 5. Create temporary swap and bind-mount /tmp (avoids running out of RAM)
sudo mkdir -p /mnt/tmp && sudo mount --bind /mnt/tmp /tmp
sudo dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192 status=progress
sudo chmod 600 /mnt/swapfile && sudo mkswap /mnt/swapfile && sudo swapon /mnt/swapfile

# 6. Install
sudo NIX_CONFIG="experimental-features = nix-command flakes" \
  nixos-install --root /mnt --max-jobs 1 \
  --flake /mnt/home/$USER_NAME/nixos-config#$HOST_NAME

# 7. Clean up and reboot
sudo swapoff /mnt/swapfile && sudo rm /mnt/swapfile
sudo reboot

# 8. After reboot, login as your user (password: nixos) and change password
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
};
```

| Option | Description |
|--------|-------------|
| `device` | Disk device path (from `lsblk`) |
| `encryption.enable` | Enable LUKS encryption |
| `swapSize` | Swap partition size (e.g., "8G", "16G"), omit for no swap |

### BIOS vs UEFI Configuration

BIOS/UEFI mode is controlled by `variables.isBIOS` (set per-host in `flake.nix`):

- **UEFI systems (default):** `isBIOS = false` - Creates 512MB EFI partition, enables EFI support
- **BIOS systems:** `isBIOS = true` - Creates 1MB BIOS boot partition, installs GRUB to disk

Disko reads this value directly - no need to configure it in diskoConfig.

**Keep diskoConfig enabled after installation.** The disko module only partitions disks when you explicitly run the disko command - normal rebuilds won't touch your disk. Keeping it enabled ensures bootloader settings remain correct and documents your disk layout in the config.

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
