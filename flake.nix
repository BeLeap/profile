{
  description = "personal profile picture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs }:
        rec {
          danjo = pkgs.stdenvNoCC.mkDerivation {
            name = "danjo";
            version = "1.1";

            src = pkgs.fetchurl {
              url = "https://cdn.jsdelivr.net/gh/fonts-archive/Danjo/Danjo.otf";
              name = "Danjo.otf";
              hash = "sha256-zBEXy3RoKrv5BAGk79mmqdpeX90QwzZmdb3qyfOfmiw=";
            };

            unpackPhase = ''
              runHook preUnpack
              cp $src Danjo.otf
              runHook postUnpack
            '';

            installPhase = ''
              runHook preInstall
              install -Dm644 Danjo.otf $out/share/fonts/opentype/Danjo-bold.otf
              runHook postInstall
            '';
          };
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "profile";
            nativeBuildInputs = with pkgs; [
              resvg
              danjo
            ];
            src = ./.;

            buildPhase = ''
              runHook preBuild
              resvg --list-fonts \
                --skip-system-fonts \
                --font-family=Danjo-bold \
                --use-font-file=${danjo}/share/fonts/opentype/Danjo-bold.otf
              ${builtins.concatStringsSep "\n" (
                map
                  (dim: ''
                    resvg profile.svg profile-${dim}.png -w ${dim} -h ${dim} \
                      --skip-system-fonts \
                      --font-family=Danjo-bold \
                      --use-font-file=${danjo}/share/fonts/opentype/Danjo-bold.otf
                  '')
                  [
                    "16"
                    "64"
                    "250"
                    "512"
                    "1024"
                    "2048"
                  ]
              )}
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              install -Dm655 *.png $out/
              runHook postInstall
            '';
          };
        }
      );
    };
}
