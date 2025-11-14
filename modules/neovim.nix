{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nodejs
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
