{...}: {
  feature.greetd = {
    description = "Lightweight console greeter and graphical session launcher via tuigreet.";
    modules = {
      greetd = {pkgs, ...}: {
        config = {
          services.greetd = {
            enable = true;
            settings.default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
              user = "greeter";
            };
          };
        };
      };
    };
  };
}
