{
  description = "A flake for building NXSession";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Memoize nixpkgs for different platforms for efficiency.
      nixpkgsFor = system: import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
      };
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
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgsFor system; in
      rec {
        legacyPackages = pkgs;

        defaultPackage = pkgs.nxsession;
  }));
}
