#!/bin/bash

# DEPENDENCIES-BASE: git, mercurial, curl, wget, tar, gcc, g++, make, libtool, automake, autoconf, autogen, pkg-config, cmake, bison, flex, gperf, gettext, autopoint texinfo texlive
# DEPENDENCIES?: libexpat, libpng
# DEPENDENCIES: libfontconfig-devel, libfreetype2-devel, libbz2-devel, librubberband-devel, libfftw3-devel, libsamplerate0-devel, libgmp-devel

set -u
set -e
set -x


autogen_src()
{
    echo "AUTOGEN $1"

    ./autogen.sh
}

bootstrap_src()
{
    echo "BOOTSTRAP $1"

    ./bootstrap
}

dot_bootstrap_src()
{
    echo "BOOTSTRAP $1"

    ./.bootstrap
}

configure_src()
{
    echo "CONFIGURE $1"

    echo ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
    ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

config_src()
{
    echo "CONFIGURE $1"

    echo ./config \
         --prefix=$OUT_PREFIX \
         "${@:2}"
    ./config \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

cmake_src()
{
    echo "CMAKE $1"

    echo cmake . \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:2}"
    cmake . \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:2}"
}

cmake_sp_src()
{
    echo "CMAKE $1"

    echo cmake "$2" \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:3}"
    cmake "$2" \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:3}"
}

make_src()
{
    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install
}

make_iie_src() # ignore install error
{
    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install || true
}

compile_with_configure()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_config_sp() # subpath, not necessarily needed
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1
    cd $2

    configure_src "$1" "${@:3}"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_config()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    config_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_autogen()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_bootstrap()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    bootstrap_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_dot_bstrp()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    dot_bootstrap_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_with_autog_iie()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_iie_src "$1"

    cd $CURRENT_DIR
}

compile_with_cmake()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    cmake_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
}
compile_with_cmake_sp()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"
    mkdir -p "$2"
    cd "$2"

    cmake_sp_src "$1" "$3" "${@:4}"
    make_src "$1"

    cd $CURRENT_DIR
}

compile_ffnvcodec()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "MAKE $1"

    make install PREFIX=$OUT_PREFIX

    cd $CURRENT_DIR
}

compile_c2man()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "C2MAN CONFIGURE $1"

    ./Configure -dE

    echo "binexp=$OUT_BIN" >> config.sh
    echo "installprivlib=$OUT_PREFIX" >> config.sh
    echo "mansrc=$OUT_PREFIX" >> config.sh
    sh config_h.SH
    sh flatten.SH
    sh Makefile.SH

    echo "MAKE $1"

    make depend
    make -j"${CPU_CORES}"
    make install

    cd $CURRENT_DIR
}

compile_alsa()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "ALSA CONFIGURE $1"

    libtoolize --force --copy --automake
    aclocal
    autoheader
    automake --foreign --copy --add-missing
    autoconf
    ./configure \
        --prefix=$OUT_PREFIX \
        --enable-shared=no \
        --enable-static=yes

    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install

    cd $CURRENT_DIR
}

compile_svtav1()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"

    echo "SVT_AV1 BUILD $1"

    cd "Build/linux"
    ./build.sh \
        prefix="$OUT_PREFIX" \
        jobs="$CPU_CORES" \
        release \
        static \
        install

    cd $CURRENT_DIR
}

compile_rav1e()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"

    echo "install cargo-c (for rav1e)"
    cargo install --root="$OUT_PREFIX" cargo-c

    echo "rav1e BUILD $1"
    PATH="$OUT_PREFIX/bin:$PATH" cargo build --release
    PATH="$OUT_PREFIX/bin:$PATH" cargo cinstall --release \
          --prefix="$OUT_PREFIX"

    echo "FIX rav1e.pc file" # Hack
    sed -i "s/ -lgcc_s / /g" "$OUT_PREFIX/lib/pkgconfig/rav1e.pc"

    cd $CURRENT_DIR
}

# get cpu count
CPU_CORES="$(grep ^processor /proc/cpuinfo | wc -l)"
echo "Building with ${CPU_CORES} parallel jobs"

# set path vars
WD=$(pwd)
SRC=$WD/src

OUT_PREFIX=$WD/ffmpeg_build
OUT_BIN=$WD/ffmpeg_bin
OUT_PKG_CONFIG=$OUT_PREFIX/lib/pkgconfig

export PATH="$OUT_BIN:$PATH"
export PKG_CONFIG_PATH=$OUT_PKG_CONFIG
export CFLAGS="${CFLAGS-} -march=x86-64 -mtune=generic"
export CXXFLAGS="${CXXFLAGS-} $CFLAGS"
export LDFLAGS="${LDFLAGS-}"
# export CC="gcc"
# export CXX="g++"

rm -rf $OUT_PREFIX
rm -rf $OUT_BIN

