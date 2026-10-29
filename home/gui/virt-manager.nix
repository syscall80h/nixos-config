{ ... }:
{
  # virt-manager connects to the system libvirt (where the VMs live) at startup
  dconf.settings."org/virt-manager/virt-manager/connections" = {
    autoconnect = [ "qemu:///system" ];
    uris = [ "qemu:///system" ];
  };
}
