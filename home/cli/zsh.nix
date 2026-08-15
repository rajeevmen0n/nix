{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh-history-substring-search
  ];

  programs.zsh = {
    enable = true;
    
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history.save = 100000;
    historySubstringSearch = {
      enable = true;
      searchUpKey = "$key[Up]";
      searchDownKey = "$key[Down]";
    };

    initContent = ''
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=none
      export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=none

      history-substring-search-up-prefixed(){
        HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 HISTORY_SUBSTRING_SEARCH_PREFIXED=1 history-substring-search-up
      }
      history-substring-search-down-prefixed(){
        HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1 HISTORY_SUBSTRING_SEARCH_PREFIXED=1 history-substring-search-down
      }

      zle -N history-substring-search-up-prefixed
      zle -N history-substring-search-down-prefixed

      bindkey -r "^["
      bindkey ";5C" forward-word
      bindkey ";5D" backward-word
      bindkey ";5A" history-substring-search-up-prefixed
      bindkey ";5B" history-substring-search-down-prefixed

      if [ -f ~/.cache/wal/sequences ]; then
        (cat ~/.cache/wal/sequences &)
      fi

      # Ensure cursor is always restored to blinking line on prompt and after program exits (e.g. neovim)
      _set_cursor_beam() {
        printf '\033[5 q'
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _set_cursor_beam
      _set_cursor_beam
    '';

    shellAliases = {
      ll = "ls -lha";
    };
  };
}
