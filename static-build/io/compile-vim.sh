#!/bin/bash
set -e

source /io/env.sh

apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-key 084ECFC5828AB726
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-key 1E9377A2BA9EF27F

echo "deb http://ppa.launchpad.net/george-edison55/cmake-3.x/ubuntu trusty main" | tee /etc/apt/sources.list.d/george-edison55-cmake3-trusty.list
echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu trusty main" | tee /etc/apt/sources.list.d/ubuntu-toolchain-r-test-trusty.list

apt-get -y update

apt-get install -y curl xz-utils cmake3 g++-5 pkg-config autotools-dev automake libtool git gobject-introspection gtk-doc-tools 

mkdir ${DEPS}
mkdir ${TARGET}


mkdir ${DEPS}/ncurses
cd ${DEPS}/ncurses
curl -k https://invisible-island.net/datafiles/release/ncurses.tar.gz -o ncurses.tar.gz
tar zxvf ncurses.tar.gz
cd ncurses-6.3
./configure --disable-shared --enable-static
make
make install

echo "building vim"
cd ${DEPS}
git clone https://github.com/vim/vim.git
cd vim/src
LDFLAGS="-static" ./configure --disable-channel --disable-gpm --disable-gtktest --disable-gui --disable-netbeans --disable-nls --disable-selinux --disable-smack --disable-sysmouse --disable-xsmp --enable-multibyte --with-features=huge --without-x 
make
make install
mkdir -p ${DEPS}/out/vim
cp -r /usr/local/* ${DEPS}/out/vim
strip ${DEPS}/out/bin/vim
