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
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "profile";
            nativeBuildInputs = with pkgs; [
              resvg
              pretendard
            ];
            src = ./.;

            buildPhase = ''
              runHook preBuild
              ${builtins.concatStringsSep "\n" (
                map
                  (dim: ''
                    resvg profile.svg profile-${dim}.png -w ${dim} -h ${dim} \
                      --skip-system-fonts \
                      --font-family=Pretendard \
                      --use-font-file=${pkgs.pretendard}/share/fonts/opentype/Pretendard-Regular.otf
                  '')
                  [
                    "16"
                    "250"
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
