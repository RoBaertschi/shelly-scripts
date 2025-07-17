# ml2 sts=2 ts=2 ml2

{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
    version = builtins.substring 0 8 lastModifiedDate;
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system; overlays = [ self.overlay ];});
  in {
    overlay = final: prev: {
      shelly = with final; stdenv.mkDerivation {
        name = "shelly-${version}";
        unpackPhase = ":";
        buildPhase = ":";
        installPhase = ''
          mkdir -p $out/bin
          cp ${./tmux-sessionizer} $out/bin/tmux-sessionizer
          cp ${./tmux-sessionizer-clone} $out/bin/tmux-sessionizer-clone
          cp ${./rfv} $out/bin/rfv
          cp ${./git-helper} $out/bin/git-helper
          cp ${./git-start} $out/bin/git-start
          cp ${./git-done} $out/bin/git-done
          '';
      };
    };
    packages = forAllSystems(system: {
      inherit (nixpkgsFor.${system}) shelly;
    });
    nixosModules.shelly = {pkgs, ...}:
      {
          nixpkgs.overlays = [self.overlay];
          environment.systemPackages = [ pkgs.shelly pkgs.fzf pkgs.tmux pkgs.ripgrep pkgs.bat pkgs.gh pkgs.jq pkgs.ruby ];
      };
    defaultPackage = forAllSystems (system: self.packages.${system}.shelly);
  };
}
