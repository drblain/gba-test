if(NOT DEFINED ENV{DEVKITPRO} OR "$ENV{DEVKITPRO}" STREQUAL "")
    message(FATAL_ERROR
        "DEVKITPRO is not set. Install devkitPro and set DEVKITPRO in your environment.")
endif()

set(GBA_DEVKITPRO "$ENV{DEVKITPRO}")
if(DEFINED ENV{DEVKITARM} AND NOT "$ENV{DEVKITARM}" STREQUAL "")
    set(GBA_DEVKITARM "$ENV{DEVKITARM}")
else()
    set(GBA_DEVKITARM "${GBA_DEVKITPRO}/devkitARM")
endif()

set(GBA_ARM_TOOL_PREFIX "${GBA_DEVKITARM}/bin/arm-none-eabi-")
set(CMAKE_C_COMPILER "${GBA_ARM_TOOL_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "${GBA_ARM_TOOL_PREFIX}g++")
set(CMAKE_ASM_COMPILER "${GBA_ARM_TOOL_PREFIX}gcc")
set(CMAKE_AR "${GBA_ARM_TOOL_PREFIX}ar")
set(CMAKE_RANLIB "${GBA_ARM_TOOL_PREFIX}ranlib")
set(CMAKE_OBJCOPY "${GBA_ARM_TOOL_PREFIX}objcopy")

foreach(tool IN ITEMS
        "${CMAKE_C_COMPILER}"
        "${CMAKE_CXX_COMPILER}"
        "${CMAKE_OBJCOPY}"
        "${GBA_DEVKITPRO}/tools/bin/gbafix")
    if(NOT EXISTS "${tool}")
        message(FATAL_ERROR "Required devkitPro tool was not found: ${tool}")
    endif()
endforeach()

set(GBA_GBAFIX "${GBA_DEVKITPRO}/tools/bin/gbafix")

# This project cross-compiles for a bare-metal target and does not run host checks.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm7tdmi)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
