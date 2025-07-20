{
  description = "ChainedSocial - Decentralized social media platform on Internet Computer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # DFX version
        dfxVersion = "0.27.0";
        
        # Node.js version
        nodeVersion = "22";
        
        # Python version
        pythonVersion = "3.11";
        
        # Custom DFX package
        dfx = pkgs.stdenv.mkDerivation {
          pname = "dfx";
          version = dfxVersion;
          src = pkgs.fetchurl {
            url = "https://github.com/dfinity/dfx/releases/download/${dfxVersion}/dfx-${dfxVersion}-x86_64-unknown-linux-gnu.tar.gz";
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will be updated by nix-prefetch-url
          };
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/bin
            cp dfx $out/bin/
            chmod +x $out/bin/dfx
          '';
          postFixup = ''
            wrapProgram $out/bin/dfx --set PATH ${pkgs.lib.makeBinPath [ pkgs.curl ]}
          '';
        };
        
        # Development environment
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # DFX and ICP tools
            dfx
            
            # Node.js ecosystem
            nodejs_20
            nodePackages.npm
            
            # Python ecosystem
            python311
            python311Packages.pip
            
            # Development tools
            git
            curl
            wget
            unzip
            
            # Build tools
            gcc
            gnumake
            
            # Additional tools
            jq
            ripgrep
          ];
          
          shellHook = ''
            echo "🚀 ChainedSocial Development Environment"
            echo "📦 DFX version: $(dfx --version)"
            echo "📦 Node.js version: $(node --version)"
            echo "📦 npm version: $(npm --version)"
            echo "📦 Python version: $(python3 --version)"
            echo ""
            echo "🔧 Available commands:"
            echo "  dfx --version     # Check DFX installation"
            echo "  npm install       # Install frontend dependencies"
            echo "  python3 -m pip    # Python package management"
            echo ""
          '';
        };
        
      in {
        # Development shell
        devShells.default = devShell;
        
        # Packages
        packages = {
          dfx = dfx;
          default = dfx;
        };
        
        # Apps
        apps = {
          dfx = {
            type = "app";
            program = "${dfx}/bin/dfx";
          };
        };
      }
    );
} 