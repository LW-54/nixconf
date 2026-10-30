{self, ...}: {
  feature.greetd = {
    description = "Lightweight console greeter and graphical session launcher via tuigreet.";
    modules = {
      greetd = {pkgs, ...}: {
        imports = [self.nixosModules.testing];

        config = {
          services.greetd = {
            enable = true;
            settings.default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
              user = "greeter";
            };
          };

          testing.checks.greetd = {
            description = "greetd is running";
            script = ''
              machine.wait_for_unit("greetd.service")
            '';
          };
        };
      };
    };
  };
}
