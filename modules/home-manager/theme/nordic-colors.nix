# modules/home-manager/theme/nordic-colors.nix
# Centralized Nordic/Nord color palette for consistent theming across all modules

{
  # Polar Night - Dark backgrounds
  nord0 = "#2E3440";   # Background
  nord1 = "#3B4252";   # Lighter background
  nord2 = "#434C5E";   # Selection background
  nord3 = "#4C566A";   # Comments, borders

  # Snow Storm - Light text
  nord4 = "#D8DEE9";   # Main text
  nord5 = "#E5E9F0";   # Lighter text
  nord6 = "#ECEFF4";   # Brightest text

  # Frost - Accent colors
  nord7 = "#8FBCBB";   # Teal/cyan
  nord8 = "#88C0D0";   # Light blue (primary accent)
  nord9 = "#81A1C1";   # Blue
  nord10 = "#5E81AC";  # Dark blue

  # Aurora - Semantic colors
  nord11 = "#BF616A";  # Red (errors, urgent)
  nord12 = "#D08770";  # Orange (warnings)
  nord13 = "#EBCB8B";  # Yellow
  nord14 = "#A3BE8C";  # Green (success)
  nord15 = "#B48EAD";  # Purple/magenta

  # Common semantic mappings
  background = "#2E3440";
  backgroundAlt = "#3B4252";
  foreground = "#D8DEE9";
  foregroundAlt = "#ECEFF4";
  border = "#4C566A";
  accent = "#88C0D0";
  urgent = "#BF616A";
  warning = "#EBCB8B";
  success = "#A3BE8C";
  selected = "#5E81AC";

  # Alacritty-specific color scheme
  alacritty = {
    primary = {
      background = "#2E3440";
      foreground = "#D8DEE9";
    };
    cursor = {
      cursor = "#D8DEE9";
      text = "#2E3440";
    };
    selection = {
      background = "#D8DEE9";
      text = "#2E3440";
    };
    normal = {
      black = "#3B4252";
      red = "#BF616A";
      green = "#A3BE8C";
      yellow = "#EBCB8B";
      blue = "#81A1C1";
      magenta = "#B48EAD";
      cyan = "#88C0D0";
      white = "#E5E9F0";
    };
    bright = {
      black = "#4C566A";
      red = "#BF616A";
      green = "#A3BE8C";
      yellow = "#EBCB8B";
      blue = "#81A1C1";
      magenta = "#B48EAD";
      cyan = "#8FBCBB";
      white = "#ECEFF4";
    };
  };

  # Sway/Hyprland window colors
  window = {
    focused = {
      border = "#4C566A";
      background = "#4C566A";
      text = "#D8DEE9";
      indicator = "#4C566A";
      childBorder = "#4C566A";
    };
    unfocused = {
      border = "#4C566A";
      background = "#4C566A";
      text = "#D8DEE9";
      indicator = "#4C566A";
      childBorder = "#4C566A";
    };
    urgent = {
      border = "#BF616A";
      background = "#BF616A";
      text = "#D8DEE9";
      indicator = "#BF616A";
      childBorder = "#BF616A";
    };
  };

  # Swaylock command with Nordic colors
  swaylockCmd = wallpaperPath: ''swaylock -f -i ${wallpaperPath} --effect-blur 7x5 --indicator --indicator-radius 100 --indicator-thickness 7 --ring-color 4c566a --key-hl-color 88c0d0 --bs-hl-color bf616a --inside-color 2e344088 --ring-ver-color 5e81ac --inside-ver-color 2e344088 --ring-wrong-color bf616a --inside-wrong-color 2e344088 --line-color 00000000 --separator-color 00000000 --clock --timestr '%H:%M:%S' --datestr "" --text-color eceff4 --font 'JetBrainsMono Nerd Font' --font-size 24'';
}
