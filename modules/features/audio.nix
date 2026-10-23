{...}: {
  feature.audio = {
    description = "PipeWire sound server and real-time audio processing stack.";
    modules = {
      audio = {...}: {
        config = {
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };
          services.pulseaudio.enable = false;
        };
      };
    };
  };
}
