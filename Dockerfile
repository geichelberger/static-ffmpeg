############################################################
# Dockerfile for building the static FFmpeg binary
# Based on Debian
############################################################

FROM docker.io/library/debian:10.6
# Update the repository sources list
RUN apt update && apt install -y \
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
	libharfbuzz-dev\
	librubberband-dev \
	libsamplerate0-dev \
	libtool \
	make \
	mercurial \
	pkg-config \
	texinfo \
	texlive \
	wget
