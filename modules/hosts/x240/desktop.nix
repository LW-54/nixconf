{ ... }:
{
  flake.nixosModules.x240Desktop = {
    console.keyMap = "fr";
    services.xserver.xkb = {
      layout = "fr";
      variant = "";
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}