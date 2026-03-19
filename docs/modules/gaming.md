# Gaming

Gaming requires both system-level and user-level modules.

## Steam

- **System:** `steam.enable = true;` in `configuration.nix`
- **User:** `steam.enable = true;` in `home.nix`

System-level installs Steam with Proton-GE compatibility. If `gamemode.enable` is also true, Steam is built with GameMode support automatically.

User-level installs additional tools: MangoHUD, Vulkan tools, Proton utilities.

## GameMode

- **System:** `gamemode.enable = true;` in `configuration.nix`
- **User:** `gamemode.enable = true;` in `home.nix`

System-level configures Feral GameMode with:
- CPU governor optimization
- GPU performance settings
- Renice for game processes
- Desktop notifications on activation/deactivation

## Minecraft

- **User only:** `minecraft.enable = true;` in `home.nix`

Installs the Minecraft launcher.

## Example Configuration

```nix
# configuration.nix
steam.enable = true;
gamemode.enable = true;

# home.nix
steam.enable = true;
gamemode.enable = true;
minecraft.enable = true;
```
