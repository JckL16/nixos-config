# Troubleshooting

Common issues and solutions.

## Network Issues

```bash
# Check network status
nmcli device status

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

## Build Failures

If the build fails, check that:

- Your `hardware-configuration.nix` is in the correct host directory
- Your hostname in `configuration.nix` matches the flake entry name
- The username in `variables.nix` matches the user you created
- You have selected the correct graphics driver for your hardware

## Flake Lock Issues

If packages are outdated or you're getting unexpected versions:

```bash
# Update the flake lock file
nix flake update

# Or update a specific input
nix flake lock --update-input nixpkgs
```

## Display Issues

### Black screen after login

Check that you've enabled the correct graphics driver for your hardware:

```nix
# For Intel
intel-graphics.enable = true;

# For AMD
amd-graphics.enable = true;

# For NVIDIA
nvidia-graphics.enable = true;
```

### Wrong resolution or refresh rate

Configure your monitor in `home.nix`:

```nix
wayland.windowManager.hyprland.settings = {
  monitor = [
    "DP-1, 2560x1440@144, 0x0, 1"
  ];
};
```

Use `hyprctl monitors` to list available monitors and their names.

## Audio Issues

```bash
# Check PipeWire status
systemctl --user status pipewire

# Restart PipeWire
systemctl --user restart pipewire
```

## Bluetooth Issues

```bash
# Check Bluetooth status
systemctl status bluetooth

# Restart Bluetooth
sudo systemctl restart bluetooth

# Use bluetoothctl to pair devices
bluetoothctl
```

## WSL-Specific Issues

### Cannot connect to X server

WSL runs headless by default. For GUI apps, ensure WSLg is enabled (Windows 11) or use an X server on Windows.

### Slow file access on /mnt/c

This is expected. Windows filesystem access through WSL is slower than native Linux filesystems. Keep your projects in the Linux filesystem (`~`) for better performance.

## Recovering from Bad Configuration

If you can't boot after a configuration change:

1. At the GRUB menu, select a previous generation
2. Boot into it
3. Fix the configuration
4. Rebuild

Or from a live USB:

```bash
# Mount your system
sudo mount /dev/disk/by-label/nixos /mnt
sudo mount /dev/disk/by-label/boot /mnt/boot

# Chroot into the system
sudo nixos-enter --root /mnt

# Fix and rebuild
cd ~/nixos-config
nixos-rebuild switch --flake .#<hostname>
```
