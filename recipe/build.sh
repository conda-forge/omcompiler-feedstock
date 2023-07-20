#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

cd OMCompiler

# dont include the build prefix that wont exist when compiling FMUs
export CC=`basename ${CC}`
export CPP=`basename ${CPP}`

# error: expected '=', ',', ';', 'asm' or '__attribute__' before 'void'
curl -L https://github.com/OpenModelica/OMCompiler-3rdParty/pull/89.patch | patch -p1 -d 3rdParty

# help find conda dependencies in prefix
sed -i "s|\-lOpenModelicaCompiler|\-L${PREFIX}/lib \-lOpenModelicaCompiler|g" common/m4/omhome.m4
sed -i "s|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,|RT_LDFLAGS_SHARED=\"\-Wl,\-rpath\-link,${PREFIX}/lib \-Wl,\-rpath\-link,|g" configure.ac

# link with shared blas/lapack libs: https://github.com/OpenModelica/OpenModelica/issues/10304
sed -i "s|-Wl,-Bstatic -lSimulationRuntimeFMI \$LDFLAGS \$LD_LAPACK -Wl,-Bdynamic|-Wl,-Bstatic -lSimulationRuntimeFMI -Wl,-Bdynamic \$LDFLAGS \$LD_LAPACK|g" configure.ac

# Compiler/runtime/libomcruntime-boot.so: undefined reference to `libiconv
sed -i "s|\-lzmq|\-lzmq \-liconv|g" configure.ac

# add fpic to fmi build flags
sed -i "s|\-DCMINPACK_NO_DLL=1|\-DCMINPACK_NO_DLL=1 \-fPIC|g" SimulationRuntime/fmi/export/buildproject/configure.ac Compiler/Script/CevalScriptBackend.mo

# https://github.com/OpenModelica/OpenModelica/issues/7064
sed -i "s|LIBRARY DESTINATION \${CMAKE_INSTALL_LIBDIR}|LIBRARY DESTINATION lib2|g" 3rdParty/libzmq/CMakeLists.txt

# https://github.com/OpenModelica/OpenModelica/issues/7330
sed -i "s| -DCMAKE_INSTALL_MESSAGE=LAZY||g" Makefile.common

# https://github.com/OpenModelica/OpenModelica/issues/10982
sed -i "s|BOOST_HOME = @BOOSTHOME@|BOOST_HOME = ${PREFIX}/include|g" SimulationRuntime/ParModelica/auto/Makefile.in

autoreconf -vfi
./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install
