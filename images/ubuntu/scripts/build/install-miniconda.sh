#!/bin/bash -e
################################################################################
##  File:  install-miniconda.sh
##  Desc:  Install miniconda
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh

# Install Miniconda
if [ ! -d /usr/share/miniconda ]; then
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
        && chmod +x miniconda.sh \
        && ./miniconda.sh -b -p /usr/share/miniconda \
        && rm miniconda.sh
else
    echo "Miniconda already installed, skipping."
fi

CONDA=/usr/share/miniconda
set_etc_environment_variable "CONDA" "${CONDA}"

ln -sfn $CONDA/bin/conda /usr/bin/conda

invoke_tests "Tools" "Conda"
