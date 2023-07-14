# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 desktop xdg-utils

EGIT_REPO_URI="https://github.com/gnif/LookingGlass.git"
DESCRIPTION="A low latency KVM FrameRelay implementation for guests with VGA PCI Passthrough"
HOMEPAGE="https://looking-glass.io https://github.com/gnif/LookingGlass"

LICENSE="GPL-2"
SLOT="0"
IUSE="binutils X wayland pipewire pulseaudio gnome"
REQUIRED_USE="|| ( binutils X wayland pipewire pulseaudio ) pipewire? ( !pulseaudio ) pulseaudio? ( !pipewire ) "

RDEPEND="dev-libs/libconfig
	dev-libs/nettle
	media-libs/freetype
	media-libs/fontconfig
	media-libs/libsdl2
	media-libs/sdl2-ttf
	virtual/glu
	media-libs/libsamplerate
	binutils? ( sys-devel/binutils )
	X? ( x11-libs/libX11 x11-libs/libXfixes x11-libs/libXi x11-libs/libXScrnSaver x11-libs/libXpresent )
	wayland? ( dev-libs/wayland )
	pulseaudio? ( media-libs/libpulse )
	pipewire? ( media-video/pipewire )
	gnome? ( gui-libs/libdecor )
"

DEPEND="${RDEPEND}
	app-emulation/spice-protocol
	wayland? ( dev-libs/wayland-protocols )
"
BDEPEND="virtual/pkgconfig"

CMAKE_USE_DIR="${S}"/client

src_prepare() {
	default

	# Base on build.rst from the project
	# https://github.com/gnif/LookingGlass/blob/master/doc/build.rst

	if ! use binutils; then
		MYCMAKEARGS=" -DENABLE_BACKTRACE=no "
	fi

	if ! use X; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_X11=no "
	fi

	if ! use wayland; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_WAYLAND=no "
	fi

	if ! use pipewire; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_PIPEWIRE=no "
	fi

	if ! use pulseaudio; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_PULSEAUDIO=no "
	fi

	if ! use pulseaudio; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_PULSEAUDIO=no "
	fi

	if use gnome && use wayland; then
		MYCMAKEARGS=" ${MYCMAKEARGS} -DENABLE_LIBDECOR=ON "
	fi

	cmake_src_prepare
}

src_install() {
	einstalldocs
	dobin "${BUILD_DIR}/looking-glass-client"
	newicon -s 128 "${S}/resources/icon-128x128.png" looking-glass-client.png

	if use X && ! use wayland || ! use X && use wayland; then
		domenu "${FILESDIR}/LookingGlass.desktop"
	fi

	if use X && use wayland; then
		domenu "${FILESDIR}/LookingGlass-X.desktop"
		newmenu "${FILESDIR}/LookingGlass.desktop" LookingGlass-Wayland.desktop
	fi
}

pkg_postinst() {
	xdg_icon_cache_update
	if use X && ! use wayland || ! use X && use wayland; then
		ewarn "The desktop file located located at /usr/share/applications/LookingGlass.desktop"
	fi
	if use X && use wayland; then
		ewarn "The desktop files located located at /usr/share/applications/LookingGlass-X.desktop /usr/share/applications/LookingGlass-Wayland.desktop"
	fi
	ewarn "Use the Right Control (Control_R) as the modifier key to control the action in LookingGlass"
	ewarn "Note: Key was change because my laptop dosent have ScrLk"
	ewarn "Tip: If you press and hold the modfier key (Control_R) you get all the key shortcuts for all action"
	ewarn ""
	ewarn "Note: The modifier key can be change by editing the desktop file"
	ewarn "More information on this link: https://looking-glass.io/wiki/Client/Keyboard_shortcuts"
}
