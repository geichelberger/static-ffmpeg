#!/bin/bash

set -u
set -e


apt-get update
apt-get install -y git mercurial curl wget gcc make automake autoconf autogen libtool cmake g++ pkg-config bison flex gperf gettext autopoint texinfo texlive ghostscript gnupg
apt-get install -y libfontconfig1-dev libfreetype6-dev libbz2-dev librubberband-dev libfftw3-dev libsamplerate0-dev libgmp-dev
