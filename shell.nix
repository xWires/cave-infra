{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    ansible
    packer
    python314Packages.pywinrm
    qemu
    wimlib
    xorriso
  ];

  shellHook = ''
    export PKR_VAR_efi_firmware_code="${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
    export PKR_VAR_efi_firmware_vars="${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"
    export PKR_VAR_virtio_win_drivers="${pkgs.virtio-win}"
  '';
}
