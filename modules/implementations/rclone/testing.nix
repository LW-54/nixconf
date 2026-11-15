{
  internal.rclone.mkTesting = {
    self,
    config,
    lib,
    pkgs,
    state,
    tmpl,
  }: let
    inherit
      (state)
      cfg
      enabledMounts
      mountNames
      mountedSliceNames
      compositeSliceValid
      ;
    inherit (tmpl) mountIsProtocolSupported rcloneObscureScript;

    loopbackPlainConf = pkgs.writeText "loopback-plain.conf" ''
      [loop-hot]
      type = alias
      remote = /tmp/loopback-store/hot

      [loop-cold-raw]
      type = alias
      remote = /tmp/loopback-store/cold-raw

      [loop-cold]
      type = crypt
      remote = loop-cold-raw:
      filename_encryption = standard
      directory_name_encryption = true
      password = test-loopback-password-1
      password2 = test-loopback-password-2

      [loop-tiered]
      type = union
      upstreams = loop-hot: loop-cold:
      action_policy = epall
      create_policy = epff
      search_policy = ff
    '';
  in {
    description = "Rclone configuration templating, mount generation, and loopback tiered crypt verification";

    evalChecks = {
      valid-mount-slices = {
        assertion = lib.all (name: cfg.slices ? ${name}) mountedSliceNames;
        message = "All enabled `storage.mounts.*.slice` entries must reference defined slices in `storage.slices`.";
      };
      valid-active-slices = {
        assertion = lib.all (name: cfg.slices ? ${name}) cfg.activeSlices;
        message = "All `storage.activeSlices` entries must reference defined slices in `storage.slices`.";
      };
      valid-mount-protocols = {
        assertion = lib.all (mName: mountIsProtocolSupported enabledMounts.${mName}) mountNames;
        message = "A mount in `storage.mounts` requests a transport protocol unsupported by its target slice.";
      };
      cache-excluded-from-backup = {
        assertion = builtins.elem "/var/cache/rclone" config.backup.exclude;
        message = "`/var/cache/rclone` must be excluded from `backup.exclude` when `implementation.rclone` is active.";
      };
      composite-slices-valid = {
        assertion = lib.all (name: compositeSliceValid name cfg.slices.${name}) (builtins.attrNames cfg.slices);
        message = "One or more `storage.slices` entries contain cyclic or dangling provider/slice references.";
      };
    };

    inspectChecks = {
      rclone-binary = {
        description = "Verify rclone and mount.rclone helpers exist in system closure";
        priority = 200;
        script = ''
          for bin in "$system/sw/bin/rclone" "$system/sw/bin/mount.rclone"; do
            if [ ! -x "$bin" ]; then
              echo "Error: expected executable '$bin' missing!" >&2
              exit 1
            fi
          done
        '';
      };
      rclone-etc-link = {
        description = "Verify /etc/rclone/rclone.conf links to /run/rclone/rclone.conf";
        priority = 210;
        script = ''
          link="$etc/rclone/rclone.conf"
          if [ ! -L "$link" ]; then
            echo "Error: expected symlink '$link' missing!" >&2
            exit 1
          fi
          target="$(readlink "$link")"
          if [ "$target" != "/run/rclone/rclone.conf" ]; then
            echo "Error: expected '$link' -> '/run/rclone/rclone.conf', got '$target'" >&2
            exit 1
          fi
        '';
      };
      rclone-config-unit = {
        description = "Verify rclone-config.service unit exists";
        priority = 220;
        script = self.lib.testing.mkInspectFile {
          path = "$etc/systemd/system/rclone-config.service";
          pattern = "nixconf-rclone-config-setup";
        };
      };
    };

    vmChecks.loopback-tiered-crypt = {
      description = "rclone-config renders /run/rclone/rclone.conf and loopback union+crypt mounts cleanly via VFS cache";
      priority = 400;
      script = ''
        machine.wait_for_unit("rclone-config.service")
        machine.succeed("test -s /run/rclone/rclone.conf && test -L /etc/rclone/rclone.conf")

        machine.succeed("mkdir -p /tmp/loopback-store/hot/hot-tier /tmp/loopback-store/cold-raw /mnt/loopback-tiered /var/cache/rclone/loopback-test")
        machine.succeed("${rcloneObscureScript}/bin/nixconf-rclone-obscure-config ${loopbackPlainConf} /tmp/loopback.conf")
        machine.succeed("test $(stat -c '%a' /tmp) = '1777'")
        machine.succeed("test $(stat -c '%a' /tmp/loopback.conf) = '600'")
        machine.fail("grep -q 'test-loopback-password-1' /tmp/loopback.conf")

        machine.succeed(
            "mount -t rclone "
            "-o rw,allow_other,args2env,config=/tmp/loopback.conf,cache-dir=/var/cache/rclone/loopback-test,dir-cache-time=1s,vfs-cache-mode=writes "
            "loop-tiered: /mnt/loopback-tiered"
        )
        machine.wait_until_succeeds("mountpoint -q /mnt/loopback-tiered", timeout=30)

        # Ensure epff routes new writes in /hot-tier deterministically to loop-hot rather than racing on '/'.
        machine.succeed("echo hot-tier-data > /mnt/loopback-tiered/hot-tier/hot-file.txt")
        machine.wait_until_succeeds("grep -qx 'hot-tier-data' /tmp/loopback-store/hot/hot-tier/hot-file.txt", timeout=15)

        machine.succeed("printf 'cold-secret-payload\n' > /tmp/cold-input.txt")
        machine.succeed("rclone --config /tmp/loopback.conf copyto /tmp/cold-input.txt loop-cold:cold-file.txt")
        machine.succeed("rm -f /tmp/cold-input.txt")

        # Verify ciphertext in cold-raw: neither plaintext filename nor plaintext payload appears on disk.
        machine.fail("test -e /tmp/loopback-store/cold-raw/cold-file.txt")
        machine.fail("grep -rq 'cold-secret-payload' /tmp/loopback-store/cold-raw")

        # Verify transparent plaintext read through the union + crypt mount.
        machine.wait_until_succeeds("grep -qx 'cold-secret-payload' /mnt/loopback-tiered/cold-file.txt", timeout=10)

        machine.succeed("umount /mnt/loopback-tiered")
        machine.succeed("rm -rf /tmp/loopback.conf /tmp/loopback-store /mnt/loopback-tiered /var/cache/rclone/loopback-test")
      '';
    };
  };
}
