cmake_minimum_required(VERSION 3.28)

project(gba-test LANGUAGES C ASM)

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