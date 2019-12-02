
{
  description = "A flake for building NXSession";

  edition = 201909;

  outputs = { self, nixpkgs }:
    let

      officialRelease = false;

      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );
    in {

      overlay = final: prev: with final; {
        nxsession = substituteAll {
          dir = "bin";
          isExecutable = true;
          name = "nxsession";
          nxlibs = nx-libs; # substituteAll does not handle variable with '-'
          inherit psmisc;
          inherit (xorg) xauth;
          src = ./nxsession;
        };
      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) nxsession;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.nxsession);

  };
}
