{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
	  inherit (pkgs.texlive) scheme-full;
      };
   in rec {
      packages = {
	document = pkgs.stdenvNoCC.mkDerivation rec {
	  name = "latex-demo";
	  src = self;
	  buildInputs = [ pkgs.coreutils tex ];
	  phases = ["unpackPhase" "buildPhase" "installPhase" ];
	  buildPhase = ''
	    export PATH="${pkgs.lib.makeBinPath buildInputs}";
	    mkdir -p .cache/texmf-var
	    env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
		pdflatex main.tex
	  '';
	  installPhase = ''
	    mkdir -p $out
	    cp main.pdf $out/
	  '';
	};
      };
      devShell = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive tex ];
        buildInputs = [ ];
      };
      defaultPackage = packages.document;
    });
}
