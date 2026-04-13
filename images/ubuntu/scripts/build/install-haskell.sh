#!/bin/bash -e
################################################################################
##  File:  install-haskell.sh
##  Desc:  Install Haskell, GHCup, Cabal and Stack
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh

# Any nonzero value for non-interactive installation
export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
export BOOTSTRAP_HASKELL_INSTALL_NO_STACK_HOOK=1
export GHCUP_INSTALL_BASE_PREFIX=/usr/local
export BOOTSTRAP_HASKELL_GHC_VERSION=0
export GHCUP_CURL_OPTS="--retry 5 --retry-delay 5 --retry-connrefused --retry-all-errors"
ghcup_bin=$GHCUP_INSTALL_BASE_PREFIX/.ghcup/bin
set_etc_environment_variable "BOOTSTRAP_HASKELL_NONINTERACTIVE" $BOOTSTRAP_HASKELL_NONINTERACTIVE
set_etc_environment_variable "GHCUP_INSTALL_BASE_PREFIX" $GHCUP_INSTALL_BASE_PREFIX
set_etc_environment_variable "GHCUP_CURL_OPTS" "$GHCUP_CURL_OPTS"

retry_ghcup_install() {
    local tool=$1
    local version=$2
    local attempts=5
    local attempt=1
    while true; do
        if ghcup install "$tool" "$version"; then
            return 0
        fi
        if [ $attempt -ge $attempts ]; then
            return 1
        fi
        echo "ghcup install $tool $version failed, retry $attempt/$attempts..."
        sleep 10
        attempt=$((attempt + 1))
    done
}

# Install GHCup
curl --proto '=https' --tlsv1.2 -fsSL https://get-ghcup.haskell.org | sh > /dev/null 2>&1 || true
export PATH="$ghcup_bin:$PATH"
prepend_etc_environment_path $ghcup_bin

available_versions=$(ghcup list -t ghc -r | grep -v "prerelease" | awk '{print $2}')

# Install latest Haskell Major.Minor version
major_minor_versions=$(echo "$available_versions" | cut -d"." -f 1,2 | uniq | tail -n1)
for major_minor_version in $major_minor_versions; do
    full_version=$(echo "$available_versions" | grep "$major_minor_version." | tail -n1)
    echo "install ghc version $full_version..."
    retry_ghcup_install ghc "$full_version"
    ghcup set ghc $full_version
done

echo "install cabal..."
retry_ghcup_install cabal latest

chmod -R 777 $GHCUP_INSTALL_BASE_PREFIX/.ghcup
if [ ! -e /etc/skel/.ghcup ]; then
    ln -s $GHCUP_INSTALL_BASE_PREFIX/.ghcup /etc/skel/.ghcup
fi

# Install the latest stable release of haskell stack
if ! command -v stack >/dev/null 2>&1; then
    curl -fsSL https://get.haskellstack.org/ | bash
else
    echo "Stack already installed, skipping."
fi

invoke_tests "Haskell"
