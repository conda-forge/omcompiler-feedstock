git config -f .gitmodules submodule.OMCompiler/3rdParty.url https://github.com/OpenModelica/OMCompiler-3rdParty.git
git submodule -q sync --recursive OMCompiler/3rdParty
git submodule -q update --force --init --recursive OMCompiler/3rdParty

set "OMDEV=%LIBRARY_PREFIX%"
set "MSYSTEM_PREFIX=%LIBRARY_PREFIX%"

:: error C2491: 'ffi_type_void': definition of dllimport data not allowed
echo target_compile_definitions(ffi PRIVATE FFI_STATIC_BUILD)>>OMCompiler/3rdParty/libffi/CMakeLists.txt

cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DOM_ENABLE_GUI_CLIENTS=OFF ^
    -DOM_USE_CCACHE=OFF ^
    -DBLA_VENDOR=Generic ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1