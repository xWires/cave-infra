# cave-infra

Tools for managing bare-metal infrastructure in "The Cave".

# Setup

All servers must be running Fedora. This repo is based on Fedora 44.

First, you'll need something to run the PXE server. I used a virtual machine on Proxmox. (An LXC container will not work because it can't mount loopback devices.)

To build the Windows Server image, you must first get the virtio-win drivers and place the contents of the ISO into `images/windows_server/drivers/` (if you are on NixOS, use the `./scripts/nixos-copy-virtio-win.sh` which will get the files for you), copy and fill in `./images/windows_server/.auto.pkrvars.hcl.example`, then run `packer build ./images/windows_server`.

To set up the PXE server, set the `pxe_server_ip` variable in `ansible/group_vars/pxe_servers.yml` to the IP used by the PXE server. Also, add it to the `ansible/inventory.ini` file under the `[pxe_servers]` group.

Then run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/pxe_server.yml`
