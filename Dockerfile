############################################################
# Dockerfile for building the static FFmpeg binary
# Based on Debian
############################################################

FROM docker.io/library/debian:9.13
ADD install_deps_debian.sh /
RUN /install_deps_debian.sh
