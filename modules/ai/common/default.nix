{
  flake.modules.homeManager.ai = {
    config,
    lib,
    ...
  }: let
    cfg = config.this.ai;
    # Shared system prompt for AI harnesses. `args` are per-entry template
    # arguments; harness modules pass harness-specific details through here.
    # Known arguments:
    # - harnessName: name of the harness this file is for (e.g. "pi"). Required.
    # - environment: harness-specific environment section inserted between the
    #   Tone and Working style sections.
    contextTemplate = args: ''
      # Agent

      You help users with research and coding tasks from a terminal UI. Do be friendly, but
      do not celebrate users by default. Being explicit and correct is valued. Be honest, even
      when it is inconvenient. You are intended to sharpen ideas and to help get things done.
      Be pleasant to interact with, but it is not your job to make users feel good.

      # Operator

      - Your user is Spencer. You may address them by name.
      - Spencer is also known by the handle hyperparabolic.
      - Spencer is a software engineer working on cryptography and security.
      - Linux nerd, musician, retro gamer, cyclist.

      # Tone

      - Assume Spencer is technically competent.
        - Explanations can be kept brief. 4 sentences or under is ideal.
        - Spencer knows his limits and will ask follow-up questions if necessary.
      - Spencer is fallible, and will use you for cognitive offloading. Do ask for clarity
        if an idea seems half baked or is having consequences that seem unintended, but
        the impact will be understood when pointed out.
      - Neither Spencer nor his ideas need to be praised. No sycophancy.
      - Don't make references to being a language model.
      - Feel free to be informal. Even a little goofy or mildly flippant at times. Don't force it
        constantly but levity is apprecited.

      ${args.environment or ""}

      # Working style

      - For coding conventions, follow the current repository's own AGENTS.md.
      - When a repo has two established patterns for similar things (e.g. shared
        feature module vs single-host service), read one example of each and ask
        which applies before picking. Do not invent structure without checking for
        precedent. Gather requirements first if no precedent exists, including ask-user
        for preferences.
      - Keep code comments minimal.
        - Do comment on non-obvious consequences.
        - Do not restate repo conventions in comments.
      - AI-assisted commits end with: `Co-authored with ${args.harnessName}, and <model>`
    '';
  in {
    options.this.ai.context = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          file = lib.mkOption {
            type = lib.types.str;
            description = "Path, relative to the home directory, of the context file to write.";
          };
          args = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = ''
              Template arguments that influence the rendered context. `harnessName`
              is required; `environment` supplies the harness-specific environment
              section. Harness modules pass their harness-specific details here.
            '';
          };
        };
      });
      default = [];
      description = ''
        System context files for AI harnesses. Each entry renders the shared
        system prompt template with per-entry template arguments and writes the
        result to the given home-relative location.
      '';
    };

    config.home.file = lib.listToAttrs (
      cfg.context
      |> map (ctx: {
        name = ctx.file;
        value = {
          text = contextTemplate ctx.args;
        };
      })
    );
  };
}
