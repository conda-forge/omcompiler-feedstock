#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d OMCompiler/3rdParty

# OMCompiler/Compiler/runtime/HpcOmBenchmarkExt.cpp:24:10: fatal error: expat.h: No such file or directory
sed -i "156itarget_link_libraries(omcbackendruntime PUBLIC omc::3rd::FMIL::expat)" OMCompiler/Compiler/runtime/CMakeLists.txt

cmake ${CMAKE_ARGS} -G "Ninja" -LAH \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DOM_ENABLE_GUI_CLIENTS=OFF \
  -DOM_USE_CCACHE=OFF \
  -DBLA_VENDOR=Generic \
  -B build -S .
cmake --build build --target install
