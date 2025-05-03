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

    initExtra = ''
      history-substring-search-up-prefixed(){
        HISTORY_SUBSTRING_SEARCH_PREFIXED=1 history-substring-search-up
      }
      history-substring-search-down-prefixed(){
        HISTORY_SUBSTRING_SEARCH_PREFIXED=1 history-substring-search-down
      }

      zle -N history-substring-search-up-prefixed
      zle -N history-substring-search-down-prefixed

      bindkey -r "^["
      bindkey ";5C" forward-word
      bindkey ";5D" backward-word
      bindkey ";5A" history-substring-search-up-prefixed
      bindkey ";5B" history-substring-search-down-prefixed
    '';

    shellAliases = {
      ll = "ls -lha";
    };
  };
}