{
  description = "ChainedSocial - Decentralized social media platform on Internet Computer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Development environment with minimal dependencies
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
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
            echo "📦 Python version: $(python3 --version)"
            echo ""
            echo "🔧 Available commands:"
            echo "  python3 -m pip    # Python package management"
            echo "  dfx --version     # Check DFX installation (if installed)"
            echo ""
            echo "💡 Note: Node.js and DFX will be installed via official installers when needed"
            echo "   This avoids compilation issues in Nix"
            echo ""
          '';
        };
        
      in {
        # Development shell
        devShells.default = devShell;
      }
    );
} 