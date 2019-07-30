#!/bin/bash -eu

git rev-parse --is-inside-work-tree > /dev/null || (
echo "Please rerun in a git working dir."
exit 1
)

readonly TOP="$(git rev-parse --show-toplevel)"
readonly DOCKER_CONTEXT_DIR="$TOP/Dockerfile.d"
declare ARCH=$(uname -m)
[[ "x86_64"=$ARCH ]] && ARCH="amd64"

readonly array PKGS_COMMON=(
etc/locale.gen
etc/portage/make.conf
etc/portage/package.accept_keywords
etc/portage/package.license
etc/portage/package.use
etc/portage/repos.conf
etc/profile.d/makeopts.sh
var/cache/binpkgs
var/db/repos
)

for path in ${PKGS_COMMON[@]}; do
  if [[ -e /$path ]]; then
    tar c --directory / $path | tar xpv -C "$DOCKER_CONTEXT_DIR/$ARCH"
    tar c --owner=0 --group=0 --directory / $path | tar xpv -C "$DOCKER_CONTEXT_DIR/$ARCH"
  else
    >&2 echo "Not exist: $path"
    continue
  fi
done
