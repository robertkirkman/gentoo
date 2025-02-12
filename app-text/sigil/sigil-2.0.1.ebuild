# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
PYTHON_REQ_USE="tk"

inherit xdg cmake python-single-r1

DESCRIPTION="Multi-platform WYSIWYG ebook editor for ePub format"
HOMEPAGE="https://sigil-ebook.com/ https://github.com/Sigil-Ebook/Sigil"
SRC_URI="https://github.com/Sigil-Ebook/Sigil/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P^}"

LICENSE="GPL-3+ Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+plugins +qt5 qt6"
REQUIRED_USE="${PYTHON_REQUIRED_USE} ^^ ( qt5 qt6 )"

RDEPEND="
	${PYTHON_DEPS}
	app-text/hunspell:=
	dev-libs/libpcre2:=[pcre16]
	sys-libs/zlib[minizip]
	$(python_gen_cond_dep '
		dev-python/css-parser[${PYTHON_USEDEP}]
		dev-python/lxml[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]')
	plugins? ( $(python_gen_cond_dep '
		dev-python/chardet[${PYTHON_USEDEP}]
		dev-python/cssselect[${PYTHON_USEDEP}]
		dev-python/dulwich[${PYTHON_USEDEP}]
		dev-python/html5lib[${PYTHON_USEDEP}]
		dev-python/pillow[${PYTHON_USEDEP}]
		dev-python/regex[${PYTHON_USEDEP}]'
	) )
	qt5? (
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtprintsupport:5
		dev-qt/qtwebengine:5[widgets]
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
	)
	qt6? (
		dev-qt/qtbase:6[concurrent,cups,network,widgets,xml]
		dev-qt/qt5compat:6
		dev-qt/qtwebengine:6[widgets]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	qt5? ( dev-qt/linguist-tools:5 )
	qt6? ( dev-qt/qttools:6[linguist] )
	virtual/pkgconfig
"

DOCS=( ChangeLog.txt README.md )

src_configure() {
	local mycmakeargs=(
		-DTRY_NEWER_FINDPYTHON3=1
		-DPython3_INCLUDE_DIR="$(python_get_includedir)"
		-DPython3_LIBRARY="$(python_get_library_path)"
		-DPython3_EXECUTABLE="${PYTHON}"

		-DUSE_QT6=$(usex qt6)
		-DINSTALL_BUNDLED_DICTS=0
		-DSYSTEM_LIBS_REQUIRED=1
		-DUSE_SYSTEM_LIBS=1
	)
	# use system-mathjax && mycmakeargs+=( -DMATHJAX3_DIR="${EPREFIX}"/usr/share/mathjax )

	cmake_src_configure
}

src_install() {
	cmake_src_install
	python_fix_shebang "${ED}"/usr/share/sigil/
	python_optimize "${ED}"/usr/share/sigil/
}
