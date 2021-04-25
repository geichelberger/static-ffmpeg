#!/bin/bash

# DEPENDENCIES-BASE: git, mercurial, curl, wget, tar, gcc, g++, make, libtool, automake, autoconf, autogen, pkg-config, cmake, bison, flex, gperf, gettext, autopoint texinfo texlive
# DEPENDENCIES?: libexpat, libpng
# DEPENDENCIES: libfontconfig-devel, libfreetype2-devel, libbz2-devel, librubberband-devel, libfftw3-devel, libsamplerate0-devel, libgmp-devel

set -u
set -e
set -x

# git clone ignore error
git_clone_ie()
{
    git clone --quiet $1 $2 || true
}

git_get_fresh()
{
    echo "FETCH/CLEAN $1"
    git_clone_ie $2 $1
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $1
    git fetch -p
    git clean -fdx
    git checkout -- .
    cd $CURRENT_DIR
}

git_get_frver() # fresh with version
{
    git_get_fresh $1 $3
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $1
    git checkout $2
    cd $CURRENT_DIR
}

git_get_submd()
{
    git_get_fresh $1 $2

    echo "SUBMODULES $1"

    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $1

    git submodule deinit -f .
    git submodule init
    git submodule update

    cd $CURRENT_DIR
}

dl_tar_gz_fre()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    echo "CLEAN/DOWNLOAD/UNTAR $1"

    rm -rf "$1"

    mkdir "$1"
    cd "$1"

    curl -s -o tmp.tar.gz -L $2
    tar -xzf tmp.tar.gz --strip-components=1
    rm tmp.tar.gz

    cd $CURRENT_DIR
}

# set path vars
WD=$(pwd)
SRC=$WD/src

mkdir -p $SRC


# get source
cd $SRC
git_get_fresh  ffmpeg                     https://git.ffmpeg.org/ffmpeg.git &
git_get_frver  nasm         nasm-2.13.03  https://repo.or.cz/nasm.git &
git_get_fresh  yasm                       git://github.com/yasm/yasm.git &
git_get_frver  alsa         v1.2.4        https://github.com/alsa-project/alsa-lib.git &
git_get_fresh  libx264                    http://git.videolan.org/git/x264.git &
git_get_fresh  libx265                    https://github.com/videolan/x265 &
git_get_fresh  libopus                    https://github.com/xiph/opus.git &
git_get_fresh  libogg                     https://github.com/xiph/ogg.git &
git_get_fresh  libvorbis                  https://github.com/xiph/vorbis.git &
git_get_fresh  libvpx                     https://chromium.googlesource.com/webm/libvpx &
# git_get_fresh  freetype2                  git://git.sv.nongnu.org/freetype/freetype2.git &
# git_get_fresh  fontconfig                 git://anongit.freedesktop.org/fontconfig &
git_get_fresh  frei0r                     https://github.com/dyne/frei0r.git &
git_get_fresh  fribidi                    https://github.com/fribidi/fribidi.git &
git_get_fresh  libopenjpeg                https://github.com/uclouvain/openjpeg.git &
git_get_fresh  libsoxr                    https://git.code.sf.net/p/soxr/code &
git_get_fresh  libspeex                   https://github.com/xiph/speex.git &
git_get_fresh  libtheora                  https://github.com/xiph/theora.git &
git_get_fresh  libvidstab                 https://github.com/georgmartius/vid.stab.git &
git_get_fresh  libwebp                    https://chromium.googlesource.com/webm/libwebp &
git_get_fresh  ffnvcodec                  https://git.videolan.org/git/ffmpeg/nv-codec-headers.git &
git_get_fresh  c2man                      https://github.com/fribidi/c2man.git &
git_get_submd  gnutls                     https://gitlab.com/gnutls/gnutls.git &
git_get_fresh  nettle                     https://git.lysator.liu.se/nettle/nettle &

dl_tar_gz_fre  lame      http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz &
dl_tar_gz_fre  xvidcore  https://downloads.xvid.com/downloads/xvidcore-1.3.5.tar.gz &

# wait for download jobs to finish
wait
