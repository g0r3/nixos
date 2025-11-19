{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
    (python3.withPackages (python-pkgs: with python-pkgs; [
        debugpy
    ]))
    ruff
    stylua
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
