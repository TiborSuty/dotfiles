{ lib, buildNpmPackage, fetchurl, jq, nodejs_24, stdenv, autoPatchelfHook }:

buildNpmPackage rec {
  pname = "nx";
  version = "23.2.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/nx/-/nx-${version}.tgz";
    hash = "sha512-QOgM7EcJ6gvLKZ3Azno7wdoXXhRhZHbRDN79gCmGXsBxH9WBXCeSy3DyGdee/d5Fa6GnxVOgwKTCx8l0eA+vHw==";
  };

  nodejs = nodejs_24;
  npmDepsHash = "sha256-0w5fIYe3t3Uofec3uH7IQrf112j9sCbifNPh0ux08nQ=";

  # The npm release contains compiled JavaScript and platform-specific native
  # bindings. Lock runtime dependencies; do not run networked postinstall hooks.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
    cp ${./package-lock.json} package-lock.json
  '';
  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  meta = {
    description = "Nx CLI for monorepo task orchestration";
    homepage = "https://nx.dev";
    license = lib.licenses.mit;
    mainProgram = "nx";
    platforms = [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ];
  };
}
