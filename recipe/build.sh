#!/bin/sh

set -x

git submodule -q sync
git submodule -q update --init --recursive

cd OMCompiler

# dont include the build prefix
export CC=`basename ${CC}`
export CPP=`basename ${CPP}`

# https://github.com/OpenModelica/OpenModelica/issues/7064
cd 3rdParty/libzmq/
mkdir -p build && cd build
# cmake  -DCMAKE_INSTALL_MESSAGE=LAZY -DCMAKE_VERBOSE_MAKEFILE:Bool=ON -DCMAKE_AR:String="$BUILD_PREFIX/bin/x86_64-conda-linux-gnu-ar" -DCMAKE_INSTALL_PREFIX="`pwd`" -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_COLOR_MAKEFILE:Bool=OFF -DWITH_PERF_TOOL:Bool=OFF -DZMQ_BUILD_TESTS:Bool=OFF -DENABLE_CPACK:Bool=OFF -DCMAKE_BUILD_TYPE=Release .. -G "Unix Makefiles"
cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX="`pwd`" -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DZMQ_BUILD_TESTS:Bool=OFF ..
make

ls -l bin
ls -l $PWD/bin/local_lat
# find . -name local_lat
# file bin/local_lat || echo "nope"
make install
cd ${SRC_DIR}/OMCompiler

# cmake -DCMAKE_INSTALL_PREFIX=
# sed -i 's|SOVERSION "5.1.3"|SOVERSION "4.2.3"|g' 3rdParty/libzmq/CMakeLists.txt

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
make || ( ls -l 3rdParty/libzmq/build/lib/ && find . -name "libzmq*" )
# find . -name "libzmq*"
#make -j${CPU_COUNT}
make install
