{config, ...}: {
  flake.modules.nixos.hosts-redbud = {...}: {
    imports = with config.flake.modules.nixos;
      [
        core
        hyperparabolic
        this
        this-share-home

        audio
        bluetooth
        laptop
        pipewire-raop
        reverse-proxy
        secureboot
        user-spencer
        zfs

        # TODO: tpm decrypt failure
        # automated LUKS unlocks are borked, no time to dig atm
        # clues for looking later:
        # `tpm2_getcap properties-variable`
        # maybe related?:
        # https://github.com/systemd/systemd/issues/42725
        # https://github.com/systemd/systemd/commit/be8a7b418a3493ecaa1b7f36abcbd8685aa2931d
        stage1-ssh
      ]
      ++ [
        {
          home-manager.users.spencer = {
            imports = with config.flake.modules.homeManager; [
              core
              hosts-redbud

              user-spencer
            ];
          };
        }
      ];
  };

  flake.modules.homeManager.hosts-redbud = {...}: {};
}
