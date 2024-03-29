# nix-bpf-env
My adhoc dev environment for BPF development on NixOS

![nix-bpf-env](https://user-images.githubusercontent.com/103492698/199709006-bf2f0020-8276-41dd-b807-93a0da6ac234.png)

## Where am I using this?

I am mainly using the flake version of the environment on an aarch64 NixOS image in UTM on an Apple M1 Max laptop.

## Try without installing

The easiest way to try out this and experiment with the environment is to run this command:

```console
nix develop github:krisztianfekete/nix-bpf-env
```
And you can get started hacking (e)BPF right away!

## Default workflow

I am managing my system via `home-manager`, and just using this flake as an experimental ad-hoc environment for BPF research & development.

To build the environment, I can just go to a folder where I have this `flake.nix` and pull up the environment, e.g.:

```console
[fktkrt@virtan1x:~/projects/bpf]$ nix develop

# and all the packages listed will be available, see:
fktkrt@virtan1x:~/projects/bpf]$ clang --version
clang version 14.0.6
Target: aarch64-unknown-linux-gnu
Thread model: posix
InstalledDir: /nix/store/4ycs8pf3i5pv40hzp4bgvjnqdlag1dg5-clang-14.0.6/bin
```

This gives me more flexibility compared to pulling and running the env from github repo directly, e.g. I can make changes on the fly in my local `flake.nix` file. 

> Note: the lorri + direnv workflow is not actively used so I cannot guarantee that it won't break from time to time.

## lorri + direnv version

Originally, I started out with this `lorri` based setup.

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

It is also working on my Intel MBP as well (in a VirtualBox VM), but that is not tested heavily.
The only change required there is to disable `bpftools` in `shell.nix`.

```console
[fktkrt@virtanix:~/nixos-configs]$ nix-info -m
 - system: `"x86_64-linux"`
 - host os: `Linux 5.15.59, NixOS, 22.05 (Quokka), 22.05.2322.92fe622fdfe`
 - multi-user?: `yes`
 - sandbox: `yes`
 - version: `nix-env (Nix) 2.8.1`
 - channels(fktkrt): `"home-manager-22.05.tar.gz"`
 - nixpkgs: `/nix/var/nix/profiles/per-user/root/channels/nixos`
```

### lorri + direnv workflow

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
