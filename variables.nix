# variables.nix

{
  username = "jack";
  description = "Jack";
  timeZone = "Europe/Stockholm";

  gitUsername = "Jack";
  gitEmail = "jack@example.com";

  defaultLocale = "en_US.UTF-8";
  extraLocale = "sv_SE.UTF-8";

  keyboard-layout = "se";
  console-keyboard = "sv-latin1";

  system-state-version = "25.11";

  # Bootloader configuration
  # bootDevice: Drive to install GRUB to (for BIOS systems or when not using disko)
  # isBIOS: Set to true for BIOS/legacy boot, false for UEFI
  # Override these per-host in flake.nix. When disko is enabled, it uses these as defaults.
  bootDevice = "nodev";
  isBIOS = false;

  # Wayland compositor scale factor (e.g., 1, 1.5, 2)
  # Controls Hyprland monitor scaling; all UI renders in logical pixels
  displayScale = 1;

  # Wallpaper path (relative to home directory config)
  wallpaperPath = "~/.config/wallpapers/wallpaper.png";
}
