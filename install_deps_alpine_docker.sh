#!/bin/ash

set -u
set -e

echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

apk update
apk upgrade
apk add alpine-sdk \
	libgcc \
	bash \
	coreutils \
	autoconf \
	automake \
	linux-headers \
	openssl-dev \
	rust \
	cargo \
	diffutils \
	bison \
	cmake \
	yasm \
	libunistring-dev \
	libffi-dev \
	gettext-dev \
	gettext-static \
	gc-dev \
	xz \
	flex \
	gettext \
	ghostscript \
	gperf \
	bzip2-dev \
	bzip2-static \
	fftw-dev \
	fontconfig-dev \
	fontconfig-static \
	freetype-dev \
	freetype-static \
	gmp-dev \
	rubberband-dev \
	rubberband-static \
	libsamplerate-dev \
	zlib-static \
	libpng-static \
	brotli-static \
	expat-static \
	libtool \
	mercurial \
	pkgconfig \
	s3cmd \
	texinfo \
	texlive \
	texlive-dvi \
	wget \
	sudo \
	gtk-doc

echo "DONE"
