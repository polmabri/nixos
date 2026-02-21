{ config, lib, pkgs, pkgsMaster, pkgsHandy, hostname, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # Nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };
  nix.gc = {
    automatic = true;
		dates = "weekly";
    options = "--delete-older-than 30d";
  };
  services.fstrim.enable = true;

  # User
  users.users.marek = {
    isNormalUser = true;
    description = "Marek";
    extraGroups = [ "wheel" ]
      ++ lib.optional config.networking.networkmanager.enable "networkmanager"
      ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd";
  };
  environment.localBinInPath = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  zramSwap.enable = true;

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Time and locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };
  services.xserver.xkb.layout = "de";
  console.useXkbConfig = true;

  # Login and KDE Plasma
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  # Power and session defaults
  services.power-profiles-daemon.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Security
  security.apparmor.enable = true;

  # Virtual machines
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # Enable TPM emulation (for Windows 11)
      swtpm.enable = true;
      vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;    

  # Packages
  environment.systemPackages = with pkgs; [
    git
    ffmpeg
    google-chrome
    firefox
    pkgsMaster.vscode
    pkgsMaster.opencode
    nodejs
    obsidian
    virt-manager # VM management GUI
    remmina # Remote desktop client
    pkgsMaster.lmstudio
    pkgsHandy.handy
  ];
}
