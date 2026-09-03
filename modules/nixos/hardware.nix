{ ... }:
{
  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true; # was hardware.opengl before 24.11

    bluetooth = {
      enable = true;
      settings.General = {
        # Headset battery reporting and better codec negotiation.
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  # PipeWire replaces PulseAudio. GNOME expects it.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Trackpad and touchscreen handling.
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };

  services.fwupd.enable = true; # firmware updates
  services.printing.enable = true;
}
