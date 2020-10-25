#!/bin/bash

set -u
set -e


apt update
apt install -y \
	autoconf \
	autogen \
	automake \
	autopoint \
	bison \
	cmake \
	curl \
	flex \
	g++ \
	gcc \
	gettext \
	ghostscript \
	git\
	gperf \
	libbz2-dev \
	libfftw3-dev \
	libfontconfig1-dev \
	libfreetype6-dev \
	libgmp-dev \
	librubberband-dev \
	libsamplerate0-dev \
	libtool \
	make \
	mercurial \
	pkg-config \
	texinfo \
	texlive \
	wget
