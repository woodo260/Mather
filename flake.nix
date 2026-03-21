{
  description = "Mather Rails dev environment";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ruby = pkgs.ruby_3_3;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            ruby
            pkgs.bundler
            pkgs.sqlite
            pkgs.libyaml
            pkgs.pkg-config
            pkgs.git
            pkgs.nodejs_20
            pkgs.foreman
          ];

          shellHook = ''
            export BUNDLE_PATH=vendor/bundle
            export RAILS_ENV=development
            # Point tailwindcss-ruby gem to our steam-run wrapper so the
            # pre-compiled binary can run in the FHS environment on NixOS.
            export TAILWINDCSS_INSTALL_DIR=$(pwd)/nix-support

            echo "Ruby: $(ruby --version)"
            echo ""
            echo "Run 'bundle install' if needed, then 'foreman start -f Procfile.dev' to start the dev server."
          '';
        };

        apps.dev = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "mather-dev" ''
            export BUNDLE_PATH=vendor/bundle
            export RAILS_ENV=development
            cd ${toString ./.}
            ${pkgs.foreman}/bin/foreman start -f Procfile.dev
          '';
        };
      }
    );
}
