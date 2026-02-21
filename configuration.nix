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
    warn-dirty = false;
  };
  nix.gc = {
    automatic = true;
		dates = "weekly";
    options = "--delete-older-than 30d";
  };
  services.fstrim.enable = true;
  services.smartd.enable = true;
  services.journald.extraConfig = "SystemMaxUse=500M";

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
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.tmp.useTmpfs = true;
  boot.kernel.sysctl."vm.swappiness" = 180;
  zramSwap.enable = true;

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Time and locale
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  services.xserver.xkb.layout = "de";
  console.useXkbConfig = true;

  # Login and KDE Plasma
  services.displayManager.plasma-login-manager.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.dbus.implementation = "broker";
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  # Power and session defaults
  services.power-profiles-daemon.enable = true;

  # Printing (enable when needed)
  services.printing.enable = false;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # provides `docker` CLI alias
    defaultNetwork.settings.dns_enabled = true;
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
  programs.virt-manager.enable = true;

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
    pkgsMaster.lmstudio
    pkgsHandy.handy
  ];
}
