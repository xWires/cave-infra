# cave-infra

Tools for managing bare-metal infrastructure in "The Cave".

# Setup

All servers must be running Fedora. This repo is based on Fedora 44.

First, you'll need something to run the PXE server. I used a virtual machine on Proxmox. (An LXC container will not work because it can't mount loopback devices.)

To build the Windows Server image, you must first get the virtio-win drivers and place the contents of the ISO into `images/windows_server/drivers/` (if you are on NixOS, use the `./scripts/nixos-copy-virtio-win.sh` which will get the files for you), copy and fill in `./images/windows_server/.auto.pkrvars.hcl.example`, then run `packer build ./images/windows_server`.

To set up the PXE server, set the `pxe_server_ip` variable in `ansible/group_vars/pxe_servers.yml` to the IP used by the PXE server. Also, add it to the `ansible/inventory.ini` file under the `pxe_servers` group.

Then run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/pxe_server.yml`

# Active Directory

To set up Active Directory, set the `ad_initial_dc` host in `inventory.ini` to the server to use to set up the domain, then run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/create_ad_domain.yml --ask-pass`.

After the initial domain controller has created the forest and DNS, set `ad_dns` to its IP address and run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/join_domain.yml --ask-pass` to join the other servers to the domain and set hostnames.
You must now update `inventory.ini` to use the FQDNs of the Windows servers, which is required for Kerberos authentication.
Then use `ansible-playbook -i ansible/inventory.ini ansible/playbooks/windows_servers.yml --ask-pass` to finish setting things up. It has to be two separate playbooks because `join_domain` needs to use `basic` authentication because the servers aren't in the domain yet, then `windows_servers` switches to using `kerberos` authentication as some apps require it to be able to install properly (for example, Exchange).
Additional domain controllers use the initial controller for DNS while joining and switch to local DNS afterwards.

# Exchange Server

To setup Exchange Server, add the address of the host to the `exchange_servers` group and run `ansible-playbook -i ansible/inventory.ini ansible/playbooks/windows_servers.yml --ask-pass`. Only one instance of Exchange is supported currently.
