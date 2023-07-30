{
  packageOverrides = pkgs: with pkgs; {
    myPackages = pkgs.buildEnv {
      name = "my-packages";

      paths = [
        # Programming environments
        idris2
        luajitPackages.fennel
        chez
        racket-minimal

        # CLI tooling
        fzf
        pistol
        ripgrep
        tmux
        ueberzug
        w3m
        direnv     # Allows activation of of an environment per dir (e.g., auto nix-shell)
        nix-direnv # Better direnv integration with nix (includes caching)


        # Language Servers
        sumneko-lua-language-server
        pyright
        ltex-ls
      ];
    };
  };
}
