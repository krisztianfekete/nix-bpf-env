# nix-bpf-env
My adhoc dev environment for BPF development on NixOS

![image](https://user-images.githubusercontent.com/103492698/196720215-d2a591ef-1877-4642-a219-7f4ab10c8d82.png)

## Where am I using this?

I am running an aarch64 NixOS image in UTM on an Apple M1 Max laptop.

```console
[fktkrt@virtan1x:~/projects/bpf]$ nix-info -m
 - system: `"aarch64-linux"`
 - host os: `Linux 5.15.62, NixOS, 22.05 (Quokka), 22.05.2720.058de381857`
 - multi-user?: `yes`
 - sandbox: `yes`
 - version: `nix-env (Nix) 2.8.1`
 - channels(root): `"nixos-22.05"`
 - channels(fktkrt): `"home-manager-22.05.tar.gz"`
 - nixpkgs: `/nix/var/nix/profiles/per-user/root/channels/nixos`
```
## Workflow

I am using `home-manager`, which has a `dev.nix` module similar to this:

```nix
{ pkgs, ... }:

{
  services.lorri.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
```

Then, I have this folder structure for my various projects:

```console
projects/
├── azure
├── aws
└── bpf
│   ├── bcc
│   ├── libbpf-bootstrap
│   └── shell.nixྴ
├── k8s-local
├── field
└── hello
```

In `shell.nix`, I can list all the required dependencies for BPF related tasks, e.g.:

```nix
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
```

Since I have `lorri`, I can just go into the `bpf/` folder and build my dev env like this:

```console
[fktkrt@virtan1x:~]$ cd projects/bpf/
[fktkrt@virtan1x:~/projects/bpf]$ lorri shell
lorri: building environment............................. done
(lorri)
```

Now, I have all the tools listed above. If I `exit`, I won't have the packages installed, only my clean system.

