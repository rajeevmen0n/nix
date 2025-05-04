{
  vim = {
    globals = {
      netrw_liststyle = 3;
    };

    lineNumberMode = "relative";
    theme.style = "dark";

    options = {
      # tabs & indentation
      tabstop = 4; # 4 spaces for tabs
      shiftwidth = 4; # 4 spaces for indent width
      expandtab = true; # expand tab to spaces
      autoindent = true; # copy indent from current line when starting a new line
      wrap = false;

      # # search settings
      ignorecase = true; # ignore case when searching
      smartcase = true; # assume case-sensitive when mixed case search

      # # terminal color setup
      termguicolors = true;
      signcolumn = "yes"; # show sign column so that text doesn't shift

      # # split windows
      splitright = true; # split vertical window to the right
      splitbelow = true; # split horizontal window to the bottom
    };
  };
}