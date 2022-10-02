#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

cd OMCompiler

# dont include the build prefix
export CC=`basename ${CC}`
export CPP=`basename ${CPP}`

# netstream does not build with conda-forge's default c++1z
#export CXXFLAGS="${CXXFLAGS} -std=c++14"

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
#curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d 3rdParty

# help find conda dependencies in prefix
#sed -i "s|\-lOpenModelicaCompiler|\-L${PREFIX}/lib \-lOpenModelicaCompiler|g" common/m4/omhome.m4
#sed -i "s|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,${PREFIX}/lib \-Wl,\-rpath\-link,|g" configure.ac

# add fpic to fmi build flags
#sed -i "s|\-DCMINPACK_NO_DLL=1|\-DCMINPACK_NO_DLL=1 \-fPIC|g" SimulationRuntime/fmi/export/buildproject/configure.ac Compiler/Script/CevalScriptBackend.mo

# Compiler/runtime/libomcruntime-boot.so: undefined reference to `libiconv
#sed -i "s|\-lzmq|\-lzmq \-liconv|g" configure.ac

# KLU detection error
#sed -i "s|try_compile(LTEST_OK \${KLUTest_DIR} \${KLUTest_DIR} ltest OUTPUT_VARIABLE MY_OUTPUT)|set(LTEST_OK TRUE)|g" 3rdParty/sundials-5.4.0/config/SundialsKLU.cmake

autoconf
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
