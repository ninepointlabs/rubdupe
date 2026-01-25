Name:           rubdupe
Version:        1.0.0
Release:        1%{?dist}
Summary:        Ruby duplicate file detector

License:        MIT
URL:            https://github.com/timappledotcom/rubdupe
Source0:        %{name}-%{version}.tar.gz

Requires:       ruby >= 2.7
BuildArch:      noarch

%description
Intelligent duplicate file detector and sorter with smart grouping.
Analyzes files by content hash and provides interactive sorting.

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/lib/rubdupe/lib

cp smart_sort.rb $RPM_BUILD_ROOT/usr/lib/rubdupe/
cp lib/*.rb $RPM_BUILD_ROOT/usr/lib/rubdupe/lib/

cat > $RPM_BUILD_ROOT/usr/bin/smart_sort << 'WRAPPER'
#!/usr/bin/env ruby
require '/usr/lib/rubdupe/lib/file_analyzer'
require '/usr/lib/rubdupe/lib/intelligent_sorter'
require '/usr/lib/rubdupe/lib/deduplicator'
load '/usr/lib/rubdupe/smart_sort.rb'
WRAPPER

chmod +x $RPM_BUILD_ROOT/usr/bin/smart_sort

%files
/usr/bin/smart_sort
/usr/lib/rubdupe/

%changelog
* Sat Jan 25 2026 timappledotcom <179739321+timappledotcom@users.noreply.github.com> - 1.0.0-1
- Initial release
