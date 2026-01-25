#!/bin/bash
set -e

VERSION="1.0.0"
ARCH="all"
PACKAGE_NAME="rubdupe"
BUILD_DIR="rubdupe_${VERSION}_${ARCH}"

# Create package structure
mkdir -p ${BUILD_DIR}/DEBIAN
mkdir -p ${BUILD_DIR}/usr/bin
mkdir -p ${BUILD_DIR}/usr/lib/rubdupe/lib

# Copy files
cp ../../bin/smart_sort ${BUILD_DIR}/usr/bin/
cp ../../lib/*.rb ${BUILD_DIR}/usr/lib/rubdupe/lib/
cp ../../smart_sort.rb ${BUILD_DIR}/usr/lib/rubdupe/

# Create wrapper script
cat > ${BUILD_DIR}/usr/bin/smart_sort << 'WRAPPER'
#!/usr/bin/env ruby
require '/usr/lib/rubdupe/lib/file_analyzer'
require '/usr/lib/rubdupe/lib/intelligent_sorter'
require '/usr/lib/rubdupe/lib/deduplicator'
load '/usr/lib/rubdupe/smart_sort.rb'
WRAPPER

chmod +x ${BUILD_DIR}/usr/bin/smart_sort

# Create control file
cat > ${BUILD_DIR}/DEBIAN/control << CONTROL
Package: rubdupe
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: ruby (>= 2.7)
Maintainer: timappledotcom <179739321+timappledotcom@users.noreply.github.com>
Description: Ruby duplicate file detector
 Intelligent duplicate file detector and sorter with smart grouping.
 Analyzes files by content hash and provides interactive sorting.
CONTROL

# Build package
dpkg-deb --build ${BUILD_DIR}
mv ${BUILD_DIR}.deb ../../

# Cleanup
rm -rf ${BUILD_DIR}
