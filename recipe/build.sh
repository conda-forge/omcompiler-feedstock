#!/bin/sh

set -x

# git config -f .gitmodules submodule.OMCompiler/3rdParty.url https://github.com/OpenModelica/OMCompiler-3rdParty.git
# git submodule -q sync --recursive OMCompiler/3rdParty
# git submodule -q update --force --init --recursive OMCompiler/3rdParty
# 
# git config -f .gitmodules submodule.OMOptim.url https://github.com/OpenModelica/OMOptim.git
# git submodule -q sync --recursive OMOptim
# git submodule -q update --force --init --recursive OMOptim
# 
# git config -f .gitmodules submodule.OMSimulator.url https://github.com/OpenModelica/OMSimulator.git
# git submodule -q sync --recursive OMSimulator
# git submodule -q update --force --init --recursive OMSimulator
# 
# git config -f .gitmodules submodule.OMSens_Qt.url https://github.com/OpenModelica/OMSens_Qt.git
# git submodule -q sync --recursive OMSens_Qt
# git submodule -q update --force --init --recursive OMSens_Qt
# 
# git config -f .gitmodules submodule.OMCompiler/Compiler/boot/bomc.url https://github.com/OpenModelica/OMBootstrapping.git
# git submodule -q sync --recursive OMCompiler/Compiler/boot/bomc
# git submodule -q update --force --init --recursive OMCompiler/Compiler/boot/bomc


git remote set-url origin https://github.com/OpenModelica/OpenModelica.git
git submodule update --force --init --recursive

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d OMCompiler/3rdParty

cmake ${CMAKE_ARGS} -G "Ninja" -LAH \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DOM_ENABLE_GUI_CLIENTS=ON \
  -DOM_OMC_ENABLE_FORTRAN=ON -DOM_OMC_ENABLE_OPTIMIZATION=ON -DOM_OMC_ENABLE_MOO=ON \
  -DOM_USE_CCACHE=OFF \
  -DBLA_VENDOR=Generic \
  -B build -S .
cmake --build build --target install --parallel ${CPU_COUNT}
