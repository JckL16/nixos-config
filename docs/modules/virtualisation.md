# Virtualisation

## libvirt/QEMU (KVM)

- **System:** `virtualisation.enable = true;` in `configuration.nix`
- **User:** `virt-manager.enable = true;` in `home.nix`

System-level enables libvirtd with QEMU KVM, TPM emulation, and auto-start of the default NAT network. Also installs `vagrant` and `ansible`, and sets `VAGRANT_LIBVIRT_OVMF_CODE` so that vagrant-libvirt can locate the OVMF firmware (which lives in the Nix store rather than the standard distro paths the plugin expects).

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
