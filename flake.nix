{
  inputs = {
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixos-stable, nixpkgs-unstable, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system:
      let
        pkgs = import nixos-stable { inherit system; };
        unstable-pkgs = import nixpkgs-unstable { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          hardeningDisable = [ "stackprotector" ];
          packages = [
            unstable-pkgs.clang_14 # use unstable to pull 14.0.6 instead of 14.0.1
            pkgs.llvm
            pkgs.elfutils
            pkgs.zlib
            pkgs.pkg-config ];
        };
      });
}

