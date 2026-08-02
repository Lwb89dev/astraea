# Astraea RPM spec — Fedora/RHEL and openSUSE.
#
# The build starts from the staged tree produced by scripts/build-linux.sh
# (packed by scripts/build-rpm.sh into Source0). Building Flutter + Rust
# inside rpmbuild is deliberately avoided: Fedora has no flutter package and
# the sandboxed toolchains would make the spec fiction. The staged tree is
# built reproducibly by CI; this spec owns layout, dependencies, scriptlets
# and metadata validation (rpmlint).
#
# openSUSE notes: %{_libexecdir} is /usr/libexec on both families since
# Leap 15.4 / Tumbleweed; the spec uses only cross-family macros. Do NOT
# disable SELinux anywhere: all paths used are standard and policy-covered.

%global app_id com.lwb89dev.Astraea

Name:           astraea
Version: 0.4.0
Release:        1%{?dist}
Summary:        Nostr-synced calendar and agenda
License:        GPL-3.0-or-later
URL:            https://github.com/Lwb89dev/astraea
Source0:        astraea-stage-%{version}.tar.gz
BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

%description
Astraea is an offline-first, privacy-first calendar synchronized through
Nostr relays with end-to-end encryption. This source package builds the
background service, the desktop application and the GNOME Shell extension.

%package service
Summary:        Astraea calendar background service
Requires:       dbus
Recommends:     gnome-keyring
%description service
Session daemon: local SQLite database, encrypted Nostr sync, browser
authentication and the com.lwb89dev.Astraea D-Bus API. Started on demand
via D-Bus activation; systemd user units are shipped but not required.

%package desktop
Summary:        Astraea calendar desktop application
Requires:       %{name}-service = %{version}-%{release}
Requires:       gtk3
%description desktop
Full calendar UI for the Astraea Nostr calendar. Talks to astraea-service
over D-Bus and registers the astraea:// URL scheme.

%package gnome-shell-extension
Summary:        Astraea agenda in the GNOME top bar
BuildArch:      noarch
Requires:       %{name}-service = %{version}-%{release}
Requires:       gnome-shell >= 45
Recommends:     %{name}-desktop
%description gnome-shell-extension
GNOME Shell extension (45-48) with the day agenda and quick event creation.
A thin D-Bus frontend: no relay connections, no keys, no database access.

%prep
%setup -q -c

%build
# Nothing to compile: Source0 is the staged tree (see header).

%install
cp -a usr %{buildroot}/
desktop-file-validate %{buildroot}%{_datadir}/applications/%{app_id}.desktop
appstream-util validate-relax --nonet \
    %{buildroot}%{_datadir}/metainfo/%{app_id}.metainfo.xml

%files service
%{_libexecdir}/astraea/astraea-service
%{_prefix}/lib/systemd/user/astraea.service
%{_datadir}/dbus-1/services/%{app_id}.Service.service
%doc %{_datadir}/doc/astraea/

%files desktop
%{_bindir}/astraea
%{_prefix}/lib/astraea/
%{_datadir}/applications/%{app_id}.desktop
%{_datadir}/metainfo/%{app_id}.metainfo.xml
%{_datadir}/icons/hicolor/*/apps/%{app_id}.png

%files gnome-shell-extension
%{_datadir}/gnome-shell/extensions/astraea@lwb89dev/

%changelog
* Sun Jul 20 2026 Lwb89dev <lwb89dev@users.noreply.github.com> - 0.1.1-1
- First Linux packaging: service, desktop app, GNOME Shell extension.
