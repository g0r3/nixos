{ pkgs, ... }:
{
  programs.nix-ld.enable = true; # Make the plugins compatible with nixos paths
  environment.systemPackages = with pkgs; [
    lua5_1
    lua51Packages.luarocks
    nodejs
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        debugpy
      ]
    ))
    ruff # also needed for git precommit
    wl-clipboard
    ripgrep
    nixfmt-rfc-style
    jd-diff-patch
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
