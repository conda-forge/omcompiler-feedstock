
git submodule -q sync
git submodule -q update --init --recursive

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

