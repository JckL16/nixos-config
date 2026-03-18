# NixOS Installation Guide

This guide walks you through installing NixOS using this flake-based configuration. An example host (`hosts/nixos-example/`) is included as a starting point for your own system.

## Prerequisites

- NixOS installation ISO (download from [nixos.org](https://nixos.org/download.html))
- USB drive (for bootable media)
- Basic knowledge of disk partitioning

---

## Installation Steps

### 1. Boot NixOS Installation Media

Boot from the NixOS ISO.

### 2. Partition Your Disk

#### EFI

```bash
# List available disks
lsblk

# Open parted
sudo parted /dev/<your-disk>

# Inside parted, run:
mklabel gpt
mkpart ESP fat32 1MiB 512MiB
set 1 esp on
mkpart primary 512MiB 100%
quit
```

#### BIOS (VMs for example)

```bash
# List available disks
lsblk

# Open parted
sudo parted /dev/<your-disk>

# Inside parted, run:
mklabel msdos
mkpart primary 1MiB 100%
set 1 boot on
quit
```

> **Note:** A swap file is created by default. If you prefer a separate swap partition or no swap at all, you can set `swap-file.enable = false` in your host's `configuration.nix`.

### 3. Format and Mount Partitions

#### EFI

```bash
# Format boot partition
sudo mkfs.fat -F 32 -n boot /dev/<your-disk>1

# Format root partition
sudo mkfs.ext4 -L nixos /dev/<your-disk>2

# Mount root partition
sudo mount /dev/disk/by-label/nixos /mnt

# Mount boot partition
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
```

#### BIOS

```bash
# Format the root partition
mkfs.ext4 -L nixos /dev/<your-disk>1

# Mount the root partition
mount /dev/disk/by-label/nixos /mnt
```

### 4. Generate Initial Configuration

```bash
sudo nixos-generate-config --root /mnt
```

### 5. Enable Flakes

Edit `/mnt/etc/nixos/configuration.nix`:

```bash
sudo nano /mnt/etc/nixos/configuration.nix
```

Add the following inside the configuration block:

```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
networking.networkmanager.enable = true;
```

#### BIOS Only

For BIOS systems, GRUB needs to know which device to install to. Add this to the same file:

```nix
boot.loader.grub.device = "/dev/<your-disk>";
```

### 6. Install Minimal NixOS

```bash
sudo nixos-install
```

You'll be prompted to set the root password.

### 7. Reboot into New System

```bash
reboot
```

Remove the installation media when prompted.

---

## Post-Installation Setup

### 8. Login and Connect to Network

Login as **root** with the password you set during installation.

```bash
nmtui
```

Select "Activate a connection" and connect to your network.

### 9. Create Your User Account

> **Note:** Replace `jack` with the username you intend to set in `variables.nix`.

```bash
useradd -m -G wheel jack
passwd jack
```

### 10. Login as Your User

```bash
exit  # Logout from root
```

Login as the user you just created.

### 11. Clone This Configuration

```bash
nix-shell -p git

cd
git clone https://github.com/JckL16/nixos-config.git
cd nixos-config
```

### 12. Set Up Your Host Using the Example

The repository includes an example host at `hosts/nixos-example/` that you can copy and customize.

```bash
cp -r hosts/nixos-example hosts/<your-hostname>
```

#### Copy your hardware configuration into the new host directory:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/nixos-config/hosts/<your-hostname>/hardware-configuration.nix
```

### 13. Register Your Host in flake.nix

Add a new entry to `flake.nix` for your host. Use the existing entries as reference:

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
    ./hosts/<your-hostname>/hardware-configuration.nix
    ./hosts/<your-hostname>/configuration.nix
    ./modules/nixos
    home-manager.nixosModules.home-manager
  ];
};
```

For BIOS systems or when you need to override variables per host, use the override syntax:

```nix
variables = (import ./variables.nix) // {
  bootDevice = "/dev/sda";
  isBIOS = true;
};
```

### 14. Edit variables.nix

Update the global variables to match your setup:

```bash
nano ~/nixos-config/variables.nix
```

Set your username, timezone, locale, keyboard layout, and git credentials. These values are used throughout the entire configuration.

### 15. Customize Your Host

Edit your host's `configuration.nix` and `home.nix` to enable the features you need. The example config has comments showing available options:

```bash
nano ~/nixos-config/hosts/<your-hostname>/configuration.nix
nano ~/nixos-config/hosts/<your-hostname>/home.nix
```

The example host comes with Hyprland enabled and graphics drivers commented out for you to choose from. Uncomment and enable modules as needed. See [CONTENT.md](CONTENT.md) for a full list of available modules and how to configure them.

### 16. Apply Your Configuration

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#<your-hostname>
```

### 17. Reboot

```bash
reboot
```

---

## Troubleshooting

### Network Issues

```bash
# Check network status
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

### Build Failures

If the build fails, check that:
- Your `hardware-configuration.nix` is in the correct host directory
- Your hostname in `configuration.nix` matches the flake entry name
- The username in `variables.nix` matches the user you created
- You have selected the correct graphics driver for your hardware
