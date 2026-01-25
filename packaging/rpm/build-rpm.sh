#!/bin/bash
set -e

VERSION="1.0.0"
PACKAGE_NAME="rubdupe"

# Create tarball
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cd ../..
tar czf ~/rpmbuild/SOURCES/${PACKAGE_NAME}-${VERSION}.tar.gz \
  --transform "s,^,${PACKAGE_NAME}-${VERSION}/," \
  lib/*.rb smart_sort.rb

# Build RPM
rpmbuild -ba packaging/rpm/rubdupe.spec
cp ~/rpmbuild/RPMS/noarch/${PACKAGE_NAME}-${VERSION}-1.*.rpm packaging/
