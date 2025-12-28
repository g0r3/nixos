{
  pkgs,
  lib,
  isNixos,
  isDarwin,
  ...
}:
let
  myAliases = {
    l = "ls -lh --color=auto";
    ls = "ls --color=auto";
    ll = "ls -lah --color=auto";
    la = "ls --color -lha";
    df = "df -h";
    du = "du -ch";
    ipp = "curl ipinfo.io/ip";
    aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
    mkdir = "mkdir -p";
    grep = "grep --color=auto";
    egrep = "fgrep --color=auto";
    fgrep = "fgrep --color=auto";
    e = "exit";
    # git
    gs = "git status";
    gp = "git push origin HEAD";
    gd = "git diff";
    ga = "git add";
    gl = "git log";
    # nvim
    vim = "nvim";
    # nixos
    ne = "pushd > /dev/null; cd $HOME/git/nixos; vim; popd > /dev/null";
    nr = "sudo nixos-rebuild switch --flake $HOME/git/nixos/#$(hostname)";
    ns = "nix-shell";
    nsp = "nix search package";
    # gemini
    g = "gemini";
    # convenience
    mip = "curl ip.me";
  };
in
{
  config = lib.mkMerge [
    (lib.optionalAttrs isDarwin {
      programs.zsh = {
        enableSyntaxHighlighting = true;
        enableAutosuggestions = true;
        interactiveShellInit = ''
          setopt HIST_IGNORE_ALL_DUPS
          # Manually enable autosuggestions if the option doesn't exist
          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        '';
      };
    })
    (lib.optionalAttrs isNixos {
      system.userActivationScripts.zshrc = "touch .zshrc";

      programs.zsh = {
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        setOptions = [ "HIST_IGNORE_ALL_DUPS" ];
        zsh-autoenv.enable = true;
      };
    })
    {
      environment.shellAliases = myAliases;

      programs.zsh = {
        enable = true;
        enableCompletion = false;
        histSize = 10000;
        histFile = "$HOME/.zsh_history";
      };

      environment.systemPackages = with pkgs; [
        zsh
        wezterm
        oh-my-posh
      ];
    }
  ];
}
