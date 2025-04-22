{...}: {
  xsession.windowManager.awesome = {
    enable = true;
  };

  xdg.configFile = {
    awesome = {
      source = ../../awesome;
      recursive = true;
    };
  };
}
