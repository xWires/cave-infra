# cave-infra

Tools for managing bare-metal infrastructure in "The Cave".

# Setup

All servers must be running Fedora. This repo is based on Fedora 44.

First, you'll need something to run the PXE server. I used a virtual machine on Proxmox. (An LXC container will not work because it can't mount loopback devices.)

To set up the PXE server, set the `pxe_server_ip` variable in `ansible/group_vars/pxe_servers.yml` to the IP used by the PXE server. Also, add it to the `ansible/inventory.ini` file under the `[pxe_servers]` group.

Then run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/pxe_server.yml`