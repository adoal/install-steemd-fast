#!/bin/bash
#
# Compile & Install steem, speeded up with Ninja
# -- by adoal
#
# Original work bu xiaohui:
#
# Compile & Install steem. 
# Requirements:
#  MEM: 4GB
#  OS : Ubuntu 16.04 LTS x64
#
# https://steemit.com/@xiaohui
# https://www.xiaohui.com
#

# Upgrade and install requires
sudo apt-get -y update && sudo apt-get -y upgrade && \
sudo apt-get -y install git cmake g++ python-dev autotools-dev libicu-dev build-essential libbz2-dev libboost-all-dev libssl-dev libncurses5-dev doxygen libreadline-dev dh-autoreconf screen tree ninja-build

# remove old installation
rm -rf steem
rm -rf steemd
mkdir steemd

# get codes from git, compile
git clone https://github.com/steemit/steem
cd steem && git checkout master && git submodule update --init --recursive
mkdir build
(cd build && cmake -G Ninja -DCMAKE_BUILD_TYPE=Release -DLOW_MEMORY_NODE=ON .. && cmake --build .)

# install new binaries
cp build/programs/steemd/steemd ../steemd/
cp build/programs/cli_wallet/cli_wallet ../steemd/
cd ..

# download blockchain from steemitup.eu
cd steemd/
wget http://www.steemitup.eu/witness_node_data_dir.tar.gz
tar -zxvf witness_node_data_dir.tar.gz
rm witness_node_data_dir.tar.gz

# apply config.ini if available
if [ -f ../config.ini ]
then
    cp -fv ../config.ini witness_node_data_dir/
    # make a backup
    cp witness_node_data_dir/config.ini witness_node_data_dir/config.ini.bak
    # set rpc-endpoint and enable-stale-production parameters
    sed -i "s/# rpc-endpoint =/rpc-endpoint = 127.0.0.1:8091\n# rpc-endpoint =/g" witness_node_data_dir/config.ini
    sed -i "s/enable-stale-production = false/enable-stale-production = true\n#enable-stale-production = false/g" witness_node_data_dir/config.ini
fi

# prep the local blockchain
./steemd --replay



