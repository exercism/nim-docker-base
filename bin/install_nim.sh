#!/bin/bash

set -ex

readonly ARCHIVE_FILENAME='nim.tar.xz'
readonly NIM_VERSION='2.2.4'
readonly BUILD_DIR='/build/nim'
readonly INSTALL_DIR='/nim/'
mkdir -p "${BUILD_DIR}"

(
  cd "${BUILD_DIR}" || exit
  curl -sSfL -o "${ARCHIVE_FILENAME}" "https://nim-lang.org/download/nim-${NIM_VERSION}.tar.xz"
  tar --strip-components=1 -xf "${ARCHIVE_FILENAME}"
  sh build.sh
  rm -r c_code "${ARCHIVE_FILENAME}"

  bin/nim c --skipUserCfg --skipParentCfg koch.nim
  # -d:danger turns off the compiler's own runtime checks, as in the C sources
  # that ship in Nim's release archive. It makes each compile about 15% faster.
  ./koch boot -d:danger -d:leanCompiler

  # Profile-guided optimisation: build a compiler that records which code it
  # runs, compile a typical exercise with it, then rebuild the compiler with
  # gcc using that profile. This makes each compile about 10% faster again.
  readonly PGO_FLAGS='-d:danger -d:leanCompiler --hints:off --nimcache:/build/pgo-cache'
  bin/nim c ${PGO_FLAGS} --passC:-fprofile-generate --passL:-fprofile-generate -o:bin/nim-pgo compiler/nim.nim
  bin/nim-pgo c --threads:off --hints:off -o:/build/pgo-training /build/pgo_training.nim
  bin/nim c ${PGO_FLAGS} --passC:-fprofile-use --passC:-fprofile-partial-training --passC:-Wno-missing-profile -o:bin/nim compiler/nim.nim
  rm bin/nim-pgo

  mkdir -p "${INSTALL_DIR}"
  mv bin config lib "${INSTALL_DIR}"
)

rm -r "${BUILD_DIR}" /build/pgo-cache /build/pgo-training
