CC ?= gcc

STDC := -std=c11
WARN_CFLAGS := -Wall -Wextra -Wpedantic -Wshadow -Wconversion\
 -Wstrict-prototypes -Wmissing-prototypes -Werror
CFLAGS ?= $(STDC) $(WARN_CFLAGS)

ifeq ($(BUILD),release)
	OPT_CFLAGS := -O2
else ifeq ($(BUILD),debug)
	OPT_CFLAGS := -g -DDEBUG
else ifeq ($(BUILD),trace)
	OPT_CFLAGS := -g -DDEBUG -DTRACE
endif

DEP_CFLAGS := -MMD -MP
ALL_CFLAGS := $(CFLAGS) $(DEP_CFLAGS) $(OPT_CFLAGS)
