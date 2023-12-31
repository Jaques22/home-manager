{ config, pkgs, lib, ... }:
#with import <nixpkgs> {};
{
  home.username = "ben";
  home.homeDirectory = "/var/home/ben";

  xdg.userDirs = {
      enable = true;
      templates = "${config.home.homeDirectory}/.config/Templates";
    };

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;

  home.packages = [
     (pkgs.nerdfonts.override { fonts = [ "RobotoMono" ]; })
     pkgs.roboto
     pkgs.eza
     pkgs.binutils

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.file = {
    ".config/waybar".source = dotfiles/.config/waybar;
    ".config/wofi".source = dotfiles/.config/wofi;
    ".config/wofi-logout".source = dotfiles/.config/wofi-logout;
    ".config/kitty".source = dotfiles/.config/kitty;
    ".config/hypr".source = dotfiles/.config/hypr;
#    ".config/nvim".source = fetchgit {
#	url = "https://github.com/NvChad/NvChad.git";
#	deepClone = true;
#	fetchSubmodules = true;
#	rev = "v2.0";
#	sha256 = "67c520c402af0b6e44593fba53713c46340814dada0ea9470937228edff6d7dd";
#    };
    
    # dir must be writable for ranger to run
    # ".config/ranger".source = dotfiles/.config/ranger;
    ".config/rclone".source = dotfiles/.config/rclone;
    ".config/swayidle".source = dotfiles/.config/swayidle;
    ".config/swaylock".source = dotfiles/.config/swaylock;
    ".config/swaync".source = dotfiles/.config/swaync;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  # or
  #  /etc/profiles/per-user/ben/etc/profile.d/hm-session-vars.sh
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISIAL = "nvim";
    PAGER = "/usr/bin/less";
    PATH = "$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH";
    RANGER_LOAD_DEFAULT_RC="false";
    HMDOTS = "$HOME/.config/home-manager/dotfiles";
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  programs.neovim = {
      defaultEditor = true;
    };

  programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      autocd = true;
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        size = 500;
        ignoreDups = true;
      };
      localVariables = {
          PATH = "$HOME/.nix-profile/bin:$HOME/.local/bin:$PATH";
        };

      shellAliases = {
        hconf="nvim $HMDOTS/.config/hypr/hyprland.conf";
        hmconf="nvim ~/.config/home-manager/home.nix";
        hmdir="cd ~/.config/home-manager/";
        tbxe="toolbox enter";
        ls="eza --icons --group-directories-first --width=80 -a";
        ll="eza --icons --group-directories-first --width=80 --no-filesize -alo";
        };
      
      initExtraBeforeCompInit = "zstyle :compinstall filename '/var/home/ben/.zshrc' ";

      initExtra = ''
      zstyle ':completion:*' menu select=4

      # Set prompt
      setopt PROMPT_SUBST
      PROMPT='%B%n@%m%b %~/ %# '
      
      # Bind ctrl+arrows 
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Bind Home and End keys
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line

      bindkey "^L" clear-screen
      
      # Ensures auto completion doesn't break shell in git repos 
      __git_files () { 
    _wanted files expl 'local files' _files     
      }
       
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End nix

      export GPG_TTY=$(tty)
    '';
    };

    home.activation = {
      # Reload hyprland after home-manager files have been written 
      reloadHyprland = lib.hm.dag.entryAfter ["writeBoundary"] ''
        echo "Reloading Hyprland...";
        # change to $\{pkgs.hyprland}/bin/hyprctl ? for nixos 
        /usr/bin/hyprctl reload > /dev/null;
        echo "Hyprland reloaded successfully";
      '';};
}
