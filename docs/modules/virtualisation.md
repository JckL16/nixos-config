# Virtualisation

## libvirt/QEMU (KVM)

- **System:** `virtualisation.enable = true;` in `configuration.nix`
- **User:** `virt-manager.enable = true;` in `home.nix`

System-level enables libvirtd with QEMU KVM, TPM emulation, and auto-start of the default NAT network.

User-level installs the virt-manager GUI with SPICE support for Windows VMs.

```nix
# configuration.nix
virtualisation.enable = true;

# home.nix
virt-manager.enable = true;
```

## Docker

- **System only:** `docker.enable = true;` in `configuration.nix`

The user is already added to the `docker` group via `users.nix`.

## Creating a NixOS VM

When creating a NixOS VM in virt-manager, use these recommended settings:

### Basic Settings

| Setting | Recommended Value | Notes |
|---------|-------------------|-------|
| Firmware | BIOS | This config uses GRUB with BIOS by default |
| CPUs | 2-4 cores | More cores help with desktop responsiveness |
| Memory | 4-8 GB | 4GB minimum for a desktop environment |
| Disk bus | VirtIO | Best performance |
| Disk size | 20-40 GB | Depends on intended use |

### Hardware Configuration

After creating the VM, configure these devices:

**Video**
- Model: **Virtio** or **QXL**
- 3D acceleration: **Disabled** if you need snapshots, **Enabled** for better Hyprland performance

**Display**
- Type: Spice server
- Listen type: None (local only)

**Network**
- Device model: virtio

**Channel** (Add Hardware → Channel)
- Type: Spice agent (spicevmc)
- Enables clipboard sharing via spice-vdagentd

**Input** (optional)
- Add "EvTouch USB Graphics Tablet" for better mouse integration

### Snapshots vs 3D Acceleration

VirGL (3D acceleration) does not support snapshots or live migration. Choose based on your use case:

| Use Case | 3D Acceleration | Desktop | Snapshots |
|----------|-----------------|---------|-----------|
| CTF/Security work | Disabled | GNOME | Yes |
| Daily driver VM | Enabled | Hyprland | No |

For security work where you need to snapshot before analyzing malware, disable 3D acceleration and use GNOME instead of Hyprland.

---

## Guest Agents

For running NixOS inside a VM.

### QEMU Guest Agent

```nix
# configuration.nix
qemu-guest-agent.enable = true;
```

### VirtualBox Guest Agent

```nix
# configuration.nix
virtualbox-guest-agent.enable = true;
```
