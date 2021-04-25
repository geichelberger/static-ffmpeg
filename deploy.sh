#!/bin/bash

set -u
set -e


DATE="$(date +%Y%m%d%H%M%S)"
VERSION="$(./ffmpeg_bin/ffmpeg -version | sed -n 's/^ffmpeg version \(.*\) Copyright.*$/\1/p')"
FFMPEG_DIR="ffmpeg-${DATE}-${VERSION}"
mkdir -p "$FFMPEG_DIR/man/man1"

cp ffmpeg_bin/ffmpeg "$FFMPEG_DIR/"
cp ffmpeg_bin/ffprobe "$FFMPEG_DIR/"
cp ffmpeg_build/share/man/man1/ffmpeg*   "$FFMPEG_DIR/man/man1"
cp ffmpeg_build/share/man/man1/ffprobe*  "$FFMPEG_DIR/man/man1/"
cp src/ffmpeg/COPYING.GPLv3              "$FFMPEG_DIR/"
cp src/ffmpeg/README.md                  "$FFMPEG_DIR/"
cp src/ffmpeg/RELEASE                    "$FFMPEG_DIR/"

tar cfJ "${FFMPEG_DIR}.tar.xz" "${FFMPEG_DIR}"
ln -s "${FFMPEG_DIR}.tar.xz" ffmpeg-latest.tar.xz

echo "host_base = ${S3_HOST}" > "$HOME/.s3cfg"
echo "host_bucket = ${S3_HOST}" >> "$HOME/.s3cfg"
echo "bucket_location = us-east-1" >> "$HOME/.s3cfg"
echo "use_https = True" >> "$HOME/.s3cfg"
echo "access_key = ${S3_ACCESS_KEY}" >> "$HOME/.s3cfg"
echo "secret_key = ${S3_SECRET_KEY}" >> "$HOME/.s3cfg"
echo "signature_v2 = False" >> "$HOME/.s3cfg"

s3cmd put -P "${FFMPEG_DIR}.tar.xz" s3://opencast-ffmpeg-static/
s3cmd put -P ffmpeg-latest.tar.xz   s3://opencast-ffmpeg-static/
