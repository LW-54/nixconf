{
  internal.storage.defaults.providers = {
    hbox = {
      driver = "hetzner-box";
      secretStore = "storage/providers/hbox";
      settings = {
        boxId = "u711975";
        hostKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs"
        ];
      };
    };
    gdrive = {
      driver = "gdrive";
      secretStore = "storage/providers/gdrive";
      settings = {};
    };
    b2 = {
      driver = "b2";
      secretStore = "storage/providers/b2";
      settings = {
        bucket = "cyclostyle-docker";
        endpoint = "https://s3.eu-central-003.backblazeb2.com";
        region = "eu-central-003";
      };
    };
  };
}
