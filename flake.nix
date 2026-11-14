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

      version = "unstable-${self.shortRev or "dirty"}";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.buildGoModule {
            pname = "miniflux";
            inherit version;
            src = self;

            vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

            subPackages = [ "." ];

            ldflags = [
              "-s"
              "-w"
              "-X miniflux.app/v2/internal/version.Version=${version}"
            ];

            # Tests live in CI; the sandbox has no network for anything that
            # reaches out.
            doCheck = false;

            meta = {
              description = "Minimalist and opinionated feed reader with SQLite support";
              homepage = "https://miniflux.app";
              license = pkgs.lib.licenses.asl20;
              mainProgram = "miniflux";
            };
          };
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
