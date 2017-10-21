# Copyright (c) 2011 The LevelDB Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file. See the AUTHORS file for names of contributors.

#-----------------------------------------------
# Uncomment exactly one of the lines labelled (A), (B), and (C) below
# to switch between compilation modes.

# (A) Production use (optimized mode)
#OPT ?= -O2 -DNDEBUG
# (B) Debug mode, w/ full line-level debugging symbols
# OPT ?= -g2
# (C) Profiling mode: opt, but w/debugging symbols
OPT ?= -O2 -g2 -DNDEBUG
#-----------------------------------------------

# detect what platform we're building on
$(shell CC="$(CC)" CXX="$(CXX)" TARGET_OS="$(TARGET_OS)" \
    ./build_detect_platform build_config.mk ./)
# this file is generated by the previous line to set build flags and sources
include build_config.mk


CFLAGS += -I. -I./include $(PLATFORM_CCFLAGS) $(OPT)
CXXFLAGS += -I. -I./include $(PLATFORM_CXXFLAGS) $(OPT)

LDFLAGS += $(PLATFORM_LDFLAGS)
LIBS += $(PLATFORM_LIBS)

SIMULATOR_OUTDIR=out-ios-x86
DEVICE_OUTDIR=out-ios-arm

ifeq ($(PLATFORM), IOS)
# Note: iOS should probably be using libtool, not ar.
AR=xcrun ar
SIMULATORSDK=$(shell xcrun -sdk iphonesimulator --show-sdk-path)
DEVICESDK=$(shell xcrun -sdk iphoneos --show-sdk-path)
DEVICE_CFLAGS = -isysroot "$(DEVICESDK)" -arch armv6 -arch armv7 -arch armv7s -arch arm64
SIMULATOR_CFLAGS = -isysroot "$(SIMULATORSDK)" -arch i686 -arch x86_64
STATIC_OUTDIR=out-ios-universal
else
STATIC_OUTDIR=out-static
SHARED_OUTDIR=out-shared
endif

STATIC_LIBOBJECTS := $(addprefix $(STATIC_OUTDIR)/, $(SOURCES:.cc=.o))

SHARED_LIBOBJECTS := $(addprefix $(SHARED_OUTDIR)/, $(SOURCES:.cc=.o))

STATIC_ALLOBJS := $(STATIC_LIBOBJECTS)

default: all

# Should we build shared libraries?
ifneq ($(PLATFORM_SHARED_EXT),)

# Many leveldb test apps use non-exported API's. Only build a subset for testing.
SHARED_ALLOBJS := $(SHARED_LIBOBJECTS)

ifneq ($(PLATFORM_SHARED_VERSIONED),true)
SHARED_LIB1 = libleveldb.$(PLATFORM_SHARED_EXT)
SHARED_LIB2 = $(SHARED_LIB1)
SHARED_LIB3 = $(SHARED_LIB1)
SHARED_LIBS = $(SHARED_LIB1)
else
# Update db.h if you change these.
SHARED_VERSION_MAJOR = 1
SHARED_VERSION_MINOR = 20
SHARED_LIB1 = libleveldb.$(PLATFORM_SHARED_EXT)
SHARED_LIB2 = $(SHARED_LIB1).$(SHARED_VERSION_MAJOR)
SHARED_LIB3 = $(SHARED_LIB1).$(SHARED_VERSION_MAJOR).$(SHARED_VERSION_MINOR)
SHARED_LIBS = $(SHARED_OUTDIR)/$(SHARED_LIB1) $(SHARED_OUTDIR)/$(SHARED_LIB2) $(SHARED_OUTDIR)/$(SHARED_LIB3)
$(SHARED_OUTDIR)/$(SHARED_LIB1): $(SHARED_OUTDIR)/$(SHARED_LIB3)
	ln -fs $(SHARED_LIB3) $(SHARED_OUTDIR)/$(SHARED_LIB1)
$(SHARED_OUTDIR)/$(SHARED_LIB2): $(SHARED_OUTDIR)/$(SHARED_LIB3)
	ln -fs $(SHARED_LIB3) $(SHARED_OUTDIR)/$(SHARED_LIB2)
endif

$(SHARED_OUTDIR)/$(SHARED_LIB3): $(SHARED_LIBOBJECTS)
	$(CXX) $(LDFLAGS) $(PLATFORM_SHARED_LDFLAGS)$(SHARED_LIB2) $(SHARED_LIBOBJECTS) -o $(SHARED_OUTDIR)/$(SHARED_LIB3) $(LIBS)