mkdir -p $OUT_PKG_CONFIG
mkdir -p $OUT_PREFIX
mkdir -p $OUT_PREFIX/lib
mkdir -p $OUT_BIN
mkdir -p $SRC


cd $WD


compile_with_autog_iie nasm \
                       --bindir=$OUT_BIN

# compile_with_autogen   yasm \
#                        --bindir=$OUT_BIN

compile_c2man          c2man

# update table
hash -r

compile_alsa           alsa

compile_with_configure libx264 \
                       --bindir=$OUT_BIN \
                       --enable-static \
                       --enable-pic \
                       --bit-depth=all

CFLAGS="$CFLAGS -static-libgcc" \
CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++" \
compile_with_cmake_sp  libx265 build/linux ../../source \
                       -DENABLE_SHARED:bool=off

compile_with_cmake_sp  libaom-av1 build .. \
                       -DBUILD_SHARED_LIBS=0

compile_svtav1         svt_av1

compile_rav1e          rav1e

compile_with_autogen   libopus \
                       --disable-shared

# compile libogg (dependency of libvorbis)
compile_with_autogen   libogg \
                       --disable-shared

compile_with_autogen   libvorbis \
                       --with-ogg=$OUT_PREFIX \
                       --disable-shared

compile_with_configure libvpx \
                       --disable-examples \
                       --disable-unit-tests \
                       --enable-vp9-highbitdepth \
                       --as=yasm

compile_with_configure lame \
                       --bindir=$OUT_BIN \
                       --disable-shared \
                       --enable-nasm

compile_with_autogen   fribidi \
                       --bindir=$OUT_BIN \
                       --disable-shared

compile_with_cmake     libopenjpeg \
                       -DBUILD_SHARED_LIBS=OFF

compile_with_cmake     libsoxr \
                       -Wno-dev \
                       -DBUILD_SHARED_LIBS:BOOL=OFF \
                       -DBUILD_TESTS:BOOL=OFF \
                       -DWITH_OPENMP=OFF

compile_with_autogen   libspeex \
                       --disable-shared

compile_with_autogen   libtheora \
                       --disable-shared

compile_with_config_sp xvidcore build/generic

compile_with_cmake     libvidstab \
                       -DBUILD_SHARED_LIBS=OFF

compile_with_autogen   libwebp \
                       --disable-shared

compile_with_autogen   frei0r

compile_ffnvcodec      ffnvcodec

compile_with_dot_bstrp nettle \
                       --bindir=$OUT_BIN \
                       --disable-shared

# autogen for gnutls (autogen is not on alpine?)
# as long as guile-3.0 is not supported by autogen, we cant use the system package
compile_with_configure guile
compile_with_configure autogen \
                       --bindir=$OUT_BIN \
                       --disable-dependency-tracking

compile_with_bootstrap gnutls \
                       --bindir=$OUT_BIN \
                       --with-included-libtasn1 \
                       --with-included-unistring \
                       --without-p11-kit \
                       --disable-doc \
                       --disable-full-test-suite \
                       --disable-shared

compile_with_configure ffmpeg \
                       --bindir=$OUT_BIN \
                       --pkg-config-flags="--static" \
                       --extra-cflags="-I$OUT_PREFIX/include" \
                       --extra-ldflags="-L$OUT_PREFIX/lib" \
                       --extra-libs=-lpthread \
                       --extra-libs=-lm \
                       --extra-libs=-lfftw3 \
                       --extra-libs=-lsamplerate \
                       --extra-libs=-lstdc++ \
                       --extra-cflags="-static -static-libgcc" \
                       --extra-cxxflags="-static -static-libgcc -static-libstdc++" \
                       --extra-ldexeflags="-static -static-libgcc -static-libstdc++" \
                       --enable-pthreads \
                       --enable-gpl \
                       --disable-nonfree \
                       --enable-libx264 \
                       --enable-libx265 \
                       --enable-libopus \
                       --enable-libvorbis \
                       --enable-libvpx \
                       --enable-libmp3lame \
                       --enable-fontconfig \
                       --enable-libopenjpeg \
                       --enable-libspeex \
                       --enable-libaom \
                       --enable-libsvtav1 \
                       --enable-librav1e \
                       --enable-network \
                       --enable-libtheora \
                       --enable-libsoxr \
                       --enable-libxvid \
                       --enable-libvidstab \
                       --enable-libwebp \
                       --enable-libfreetype \
                       --enable-libfribidi \
                       --enable-frei0r \
                       --enable-librubberband \
                       --enable-avfilter \
                       --enable-bzlib \
                       --enable-zlib \
                       --enable-hardcoded-tables \
                       --enable-iconv \
                       --enable-postproc \
                       --disable-debug \
                       --enable-runtime-cpudetect \
                       --enable-manpages \
                       --enable-nvenc \
                       --enable-gnutls

echo "DONE"
