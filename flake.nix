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
              resvg profile.svg profile-250.png -w 250 -h 250
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
