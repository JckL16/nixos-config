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

  # If using grub this will be used.
  # When using a BIOS system this has to specify the drive to install GRUB to
  # These settings are meant to be changed in flake.nix
  bootDevice = "nodev";

  isBIOS = false;

  # Wallpaper path (relative to home directory config)
  wallpaperPath = "~/.config/wallpapers/wallpaper.png";
}
