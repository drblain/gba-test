# gba-test

## Build

Install devkitPro with devkitARM, libgba, libtonc, and the tools package. The
standard `DEVKITPRO` environment variable must point to the devkitPro
installation. `DEVKITARM` may also be set; otherwise it is taken from
`$DEVKITPRO/devkitARM`.

From an in-tree build directory, configure and build the ROM:

```sh
mkdir -p build
cd build
cmake ..
make
```

The ELF, map file, generated asset files, and `.gba` ROM are all written under
`build/`. Open `build/gba-test.gba` with mGBA.

The CMake configuration uses `source/` (or `src/` when that is the available
source directory), `include/`, and `graphics/` by default. Data and music
directories are empty by default, matching the Makefile's `DATA` and `MUSIC`
settings. Edit the
`GBA_SOURCE_DIRS`, `GBA_INCLUDE_DIRS`, `GBA_DATA_DIRS`, `GBA_MUSIC_DIRS`, and
`GBA_GRAPHICS_DIRS` lists near the top of `CMakeLists.txt` for a different
layout. Data files are embedded with `bin2s`, music files are packed with
`mmutil`, and PNG graphics are converted with `grit` during CMake configure.
