TEMPLATE	= app
LANGUAGE	= C++

CONFIG	+= thread
CONFIG	+= warn_on debug

INCLUDEPATH		+= ./include

OBJECTS_DIR 	= obj
TARGET = Test

# Input

HEADERS +=  include/leveldb/slice.h     \
            util/logging.h  \
            test/mem.h

SOURCES +=  main.cc     \
            util/logging.cc \
            test/mem.cc
