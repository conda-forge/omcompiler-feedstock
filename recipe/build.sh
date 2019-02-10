#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

# netstream does not build with conda-forge's default c++1z
export CXXFLAGS="${CXXFLAGS} -std=c++14"

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
cd 3rdParty/FMIL && curl -L https://raw.githubusercontent.com/conda-forge/fmilib-feedstock/master/recipe/undef_gnu_source.patch | patch -p1 && cd -

sedi () {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

# help sundials find lapack
sedi "s|DLAPACK_ENABLE:Bool=ON|DLAPACK_ENABLE:Bool=ON -DCMAKE_PREFIX_PATH=${PREFIX}|g" Makefile.common

# help find conda dependencies in prefix
sedi "s|\-lOpenModelicaCompiler|\-L${PREFIX}/lib \-lOpenModelicaCompiler|g" common/m4/omhome.m4
sedi "s|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,${PREFIX}/lib \-Wl,\-rpath\-link,|g" configure.ac

autoconf
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install

