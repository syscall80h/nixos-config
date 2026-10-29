{ pkgs, user, ... }:

{
  # KVM + QEMU + libvirt, managed with virt-manager.
  # VM disks go to /var/lib/libvirt/images (the @vm subvolume, NOCOW).
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm; # host architecture only (smaller than full qemu)
      swtpm.enable = true; # virtual TPM 2.0, required by Windows 11
      vhostUserPackages = [ pkgs.virtiofsd ]; # share host folders with VMs (virtiofs)
    };
    # Do not restart, at boot, the VMs that were running at shutdown:
    # a malware analysis VM must only run when started by hand.
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  programs.virt-manager.enable = true;

  # Pass a USB device to a VM from the virt-manager window (explicit action only)
  virtualisation.spiceUSBRedirection.enable = true;

  # Manage system VMs (qemu:///system) without sudo
  users.users.${user}.extraGroups = [ "libvirtd" ];
}
