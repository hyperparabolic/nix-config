{
  flake.modules.nixos.hosts-oak = {...}: {
    nixpkgs.config = {
      cudaSupport = true;
      # experimenting with enabling CPU optimizations, disabled for now
      #
      # packageOverrides = pkgs: {
      #   # build for oak CPU / GPU capabilities. Performance improvements,
      #   # but this is not portable to other hosts.
      #   llama-cpp =
      #     (pkgs.llama-cpp.override {
      #       blasSupport = true;
      #       cudaSupport = true;
      #       metalSupport = false;
      #       rocmSupport = false;
      #     }).overrideAttrs (oldAttrs: {
      #       cmakeFlags =
      #         (oldAttrs.cmakeFlags or [])
      #         ++ [
      #           # enable CPU optimizations
      #           "-DGGML_NATIVE=ON"
      #           # speed up builds, only build for my cuda arch
      #           "-DCMAKE_CUDA_ARCHITECTURES=86"
      #         ];
      #       preConfigure = ''
      #         # don't suppress -march=native
      #         export NIX_ENFORCE_NO_NATIVE=0
      #         ${oldAttrs.preConfigure or ""}
      #       '';
      #     });
      #   onnxruntime = pkgs.onnxruntime.overrideAttrs (oldAttrs: {
      #     # RAM use building this package with optimizations is
      #     # wild. -j8 to avoid slowdown due to RAM limits.
      #     preBuild = ''
      #       NIX_BUILD_CORES=8
      #       ${oldAttrs.preBuild or ""}
      #     '';
      #   });
      # };
    };
  };
}
