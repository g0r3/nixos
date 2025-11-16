{ pkgs, ... }:
{
  system.userActivationScripts.zshrc = "touch .zshrc";

  programs = {
    zsh = {
      enable = true;
      enableCompletion = false;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      histSize = 10000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
      ];
      zsh-autoenv.enable = true;
      # zplug = {
      #   enable = true;
      #   plugins = [
      #     { name = "zsh-users/zsh-autosuggestions"; }
      #     { name = "zsh-users/zsh-syntax-highlighting"; }
      #     { name = "zsh-users/zsh-completions"; }
      #     { name = "zsh-users/zsh-history-substring-search"; }
      #     { name = "unixorn/warhol.plugin.zsh"; }
      #   ];
      # };
      shellAliases = {
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
        # Only do `nix flake update` if flake.lock hasn't been updated within an hour
        # deploy-nix = "f() { if [[ $(find . -mmin -60 -type f -name flake.lock | wc -c) -eq 0 ]]; then nix flake update; fi && deploy .#$1 --remote-build -s --auto-rollback false && rsync -ax --delete ./ $1:/etc/nixos/ };f";
        # git
        gs = "git status";
        # gc = "f() { git commit -m \"$1\"}";
        gp = "git push origin HEAD";
        gd = "git diff";
        ga = "git add";
        gl = "git log";
        # nvim
        vim = "nvim";
        # nixos
        ne = "pushd > /dev/null; cd $HOME/git/nixos; vim; popd > /dev/null";
        nr = "sudo nixos-rebuild switch --flake $HOME/git/nixos/#desktop";
        ns = "nix-shell";
        # gemini
        g = "gemini";
        # convenience
        mip = "curl ip.me";
      };

      # Lets keep this for later. Needs Home Manager
      # initContent = ''
      #   # Cycle back in the suggestions menu using Shift+Tab
      #   bindkey '^[[Z' reverse-menu-complete
      #
      #   bindkey '^B' autosuggest-toggle
      #   # Make Ctrl+W remove one path segment instead of the whole path
      #   WORDCHARS=''${WORDCHARS/\/}
      #
      #   # Highlight the selected suggestion
      #   zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      #   zstyle ':completion:*' menu yes=long select
      #
      #     export EDITOR=nvim || export EDITOR=vim
      #     export LANG=en_US.UTF-8
      #     export LC_CTYPE=en_US.UTF-8
      #
      #     source $ZPLUG_HOME/repos/unixorn/warhol.plugin.zsh/warhol.plugin.zsh
      #     bindkey '^[[A' history-substring-search-up
      #     bindkey '^[[B' history-substring-search-down
      #
      #     if command -v motd &> /dev/null
      #     then
      #       motd
      #     fi
      #     bindkey -e
      # '';
    };
  };
  environment.systemPackages = with pkgs; [
    zsh
    wezterm
    oh-my-posh
  ];
}
