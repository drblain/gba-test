cmake_minimum_required(VERSION 3.28)

# define toolchain as per base_tools
include(cmake/base_tools.cmake)

project(gba-test LANGUAGES C ASM)

# allow seeing compiler command lines as in base_tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

## Makefile
if(NOT DEFINED ENV{DEVKITARM})
    message(FATAL_ERROR "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif()

## include $(DEVKITARM)/gba_rules
if(NOT DEFINED ENV{DEVKITPRO})
    message(FATAL_ERROR "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPro")
endif()

# PORTLIBS	:= $(DEVKITPRO)/portlibs/gba $(DEVKITPRO)/portlibs/armv4t
# export PATH := $(DEVKITPRO)/portlibs/gba/bin:$(DEVKITPRO)/portlibs/armv4t/bin:$(PATH)
# LIBGBA		:= $(DEVKITPRO)/libgba

## include $(DEVKITPRO)/devkitARM/base_rules
## include $(DEVKITPRO)/devkitARM/base_tools // include(base_tools.cmake)
include(cmake/bin2o.cmake)

# This snippet is probably unnecessary with export compile commands on
# ifeq ($(GENERATE_COMPILE_COMMANDS),1)
#     ADD_COMPILE_COMMAND := @/opt/devkitpro/tools/bin/generate_compile_commands
# else
#     ADD_COMPILE_COMMAND := @true
# endif