#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

# dont include the build prefix that wont exist when compiling FMUs
export CC=`basename ${CC}`
export CPP=`basename ${CPP}`

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d OMCompiler/3rdParty

cmake ${CMAKE_ARGS} -G "Ninja" -LAH \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DOM_ENABLE_GUI_CLIENTS=OFF \
  -DOM_USE_CCACHE=OFF \
  -B build -S .
cmake --build build --target install
