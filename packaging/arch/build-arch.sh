#!/bin/bash
set -e

VERSION="1.0.0"
PACKAGE_NAME="rubdupe"

# Create tarball
cd ../..
tar czf packaging/arch/${PACKAGE_NAME}-${VERSION}.tar.gz \
  --transform "s,^,${PACKAGE_NAME}-${VERSION}/," \
  --exclude=packaging \
  --exclude=.git \
  lib/*.rb smart_sort.rb

cd packaging/arch
makepkg -f
mv ${PACKAGE_NAME}-${VERSION}-1-any.pkg.tar.zst ../
