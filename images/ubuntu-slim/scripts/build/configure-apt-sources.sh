#!/bin/bash -e
################################################################################
##  File:  configure-apt-sources.sh
##  Desc:  Configure apt sources with failover from Azure to Ubuntu archives.
################################################################################

source $HELPER_SCRIPTS/os.sh

touch /etc/apt/apt-mirrors.txt

printf "http://azure.archive.ubuntu.com/ubuntu/\tpriority:1\n" | tee -a /etc/apt/apt-mirrors.txt
printf "https://archive.ubuntu.com/ubuntu/\tpriority:2\n" | tee -a /etc/apt/apt-mirrors.txt
printf "https://security.ubuntu.com/ubuntu/\tpriority:3\n" | tee -a /etc/apt/apt-mirrors.txt

if is_ubuntu24 && [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    sed -i 's|http://archive\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list.d/ubuntu.sources
    sed -i 's|https://archive\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list.d/ubuntu.sources
    sed -i 's|http://security\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list.d/ubuntu.sources
    sed -i 's|https://security\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list.d/ubuntu.sources
else
    if [ -f /etc/apt/sources.list ]; then
        sed -i 's|http://archive\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list
        sed -i 's|https://archive\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list
        sed -i 's|http://security\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list
        sed -i 's|https://security\.ubuntu\.com/ubuntu/|mirror+file:/etc/apt/apt-mirrors.txt|g' /etc/apt/sources.list
    fi
fi
