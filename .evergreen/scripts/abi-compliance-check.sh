#!/usr/bin/env bash

set -o errexit

# create all needed directories
mkdir abi-compliance
mkdir abi-compliance/changes-install
mkdir abi-compliance/latest-release-install
mkdir abi-compliance/dumps

python ./build/calc_release_version.py --next-minor >VERSION_CURRENT
python ./build/calc_release_version.py --next-minor -p >VERSION_RELEASED

declare newest current
newest="$(cat VERSION_RELEASED)"
current="$(cat VERSION_CURRENT)"

declare working_dir
working_dir="$(pwd)"

export PATH
PATH="${working_dir:?}/install/bin:${PATH:-}"

# build the current changes
env \
  CFLAGS="-g -Og" \
  EXTRA_CONFIGURE_FLAGS="-DCMAKE_INSTALL_PREFIX=./abi-compliance/changes-install" \
  .evergreen/scripts/compile.sh

# checkout the newest release
git checkout "tags/${newest}" -f

declare compile_script=".evergreen/scripts/compile.sh"
if [[ ! -f "${compile_script}" ]]; then
  # Compatibility: remove once latest release contains relocated script.
  compile_script=".evergreen/compile.sh"
fi

# build the newest release
env \
  CFLAGS="-g -Og" \
  EXTRA_CONFIGURE_FLAGS="-DCMAKE_INSTALL_PREFIX=./abi-compliance/latest-release-install" \
  bash "${compile_script}"

# check for abi compliance. Generates HTML Reports.
cd abi-compliance

cat >|old.xml <<DOC
<version>${newest}</version>
<headers>
$(pwd)/latest-release-install/include/libmongoc-1.0/mongoc/mongoc.h
$(pwd)/latest-release-install/include/libbson-1.0/bson/bson.h
</headers>
<libs>$(pwd)/latest-release-install/lib</libs>
DOC

cat >|new.xml <<DOC
<version>${current}</version>
<headers>
$(pwd)/changes-install/include/libmongoc-1.0/mongoc/mongoc.h
$(pwd)/changes-install/include/libbson-1.0/bson/bson.h
</headers>
<libs>$(pwd)/changes-install/lib</libs>
DOC

# Allow task to upload the HTML report despite failed status.
if ! abi-compliance-checker -lib mongo-c-driver -old old.xml -new new.xml; then
  : # CDRIVER-5930: re-enable task failure once 2.0.0 is released.
  # declare status
  # status='{"status":"failed", "type":"test", "should_continue":true, "desc":"abi-compliance-checker emitted one or more errors"}'
  # curl -sS -d "${status:?}" -H "Content-Type: application/json" -X POST localhost:2285/task_status || true
fi
