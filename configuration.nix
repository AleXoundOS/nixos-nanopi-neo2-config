{ config, pkgs, lib, ... }:

{
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.initrd.availableKernelModules = [ "usb_storage" ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "console=ttyS0,115200n8"
    "zswap.enabled=1" "zswap.compressor=deflate"
  ];
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 16384;
  };

  fileSystems = {
    #"/boot" = {
    #  device = "/dev/disk/by-label/NIXOS_BOOT";
    #  fsType = "vfat";
    #};
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
  
  hardware.enableRedistributableFirmware = true;

  swapDevices = [
    { device = "/dev/disk/by-label/swap-AU_USB20";
      priority = 0;
    }
    { device = "/dev/disk/by-label/swap-Transcend2";
      priority = 0;
    }
    { device = "/dev/disk/by-label/swap-SDXC";
      priority = 0;
    }
  ];

  time.timeZone = "Europe/Moscow";

  networking.wireless.enable = false;
  networking.hostName = "nanopi-nixos";
  networking.firewall.enable = false;

  users.extraUsers.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    wget vim htop screen psmisc btrfs-progs
    git haskell.compiler.ghc822Binary gcc stack
    ncdu nginx unzip unrar
  ];

  nixpkgs.config.allowUnfree = true;

  services.openssh.enable = true;
  services.printing.enable = false;
  services.logind.extraConfig = "RuntimeDirectorySize=384M";

  services.nginx = {
    enable = true;
    config = ''
     events {
       worker_connections 192;
     }
      http {
        server {
          listen *:80;
          root /data/saa;
          autoindex on;
          charset utf-8;
          sendfile on;
          include ${pkgs.nginx}/conf/mime.types;
        }
      }
    '';
  };

  sound.enable = false;
  hardware.pulseaudio.enable = false;
  services.xserver.enable = false;

  nix.maxJobs = lib.mkDefault 1;
}

