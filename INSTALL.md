# NixOS Installation Guide

This guide walks you through installing NixOS with this flake-based configuration.

## Prerequisites

- NixOS installation ISO (download from [nixos.org](https://nixos.org/download.html))
- USB drive (for bootable media)
- Basic knowledge of disk partitioning

---

## Installation Steps

### 1. Boot NixOS Installation Media

Boot from the NixOS ISO (USB or CD).

### 2. Partition Your Disk

```bash
# List available disks
lsblk

# Partition the disk
sudo parted /dev/<your-disk> -- mklabel gpt
sudo parted /dev/<your-disk> -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/<your-disk> -- set 1 esp on
sudo parted /dev/<your-disk> -- mkpart primary 512MiB 100%
```

The configuration creates a swap file by standard but if you want a separate partition for it you can simply set swap.enable = false in your hosts configuration.nix file

### 3. Format Partitions

```bash
# Format boot partition
sudo mkfs.fat -F 32 -n boot /dev/<your-disk>1

# Format root partition
sudo mkfs.ext4 -L nixos /dev/<your-disk>2
```

### 4. Mount Partitions

```bash
# Mount root partition
sudo mount /dev/disk/by-label/nixos /mnt

# Mount boot partition
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

### 5. Generate Initial Configuration

```bash
sudo nixos-generate-config --root /mnt
```

### 6. Enable Flakes (Optional but Recommended)

Edit `/mnt/etc/nixos/configuration.nix`:

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Add the following line inside the configuration block:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Also enable networking:

```nix
networking.networkmanager.enable = true;
```

### 7. Install Minimal NixOS

```bash
sudo nixos-install
```

You'll be prompted to set the root password. Choose a secure password.

### 8. Reboot into New System

```bash
reboot
```

Remove the installation media when prompted.

---

## Post-Installation Setup

### 9. Login and Connect to Network

Login as **root** with the password you set during installation.

#### If using NetworkManager:
```bash
nmtui
```

Select "Activate a connection" and connect to your network.

### 10. Create Your User Account

> 📝 **Note**: Replace `jack` with your desired username.

```bash
# Add user to wheel group for sudo access
useradd -m -G wheel jack

# Set user password
passwd jack
```

### 11. Login as Your User

```bash
exit  # Logout from root
```

#### Login as your newly created user.

```bash
su jack # replace 'jack' with your desired username.
```

### 12. Clone This Configuration

```bash
# Enter a nix-shell with git available
nix-shell -p git

# Clone this repository to your home directory
cd ~
git clone https://github.com/JckL16/nixos-config.git
cd nixos-config
```

### 13. Integrate Hardware Configuration

Copy the generated hardware configuration into your config structure:

```bash
# Option 1: Copy to host-specific directory
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hosts/YOUR_HOST/hardware-configuration.nix

# Option 2: Keep in root of config (and add to .gitignore) (this will require editing of the flake.nix file)
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hardware-configuration.nix
```

### 14. Customize Configuration

Edit your flake or host configuration to match your system:

- Update hostname
- Verify username in variables.nix matches the one you created
- Ensure `hardware-configuration.nix` is properly imported
- Adjust any system-specific settings

```bash
nano flake.nix
# or
nano hosts/YOUR_HOST/configuration.nix
```

### 15. Apply Your Full Configuration

```bash
cd ~/nixos-config

# Rebuild with your flake configuration
# Replace YOUR_HOST_NAME with system flake you want to use
sudo nixos-rebuild switch --flake .#YOUR_HOST_NAME
```

This will take some time as it downloads and builds all packages.

### 16. Reboot (Recommended)

```bash
reboot
```

---

## Troubleshooting

### Network Issues

If you can't connect to the network after installation:

```bash
# Check network status
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager
```
