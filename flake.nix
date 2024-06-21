{
  description = "Basic haskell cabal template";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ self.overlay ];
      });
    in
    {
      overlay = final: prev: {
        hsPkgs = prev.haskell.packages.ghc965.override {
          overrides = hfinal: hprev: { };
        };
        init-project = final.writeScriptBin "init-project" ''
          ${final.hsPkgs.cabal-install}/bin/cabal init --non-interactive
        '';
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          developPackage = pkgs.hsPkgs.developPackage {
            root = ./.;
          };

        in
        {
          default = developPackage;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          developPackage = pkgs.hsPkgs.developPackage {
            root = ./.;
          };
          libs = with pkgs; [
            zlib
            ormolu
            treefmt
          ];
        in
        {
          default = pkgs.hsPkgs.shellFor {
            packages = hsPkgs: [ ];
            buildInputs = with pkgs; [
              hsPkgs.cabal-install
              hsPkgs.cabal-fmt
              hsPkgs.ghc
              nixpkgs-fmt
              hsPkgs.cabal-fmt
              init-project
              developPackage
            ] ++ libs;
            shellHook = "export PS1='[$PWD]\n❄ '";
            LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath libs;
          };
        });
    };
}
