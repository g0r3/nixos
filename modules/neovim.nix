{
  config,
  lib,
  pkgs,
  isNixos,
  isDarwin,
  ...
}:

let
  cfg = config.modules.neovim;
in
{

  options.modules.neovim.enable = lib.mkEnableOption "Whether to enable the Neovim module";

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # --- macOS / Darwin Configuration ---
      (lib.optionalAttrs isDarwin {
        environment.systemPackages = [ pkgs.neovim ];
        environment.variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      })
      # --- Linux / Systemd Configuration ---
      (lib.optionalAttrs isNixos {
        programs.nix-ld.enable = true; # Make the plugins compatible with nixos paths

        environment.systemPackages = [ pkgs.wl-clipboard ];

        programs.neovim = {
          enable = true;
          defaultEditor = true;
          viAlias = true;
          vimAlias = true;
        };
      })
      # --- Common Configuration ---
      {
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
          ripgrep
          # nixfmt
          jd-diff-patch
        ];
      }
    ]
  );
}
