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

# now start building static libraries for tifig

mkdir ${DEPS}/zlib
curl -Ls https://zlib.net/zlib-${VERSION_ZLIB}.tar.xz | xz -d | tar xC ${DEPS}/zlib --strip-components=1
cd ${DEPS}/zlib
./configure --prefix=${TARGET} --static
make install

mkdir ${DEPS}/exif
curl -Ls http://netix.dl.sourceforge.net/project/libexif/libexif/${VERSION_EXIF}/libexif-${VERSION_EXIF}.tar.bz2 | tar xjC ${DEPS}/exif --strip-components=1
cd ${DEPS}/exif
autoreconf -fiv
./configure --prefix=${TARGET} --disable-shared --enable-static
make && make install

mkdir ${DEPS}/jpeg
curl -k -Ls https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${VERSION_JPEG}.tar.gz | tar xzC ${DEPS}/jpeg --strip-components=1
cd ${DEPS}/jpeg
autoreconf -fiv
./configure --prefix=${TARGET} --disable-shared --enable-static --with-jpeg8 --with-turbojpeg
make install

mkdir ${DEPS}/ffmpeg
curl -k -Ls https://github.com/FFmpeg/FFmpeg/archive/n${VERSION_FFMPEG}.tar.gz | tar xzC ${DEPS}/ffmpeg --strip-components=1
cd ${DEPS}/ffmpeg
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-encoders --disable-decoders --enable-decoder=hevc --disable-parsers --enable-parser=hevc \
  --disable-programs --disable-doc --disable-avdevice --disable-avformat --disable-avfilter --disable-indevs --disable-outdevs --disable-cuvid --disable-bsfs
make install

mkdir ${DEPS}/de265
curl -k -Ls https://github.com/strukturag/libde265/archive/refs/tags/v1.0.8.tar.gz | tar xzC ${DEPS}/de265 --strip-components=1
cd ${DEPS}/de265
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static --disable-sherlock265
make install

echo "building libheif"
mkdir ${DEPS}/heif
cd ${DEPS}/heif
git clone https://github.com/strukturag/libheif.git
cd ${DEPS}/heif/libheif
./autogen.sh
./configure --prefix=${TARGET} --disable-shared --enable-static
make
make install

