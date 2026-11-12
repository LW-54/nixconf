{lib, ...}: let
  indent = prefix: text:
    lib.concatMapStringsSep "\n" (line:
      if line == ""
      then ""
      else prefix + line) (lib.splitString "\n" (lib.removeSuffix "\n" text));

  # Collects enabled checks from all active namespaces.
  # Returns list of { namespace, name, qualifiedName, description, script, priority, ... }
  collectChecks = checkType: testing: let
    enabledNamespaces = lib.filterAttrs (_: ns: ns.enable or true) testing;
  in
    lib.concatLists (lib.mapAttrsToList (nsName: ns:
      lib.mapAttrsToList (cName: c:
        c
        // {
          namespace = nsName;
          name = cName;
          qualifiedName = "${nsName}.${cName}";
        }) (lib.filterAttrs (_: c: c.enable or true) (ns.${checkType} or {})))
    enabledNamespaces);

  sortChecks = checks:
    lib.sort (a: b:
      if (a.priority or 1000) == (b.priority or 1000)
      then a.qualifiedName < b.qualifiedName
      else (a.priority or 1000) < (b.priority or 1000))
    checks;

  failedEvalChecksFn = testing: let
    enabledNamespaces = lib.filterAttrs (_: ns: ns.enable or true) testing;
  in
    lib.concatLists (lib.mapAttrsToList (nsName: ns:
      lib.mapAttrsToList (cName: c: {
        name = "${nsName}.${cName}";
        inherit (c) message;
      }) (lib.filterAttrs (_: c: (c.enable or true) && !c.assertion) (ns.evalChecks or {})))
    enabledNamespaces);

  mkInspectScriptFn = testing: let
    checks = sortChecks (collectChecks "inspectChecks" testing);
  in
    lib.concatMapStringsSep "\n\n" (c: ''
      echo "==> [inspect] ${c.qualifiedName}: ${c.description}"
      (
      ${indent "  " c.script}
      )
    '')
    checks;

  mkVmScriptFn = {
    testing,
    label ? null,
  }: let
    checks = sortChecks (collectChecks "vmChecks" testing);
  in
    lib.concatMapStringsSep "\n\n" (c: let
      title = (lib.optionalString (label != null) "${label}: ") + "${c.qualifiedName} (${c.description})";
    in ''
      with subtest(${builtins.toJSON title}):
      ${indent "    " c.script}'')
    checks;

  # Inclusion relationship: Install tier runs all vmChecks plus installChecks.
  mkInstallScriptFn = {
    testing,
    label ? null,
  }: let
    vmChecks = collectChecks "vmChecks" testing;
    installChecks = collectChecks "installChecks" testing;
    combined = sortChecks (vmChecks ++ installChecks);
  in
    lib.concatMapStringsSep "\n\n" (c: let
      title = (lib.optionalString (label != null) "${label}: ") + "${c.qualifiedName} (${c.description})";
    in ''
      with subtest(${builtins.toJSON title}):
      ${indent "    " c.script}'')
    combined;

  mkTtyLoginFn = {
    user,
    password ? "test",
    tty ? 2,
  }: let
    t = toString tty;
    marker = "/tmp/nixconf-test-login-${user}";
  in ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("rm -f ${marker}")
    machine.succeed("chvt ${t}")
    machine.wait_until_succeeds("[ $(fgconsole) = ${t} ]")
    machine.wait_for_unit("getty@tty${t}.service")
    machine.wait_until_succeeds("pgrep -f 'agetty.*tty${t}'")
    machine.wait_until_tty_matches("${t}", "login: ")
    machine.send_chars("${user}\n")
    machine.wait_until_tty_matches("${t}", "login: ${user}")
    machine.wait_until_succeeds("pgrep login")
    machine.wait_until_tty_matches("${t}", "Password: ")
    machine.send_chars(${builtins.toJSON "${password}\n"})
    machine.wait_until_succeeds("pgrep -u ${user} -f 'bash|sh|zsh|fish'")
    machine.send_chars("touch ${marker}\n")
    machine.wait_for_file("${marker}")
    assert machine.succeed("stat -c %U ${marker}").strip() == "${user}"
    machine.send_chars("exit\n")
  '';
in {
  flake.lib.testing = {
    inherit
      indent
      collectChecks
      sortChecks
      ;

    failedEvalChecks = failedEvalChecksFn;
    mkInspectScript = mkInspectScriptFn;
    mkVmScript = mkVmScriptFn;
    mkInstallScript = mkInstallScriptFn;
    mkTtyLogin = mkTtyLoginFn;
  };
}
