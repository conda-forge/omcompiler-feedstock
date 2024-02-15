#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d OMCompiler/3rdParty

# link with shared blas/lapack libs: https://github.com/OpenModelica/OpenModelica/issues/10304
sed -i "s|-Wl,-Bstatic -lSimulationRuntimeFMI \$LDFLAGS \$LD_LAPACK -Wl,-Bdynamic|-Wl,-Bstatic -lSimulationRuntimeFMI -Wl,-Bdynamic \$LDFLAGS \$LD_LAPACK|g" OMCompiler/configure.ac

cmake ${CMAKE_ARGS} -G "Ninja" -LAH \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DOM_ENABLE_GUI_CLIENTS=OFF \
  -DOM_USE_CCACHE=OFF \
  -B build -S .
cmake --build build --target install
