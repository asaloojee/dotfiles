{
  pkgs,
  ...
}: let
  # Keep the compiler, Cargo, Clippy, formatter, and proc-macro server in sync.
  rustToolchain = pkgs.rust-bin.selectLatestNightlyWith (toolchain:
    toolchain.default.override {
      extensions = ["rust-src" "rust-analyzer"];
      targets = ["wasm32-unknown-unknown"];
    });
in {
  environment.systemPackages = [rustToolchain];
}
