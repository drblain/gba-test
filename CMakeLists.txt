cmake_minimum_required(VERSION 3.20)

# Select the devkitARM compiler before project() enables the languages.
include(cmake/base_tools.cmake)

get_filename_component(GBA_PROJECT_NAME "${CMAKE_CURRENT_SOURCE_DIR}" NAME)
project("${GBA_PROJECT_NAME}" LANGUAGES C CXX ASM)

file(RELATIVE_PATH GBA_BINARY_RELATIVE_PATH
    "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}")
if(IS_ABSOLUTE "${GBA_BINARY_RELATIVE_PATH}"
        OR GBA_BINARY_RELATIVE_PATH MATCHES "^\\.\\.(/|$)")
    message(FATAL_ERROR
        "The build directory must be inside the source tree. "
        "Create a directory such as '${CMAKE_SOURCE_DIR}/build' and run "
        "'cmake ..' from there.")
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# These defaults mirror the Makefile and the current sample layout.
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/source")
    set(GBA_SOURCE_DIRS source)
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src")
    set(GBA_SOURCE_DIRS src)
else()
    set(GBA_SOURCE_DIRS source)
endif()
set(GBA_INCLUDE_DIRS include)
set(GBA_DATA_DIRS "")
set(GBA_MUSIC_DIRS "")
set(GBA_GRAPHICS_DIRS graphics)

include(cmake/gba_assets.cmake)

set(GBA_C_SOURCES "")
set(GBA_CXX_SOURCES "")
set(GBA_ASM_SOURCES "")
foreach(directory IN LISTS GBA_SOURCE_DIRS)
    if(NOT IS_ABSOLUTE "${directory}")
        set(directory "${CMAKE_CURRENT_SOURCE_DIR}/${directory}")
    endif()
    file(GLOB directory_sources CONFIGURE_DEPENDS
        "${directory}/*.c"
        "${directory}/*.cpp"
        "${directory}/*.s"
        "${directory}/*.S")
    foreach(source_file IN LISTS directory_sources)
        get_filename_component(source_extension "${source_file}" EXT)
        if(source_extension STREQUAL ".c")
            list(APPEND GBA_C_SOURCES "${source_file}")
        elseif(source_extension STREQUAL ".cpp")
            list(APPEND GBA_CXX_SOURCES "${source_file}")
        else()
            list(APPEND GBA_ASM_SOURCES "${source_file}")
        endif()
    endforeach()
endforeach()

gba_configure_assets(GBA_GENERATED_ASM_SOURCES GBA_GENERATED_HEADERS)
list(APPEND GBA_ASM_SOURCES ${GBA_GENERATED_ASM_SOURCES})

if(NOT GBA_C_SOURCES AND NOT GBA_CXX_SOURCES AND NOT GBA_ASM_SOURCES)
    message(FATAL_ERROR "No C, C++, or assembly source files were found.")
endif()

set(GBA_TARGET "${PROJECT_NAME}")
add_executable("${GBA_TARGET}"
    ${GBA_C_SOURCES}
    ${GBA_CXX_SOURCES}
    ${GBA_ASM_SOURCES})
if(GBA_GENERATED_HEADERS)
    target_sources("${GBA_TARGET}" PRIVATE ${GBA_GENERATED_HEADERS})
endif()
set_target_properties("${GBA_TARGET}" PROPERTIES
    OUTPUT_NAME "${PROJECT_NAME}"
    SUFFIX ".elf"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

set(GBA_SDK_INCLUDE_DIRS
    "${GBA_DEVKITPRO}/libgba/include"
    "${GBA_DEVKITPRO}/libtonc/include")
set(GBA_GENERATED_INCLUDE_DIRS
    "${CMAKE_CURRENT_BINARY_DIR}/generated/data"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/graphics"
    "${CMAKE_CURRENT_BINARY_DIR}/generated/music")
target_include_directories("${GBA_TARGET}" PRIVATE
    ${GBA_INCLUDE_DIRS}
    ${GBA_SDK_INCLUDE_DIRS}
    ${GBA_GENERATED_INCLUDE_DIRS})

set(GBA_ARCH_FLAGS
    -mcpu=arm7tdmi
    -mtune=arm7tdmi
    -mthumb
    -mthumb-interwork)
set(GBA_C_FLAGS -g -Wall -O2 ${GBA_ARCH_FLAGS})
set(GBA_CXX_FLAGS ${GBA_C_FLAGS} -fno-rtti -fno-exceptions)
set(GBA_ASM_FLAGS -g -mthumb -mthumb-interwork -x assembler-with-cpp)
if(GBA_C_SOURCES)
    set_source_files_properties(${GBA_C_SOURCES} PROPERTIES
        COMPILE_OPTIONS "${GBA_C_FLAGS}")
endif()
if(GBA_CXX_SOURCES)
    set_source_files_properties(${GBA_CXX_SOURCES} PROPERTIES
        COMPILE_OPTIONS "${GBA_CXX_FLAGS}")
endif()
if(GBA_ASM_SOURCES)
    set_source_files_properties(${GBA_ASM_SOURCES} PROPERTIES
        COMPILE_OPTIONS "${GBA_ASM_FLAGS}")
endif()

set(GBA_LIBRARIES mm tonc)
set(GBA_LIBRARY_DIRS
    "${GBA_DEVKITPRO}/libgba/lib"
    "${GBA_DEVKITPRO}/libtonc/lib")
target_link_directories("${GBA_TARGET}" PRIVATE ${GBA_LIBRARY_DIRS})
target_link_libraries("${GBA_TARGET}" PRIVATE ${GBA_LIBRARIES})

set(GAME_TITLE "${PROJECT_NAME}" CACHE STRING "Title stored in the GBA ROM")
set(GAME_CODE "0000" CACHE STRING "Four-character GBA game code")
set(MAKER_CODE "00" CACHE STRING "Two-character GBA maker code")

set(GBA_MAP_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.map")
target_link_options("${GBA_TARGET}" PRIVATE
    -g
    -mthumb
    -mthumb-interwork
    -specs=gba.specs
    "-Wl,-Map,${GBA_MAP_FILE}")

set(GBA_ROM "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.gba")
add_custom_command(
    OUTPUT "${GBA_ROM}"
    COMMAND "${CMAKE_OBJCOPY}" -O binary
        "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.elf" "${GBA_ROM}"
    COMMAND "${GBA_GBAFIX}" "${GBA_ROM}"
        "-t${GAME_TITLE}" "-c${GAME_CODE}" "-m${MAKER_CODE}"
    DEPENDS "${GBA_TARGET}"
    VERBATIM
    COMMENT "Creating ${PROJECT_NAME}.gba")
add_custom_target("${GBA_TARGET}_rom" ALL DEPENDS "${GBA_ROM}")