endif  # PLATFORM_SHARED_EXT

all: $(SHARED_LIBS) $(STATIC_OUTDIR)/libleveldb.a main

main: $(STATIC_LIBOBJECTS) main.PLATFORM_CCFLAGS
	$(CXX) $(LDFLAGS) $(CXXFLAGS) $^ -o $@

clean:
	-rm -rf out-static out-shared out-ios-x86 out-ios-arm out-ios-universal
	-rm -f build_config.mk
	-rm -rf ios-x86 ios-arm

$(STATIC_OUTDIR):
	mkdir $@

$(STATIC_OUTDIR)/port: | $(STATIC_OUTDIR)
	mkdir $@

$(STATIC_OUTDIR)/checkelement: | $(STATIC_OUTDIR)
	mkdir $@

$(STATIC_OUTDIR)/util: | $(STATIC_OUTDIR)
	mkdir $@

.PHONY: STATIC_OBJDIRS
STATIC_OBJDIRS: \
	$(STATIC_OUTDIR)/port \
	$(STATIC_OUTDIR)/checkelement \
	$(STATIC_OUTDIR)/util 

$(SHARED_OUTDIR):
	mkdir $@

$(SHARED_OUTDIR)/port: | $(SHARED_OUTDIR)
	mkdir $@

$(SHARED_OUTDIR)/checkelement: | $(SHARED_OUTDIR)
	mkdir $@

$(SHARED_OUTDIR)/util: | $(SHARED_OUTDIR)
	mkdir $@

.PHONY: SHARED_OBJDIRS
SHARED_OBJDIRS: \
	$(SHARED_OUTDIR)/port \
	$(SHARED_OUTDIR)/checkelement \
	$(SHARED_OUTDIR)/util 

$(STATIC_ALLOBJS): | STATIC_OBJDIRS
$(SHARED_ALLOBJS): | SHARED_OBJDIRS

ifeq ($(PLATFORM), IOS)
$(DEVICE_OUTDIR)/libleveldb.a: $(DEVICE_LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(DEVICE_LIBOBJECTS)

$(SIMULATOR_OUTDIR)/libleveldb.a: $(SIMULATOR_LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(SIMULATOR_LIBOBJECTS)

$(DEVICE_OUTDIR)/libmemenv.a: $(DEVICE_MEMENVOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(DEVICE_MEMENVOBJECTS)

$(SIMULATOR_OUTDIR)/libmemenv.a: $(SIMULATOR_MEMENVOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(SIMULATOR_MEMENVOBJECTS)

# For iOS, create universal object libraries to be used on both the simulator and
# a device.
$(STATIC_OUTDIR)/libleveldb.a: $(STATIC_OUTDIR) $(DEVICE_OUTDIR)/libleveldb.a $(SIMULATOR_OUTDIR)/libleveldb.a
	lipo -create $(DEVICE_OUTDIR)/libleveldb.a $(SIMULATOR_OUTDIR)/libleveldb.a -output $@

$(STATIC_OUTDIR)/libmemenv.a: $(STATIC_OUTDIR) $(DEVICE_OUTDIR)/libmemenv.a $(SIMULATOR_OUTDIR)/libmemenv.a
	lipo -create $(DEVICE_OUTDIR)/libmemenv.a $(SIMULATOR_OUTDIR)/libmemenv.a -output $@
else
$(STATIC_OUTDIR)/libleveldb.a:$(STATIC_LIBOBJECTS)
	rm -f $@
	$(AR) -rs $@ $(STATIC_LIBOBJECTS)
endif

$(STATIC_OUTDIR)/%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(STATIC_OUTDIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(SHARED_OUTDIR)/%.o: %.cc
	$(CXX) $(CXXFLAGS) $(PLATFORM_SHARED_CFLAGS) -c $< -o $@

$(SHARED_OUTDIR)/%.o: %.c
	$(CC) $(CFLAGS) $(PLATFORM_SHARED_CFLAGS) -c $< -o $@

$(STATIC_OUTDIR)/port/port_posix_sse.o: port/port_posix_sse.cc
	$(CXX) $(CXXFLAGS) $(PLATFORM_SSEFLAGS) -c $< -o $@

$(SHARED_OUTDIR)/port/port_posix_sse.o: port/port_posix_sse.cc
	$(CXX) $(CXXFLAGS) $(PLATFORM_SHARED_CFLAGS) $(PLATFORM_SSEFLAGS) -c $< -o $@