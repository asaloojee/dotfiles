{
  config,
  pkgs,
  lib,
  ...
}: {
  enable = true;
  dotDir = "${config.xdg.configHome}/zsh";
  enableCompletion = false; # We handle compinit ourselves

  autosuggestion = {
    enable = true;
    strategy = ["history" "completion"];
  };

  syntaxHighlighting.enable = true;

  plugins = [
    {
      name = "zsh-completions";
      src = pkgs.zsh-completions;
      file = "share/zsh-completions/zsh-completions.zsh";
    }
    {
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
    {
      name = "zsh-history-substring-search";
      src = pkgs.zsh-history-substring-search;
      file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
    }
  ];

  history = {
    size = 10000;
    save = 10000;
    path = "$HOME/.zhistory";
    share = true;
    expireDuplicatesFirst = true;
    ignoreAllDups = true;
    ignoreSpace = true;
  };

  shellAliases = {
    g = "gitui";
    ff = "fastfetch";
    mux = "tmuxinator";

    cc = "claude";
    rebuild = "sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac";
  };

  initContent = ''
    # -----------------------------------------------------------------------
    # Completion System (Cached - Regenerates Once Per Day)
    # -----------------------------------------------------------------------
    autoload -Uz compinit

    if [[ -n ''${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
        compinit
    else
        compinit -C
    fi

    setopt COMPLETE_IN_WORD
    setopt ALWAYS_TO_END
    setopt AUTO_MENU
    setopt AUTO_LIST

    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu select
    zstyle ':completion:*' squeeze-slashes true

    # Additional history options not covered by HM
    setopt HIST_FIND_NO_DUPS
    setopt HIST_VERIFY
    setopt INC_APPEND_HISTORY

    # -----------------------------------------------------------------------
    # Key Bindings
    # -----------------------------------------------------------------------
    bindkey -e
    bindkey "^[[3~" delete-char
    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line

    bindkey ' ' magic-space

    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey '^X^E' edit-command-line

    # History substring search keybindings
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down

    function copy-buffer-to-clipboard() {
        echo -n "$BUFFER" | pbcopy
        zle -M "Copied to clipboard"
    }
    zle -N copy-buffer-to-clipboard
    bindkey '^X^C' copy-buffer-to-clipboard

    # -----------------------------------------------------------------------
    # Transient Prompt (replaces previous prompt with minimal character)
    # -----------------------------------------------------------------------
    TRANSIENT_PROMPT=`starship module character`
    zle-line-init() {
        emulate -L zsh
        [[ $CONTEXT == start ]] || return 0
        while true; do
            zle .recursive-edit
            local -i ret=$?
            [[ $ret == 0 && $KEYS == $'\4' ]] || break
            [[ -o ignore_eof ]] || exit 0
        done
        local saved_prompt=$PROMPT
        local saved_rprompt=$RPROMPT
        PROMPT=$TRANSIENT_PROMPT
        zle .reset-prompt
        PROMPT=$saved_prompt
        if (( ret )); then
            zle .send-break
        else
            zle .accept-line
        fi
        return ret
    }
    zle -N zle-line-init

    # Google Cloud SDK completions
    if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
        source "$HOME/google-cloud-sdk/completion.zsh.inc"
    fi

    # -----------------------------------------------------------------------
    # Plugin Configuration
    # -----------------------------------------------------------------------
    zstyle ':completion:*:git-checkout:*' sort false
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --color=always $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; fi'

    # -----------------------------------------------------------------------
    # Global Aliases (expand anywhere in the command, not just at the start)
    # -----------------------------------------------------------------------
    alias -g NE='2>/dev/null'
    alias -g ND='>/dev/null'
    alias -g NUL='>/dev/null 2>&1'
    alias -g JQ='| jq'

    # Suppress paste highlight flash
    zle_highlight+=(paste:none)

    # -----------------------------------------------------------------------
    # Suffix Aliases
    # -----------------------------------------------------------------------
    alias -s md=bat
    alias -s txt=bat
    alias -s log=bat
    alias -s json=jless
    alias -s py='$EDITOR'
    alias -s js='$EDITOR'
    alias -s ts='$EDITOR'
    alias -s tsx='$EDITOR'
    alias -s jsx='$EDITOR'
    alias -s nix='$EDITOR'
    alias -s html=open

    # -----------------------------------------------------------------------
    # Functions
    # -----------------------------------------------------------------------
    function gp() {
        git add -A && git commit -m "''${*:-update}" && git push
    }

    function gr() {
        local root=$(command git rev-parse --show-toplevel 2>/dev/null)
        if [[ -n "$root" ]]; then
            builtin cd "$root"
        else
            echo "Not in a git repository"
            return 1
        fi
    }
  '';
}
