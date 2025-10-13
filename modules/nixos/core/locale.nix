{ variables, ... }: {

  # Timezone
  time.timeZone = variables.timeZone;

  # Keyboard configuration
  services.xserver.xkb = {
    layout = variables.keyboard-layout;
  };
  console.keyMap = variables.console-keyboard;

  # Locale settings
  i18n.defaultLocale = variables.defaultLocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = variables.extraLocale;
    LC_IDENTIFICATION = variables.extraLocale;
    LC_MEASUREMENT = variables.extraLocale;
    LC_MONETARY = variables.extraLocale;
    LC_NAME = variables.extraLocale;
    LC_NUMERIC = variables.extraLocale;
    LC_PAPER = variables.extraLocale;
    LC_TELEPHONE = variables.extraLocale;
    LC_TIME = variables.extraLocale;
  };

}