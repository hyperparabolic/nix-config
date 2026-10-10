{
  flake.modules.homeManager.ai-omp = {config, ...}: let
    env_host = ''
      # Environment

      You are running on the nixos host ${config.this.networking.hostname} defined in the
      nix flake in the github repo at https://github.com/hyperparabolic/nix-config

      ## omp Configuration

      `~/.omp` is a single directory mixing configuration and state, and omp treats
      it as writable state. The nix-managed files inside it come in two shapes:

      - `~/.omp/agent/AGENTS.md` (this file) is an immutable nix store file. Never
        edit it in place. Its source of truth is `~/.nix-config/modules/ai/omp`,
        with the shared system prompt template in
        `~/.nix-config/modules/ai/common`; propose changes there for Spencer to
        apply.
      - `~/.omp/agent/{config.yml,models.yml}` are out-of-store symlinks that
        resolve into `~/.nix-config/modules/ai/omp/`: editing them directly edits
        the repository working tree. Commit the change if it should stick.
      - Everything else under `~/.omp` (databases, sessions, logs, caches) is
        runtime state, not configuration.

      ## Persistence

      The host home is impermanence-managed and as much as possible of omp is configured
      declaratively, so files written under `$HOME` or XDG dirs are wiped on reboot if
      they are not explicitly configured to be persisted. ~/.omp state is persisted, but
      agentic edits should target the source of truth for these files where possible:

      - `~/.nix-config` contains a flake that contains host configs.
      - `~/.nix-config/modules/ai/omp` contains the omp module that defines omp
        specific config, skills, and context.
      - ~/.nix-config/modules/ai/common` contains common harness aspects like context
        templates and common skills.

      ## Security

      You are running as the normal user spencer. Privilege escalation and gpg operations
      require interaction with a hardware key. This includes:
      - sudo
      - ssh
      - git signing
      - git push / pull
      - pass cli
      - sops

      Do not attempt to work around these limitations. Ask Spencer to do things for you if necessary.
    '';
  in {
    this.ai.context.".omp/agent/AGENTS.md" = {
      harnessName = "omp";
      environment = env_host;
    };
  };
}
