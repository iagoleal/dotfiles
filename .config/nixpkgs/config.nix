{
  allowUnfree = true;

  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "my-packages";

      paths = [
        # ~ Programming environments ~ #
        idris2
        luajitPackages.fennel
        chez
        racket-minimal

        # ~ CLI tooling ~ #
        fzf
        pistol
        ripgrep
        ueberzug
        w3m
        cloc       # count lines of source code (better than wc)
        direnv     # Allows activation of of an environment per dir (e.g., auto nix-shell)
        nix-direnv # Better direnv integration with nix (includes caching)

        # ~ Academic life ~ #
        zotero
        pandoc

        # ~ Language Servers ~ #
        sumneko-lua-language-server  # Lua
        pyright                      # Python
        ltex-ls                      # Text: Latex, Markdown, txt
        nodePackages.bash-language-server
        nodePackages.typescript-language-server
        fennel-ls

        # ~ Graphics ~ #
        darktable
        colorpicker
      ];

      pathsToLink = [ "/share" "/bin" ];
      extraOutputsToInstall = [ "man" "doc" ];
    };
  };
}
