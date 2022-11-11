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

        # Language Servers
        sumneko-lua-language-server
        pyright
        ltex-ls
      ];
    };
  };
}
