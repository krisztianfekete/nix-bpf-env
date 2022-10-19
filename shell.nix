let
  unstableTarball = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  pkgs = import <nixpkgs> {};
  unstable = import unstableTarball {};
in

pkgs.mkShell {

  hardeningDisable = [ "stackprotector" ];
  buildInputs = [
    pkgs.hello
    unstable.clang_14 # use unstable to pull 14.0.6 instead of 14.0.1
    pkgs.llvm
    pkgs.elfutils
    pkgs.zlib
    pkgs.pkg-config
    pkgs.bpftools # stable (22.05) has 6.0.2, while unstable has 5.19.8

    # keep this line if you use bash
    pkgs.bashInteractive
  ];
}
