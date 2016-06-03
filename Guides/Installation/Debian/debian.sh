#!/bin/bash

sudo apt-get update
sudo apt-get -y install autoconf automake build-essential checkinstall cmake git \
  libass-dev libfreetype6-dev libmp3lame-dev \
  libopencore-amrnb-dev libopencore-amrwb-dev librtmp-dev \
  libtheora-dev libtool libvorbis-dev libx264-dev \
  libxvidcore-dev mercurial pkg-config texinfo yasm zlib1g-dev

mkdir ~/ffmpeg_sources

# Grab current version of fdk-aac and build
cd ~/ffmpeg_sources
wget http://downloads.sourceforge.net/opencore-amr/fdk-aac/fdk-aac-0.1.4.tar.gz
tar xzvf fdk-aac-*.tar.gz
cd fdk-aac-*
autoreconf -fiv
./configure
make
sudo checkinstall --pkgname=fdk-aac \
  --pkgversion="0.1.4" --backup=no --deldoc=yes --fstrans=no --default --install

# Grab current version of libopus and build
cd ~/ffmpeg_sources
wget http://downloads.xiph.org/releases/opus/opus-1.1.2.tar.gz
tar xzvf opus-*.tar.gz
cd opus-*
./configure
make
sudo checkinstall --pkgname=opus \
  --pkgversion="1.1.2" --backup=no --deldoc=yes --fstrans=no --default --install

# Grab current version of libvpx and build
cd ~/ffmpeg_sources
git clone https://chromium.googlesource.com/webm/libvpx 
cd libvpx
./configure --disable-examples --disable-unit-tests
make
sudo checkinstall --pkgname=libvpx \
  --pkgversion="1:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default --install

# Grab current release of x265 and build
cd ~/ffmpeg_sources
hg clone https://bitbucket.org/multicoreware/x265
cd ~/ffmpeg_sources/x265/build/linux
cmake -G "Unix Makefiles" ../../source
make
sudo checkinstall --pkgname=x265 \
  --pkgversion="1:$(date +%Y%m%d%H%M)-hg" --backup=no --deldoc=yes --fstrans=no --default --install

# Grab and build current release of ffmpeg
cd ~/ffmpeg_sources
git clone https://git.ffmpeg.org/ffmpeg.git
cd ffmpeg
./configure \
  --enable-gpl \
  --enable-nonfree \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopencore-amrnb \
  --enable-libopencore-amrwb \
  --enable-libopus \
  --enable-librtmp \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-version3
make
sudo checkinstall --pkgname=ffmpeg \
  --pkgversion="5:$(date +%Y%m%d%H%M)-git" --backup=no --deldoc=yes --fstrans=no --default --install
hash -r
sudo ldconfig
