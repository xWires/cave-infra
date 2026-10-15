packer {
  required_plugins {
    qemu = { source = "github.com/hashicorp/qemu", version = ">= 1.1.0" }
  }
}

variable "build_password" {
  type = string
  sensitive = true
}

variable "efi_firmware_code" {
  type = string
}

variable "efi_firmware_vars" {
  type = string
}

variable "virtio_win_drivers" {
  type = string
}

source "qemu" "win" {
  iso_url = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  iso_checksum = "3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

  accelerator = "kvm"
  machine_type = "q35"
  cpus = 4
  memory = 8192
  disk_size = "60G"
  format = "qcow2"

  efi_boot = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars

  disk_interface = "virtio-scsi"
  net_device = "virtio-net"

  cd_content = {
    "Autounattend.xml" = templatefile("Autounattend.pkrtpl.xml", { password = var.build_password })
  }
  cd_files = [
    "${path.root}/drivers/*",
    "${path.root}/Enable-WinRM.ps1"
  ]

  boot_wait = "2s"
  boot_command = ["<spacebar><spacebar><spacebar>"]

  communicator = "winrm"
  winrm_insecure = true
  winrm_use_ssl = true
  winrm_username = "Administrator"
  winrm_password = var.build_password

  shutdown_command = "shutdown /s /t 0"
  # shutdown_command = "C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /quiet /unattend:C:\\Windows\\Temp\\sysprep-unattend.xml"
  shutdown_timeout = "30m"
  output_directory = "${path.root}/output"
  vm_name          = "win.qcow2"
}

build {
  sources = ["source.qemu.win"]

  provisioner "powershell" {
    script = "${path.root}/Update-Windows.ps1"
  }

  post-processor "shell-local" {
    inline = ["\"${path.root}/../../scripts/qcow2-to-wim.sh\" \"${path.root}/output/win.qcow2\" 3 \"${path.root}/output/install.wim\""]
  }
}
