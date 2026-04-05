{pkgs, ...}: {
  enable = true;
  package = pkgs.helix;

  settings = {
    theme = "tokyonight";

    editor = {
      # Ensure true-color rendering (needed for correct Tokyo Night colors in Ghostty)
      true-color = true;

      # Force curly underlines for diagnostics — Ghostty supports them but
      # crossterm's autodetection doesn't always pick up xterm-ghostty's Smulx capability
      undercurl = true;

      # Tint the statusline per mode (NOR/INS/SEL), like lualine in Neovim
      color-modes = true;

      # Show bufferline when multiple buffers are open
      bufferline = "multiple";

      # Absolute line numbers (not relative)
      line-number = "absolute";

      # Cursor shape per mode — Neovim uses bar for insert, Helix defaults to block everywhere
      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      statusline = {
        left = ["mode" "separator" "version-control" "separator" "file-name" "file-modification-indicator" "read-only-indicator" "spinner"];
        center = ["diagnostics"];
        right = ["selections" "separator" "file-type" "separator" "position" "position-percentage"];
        separator = "┃";
        mode = {
          normal = "NOR";
          insert = "INS";
          select = "SEL";
        };
      };

      # Indent guides (equivalent to indent-blankline in LazyVim)
      indent-guides = {
        render = true;
        character = "│";
      };

      # File picker: show hidden files, respect .gitignore (replaces your Telescope config)
      file-picker = {
        hidden = true;
        git-ignore = true;
        git-global = true;
      };

      # Compact diagnostic marker on all affected lines
      end-of-line-diagnostics = "warning";

      # LSP overlays — toggle at runtime with:
      #   :toggle lsp.display-inlay-hints
      #   :toggle lsp.auto-signature-help
      lsp = {
        display-inlay-hints = true;
        auto-signature-help = false;
      };

      # Soft wrap long lines
      soft-wrap.enable = true;
    };
  };

  languages = {
    language = let
      prettier = lang: {
        name = lang;
        auto-format = true;
        formatter = {
          command = "prettier";
          args = ["--single-quote" "--print-width" "100" "--parser" lang];
        };
      };
      prettierWeb = lang: parser: {
        name = lang;
        auto-format = true;
        formatter = {
          command = "prettier";
          args = ["--single-quote" "--print-width" "100" "--parser" parser];
        };
      };
    in [
      (prettier "typescript")
      (prettier "javascript")
      (prettierWeb "tsx" "typescript")
      (prettierWeb "jsx" "javascript")
      (prettier "css")
      (prettier "scss")
      (prettier "html")
      (prettier "json")
      (prettier "yaml")
      (prettier "markdown")
      {
        name = "astro";
        auto-format = true;
      }
      {
        name = "python";
        auto-format = true;
        formatter = {
          command = "ruff";
          args = ["format" "-"];
        };
      }
      {
        name = "nix";
        auto-format = true;
        formatter = {
          command = "alejandra";
          args = ["-"];
        };
      }
      {
        name = "rust";
        auto-format = true;
      }
    ];
  };
}
