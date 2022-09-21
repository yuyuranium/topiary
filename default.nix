{ pkgs, crane, nix-filter }:
let
  craneLib = crane.mkLib pkgs;

  commonArgs = {
    src = nix-filter.lib.filter {  
      root = ./.;
      include = [
        "benches"
        "Cargo.lock"
        "Cargo.toml"
        "languages"
        "src"
        "tests"
      ];
    };

    nativeBuildInputs = [ pkgs.libiconv ];
  };

  cargoArtifacts = craneLib.buildDepsOnly (commonArgs);
in
{
  clippy = craneLib.cargoClippy (commonArgs // {
    inherit cargoArtifacts;
    cargoClippyExtraArgs = "--all-targets -- --deny warnings";
  });

  benchmark = craneLib.buildPackage (commonArgs // {
    inherit cargoArtifacts;
    cargoTestCommand = "cargo bench --profile release";
  });

  app = craneLib.buildPackage (commonArgs // {
    inherit cargoArtifacts;
  });
}