
# Flags for debug, trace, etc.
## Depending on the environment variables:
## optimize, or debug optionnally switching the traces on.
# TODO convert to build mode: BUILD=debug make; BUILD=trace make
DEBUG ?=
TRACE ?= 

OPT_CFLAGS = 
BUILD_SUBDIR =
IS_RELEASE =

ifdef DEBUG
	OPT_CFLAGS += -g -DDEBUG
	BUILD_SUBDIR = debug
	ifdef TRACE
		OPT_CFLAGS += -DTRACE
		BUILD_SUBDIR := trace
	endif
else
	OPT_CFLAGS += -O2
	BUILD_SUBDIR = release
	IS_RELEASE = 1
endif


# General-purpose flags.
CC ?= gcc

WARN_CFLAGS = -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes -Werror
DEP_CFLAGS = -MMD -MP

# TODO Add $(CFLAGS) etc to allow overloading.
GLOBAL_CFLAGS := $(WARN_CFLAGS) $(DEP_CFLAGS) $(OPT_CFLAGS)
BUILD_PATH := $(BUILD_DIR)/$(BUILD_SUBDIR)

NEW_DIRS += $(BUILD_PATH)
