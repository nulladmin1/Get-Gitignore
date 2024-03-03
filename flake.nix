{
  description = "randimg";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = 
      pkgs.mkShell
        {
          buildInputs = with pkgs; [
            clang
            llvmPackages.bintools
            rustup
            openssl
            dbus
          ];
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
          dbus = pkgs.dbus;
          DBUS_PATH = "{dbus}";
          RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages.libclang.lib ];
          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
          '';
          RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') []);
          BINDGEN_EXTRA_CLANG_ARGS = (builtins.map (a: ''=I"${a}/include'') []);
        };
  };
}
