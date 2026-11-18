{
  description = "Miniflux with a SQLite backend";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Mirror of pkgs/by-name/mi/miniflux/package.nix, with the source
          # swapped for this repository.
          miniflux = pkgs.buildGoModule (finalAttrs: {
            pname = "miniflux";
            version = "unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";

            src = self;

            vendorHash = "sha256-n9UkKCDTUam+1tkVp8f4hb7AVg7OtIJI7NhPl3ii7iQ=";

            nativeBuildInputs = [ pkgs.installShellFiles ];

            # skip tests that require network access
            checkFlags = [ "-skip=TestResolvesToPrivateIP" ];

            ldflags = [
              "-s"
              "-w"
              "-X miniflux.app/v2/internal/version.Version=${finalAttrs.version}"
            ];

            __darwinAllowLocalNetworking = true;

            postInstall = ''
              mv $out/bin/miniflux.app $out/bin/miniflux
              installManPage miniflux.1
            '';

            meta = {
              description = "Minimalist and opinionated feed reader with SQLite support";
              changelog = "https://github.com/bonsko/miniflux-sqlite/commits/main";
              homepage = "https://miniflux.app/";
              license = pkgs.lib.licenses.asl20;
              mainProgram = "miniflux";
            };
          });
        in
        {
          default = miniflux;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
