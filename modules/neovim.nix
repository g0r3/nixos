{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    lua5_1
    lua51Packages.luarocks
    nodejs
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        debugpy
      ]
    ))
    # ruff
    # stylua
    # lua-language-server
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
