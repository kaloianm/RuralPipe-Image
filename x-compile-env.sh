#/usr/bin/bash

X_COMPILE_ENV_NAME=$1
X_COMPILE_ENV_ROOT=$HOME/x-tools/$X_COMPILE_ENV_NAME
echo "Executing command for cross-compile environment $X_COMPILE_ENV_NAME ..."
echo "Binary path root $X_COMPILE_ENV_ROOT"
shift

export PATH="$X_COMPILE_ENV_ROOT/bin:$PATH"

X_COMPILE_TOOLS_PREFIX="$X_COMPILE_ENV_ROOT/bin/$X_COMPILE_ENV_NAME-"

export X_COMPILE_STAGING_PREFIX="$(pwd)/staging"
export CC="${X_COMPILE_TOOLS_PREFIX}gcc"
export CXX="${X_COMPILE_TOOLS_PREFIX}g++"
export LD="${X_COMPILE_TOOLS_PREFIX}ld"
export AR="${X_COMPILE_TOOLS_PREFIX}ar"
export RANLIB="${X_COMPILE_TOOLS_PREFIX}ranlib"
export READELF="${X_COMPILE_TOOLS_PREFIX}readelf"

mkdir -p ./staging && mkdir -p ./build && cd ./build && exec $SHELL