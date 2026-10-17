{lib, ...}: let
  mkBitwardenSecretShellHook = {
    itemId,
    jqFilter,
    variable ? null,
    exportVariable ? true,
    bw ? "bw",
    jq ? "jq",
  }:
    lib.trim ''
      case "$(${bw} status | ${jq} -r '.status')" in
        unlocked)
          ;;
        locked)
          BW_SESSION="$(${bw} unlock --raw </dev/tty)"
          export BW_SESSION
          ;;
        unauthenticated)
          ${bw} login </dev/tty >/dev/tty
          BW_SESSION="$(${bw} unlock --raw </dev/tty)"
          export BW_SESSION
          ;;
        *)
          printf 'Unable to determine Bitwarden session state.\n' >&2
          exit 1
          ;;
      esac

      ${
        let
          getItem = "${bw} get item ${itemId} | ${jq} -e -r '${jqFilter}'";
        in
          if variable == null
          then getItem
          else ''${lib.optionalString exportVariable "export "}${variable}="$(${getItem})"''
      }
    '';
in {
  perSystem = {...}: {
    _module.args.mkBitwardenSecretShellHook = mkBitwardenSecretShellHook;
  };

  flake.lib.mkBitwardenSecretShellHook = mkBitwardenSecretShellHook;
}
