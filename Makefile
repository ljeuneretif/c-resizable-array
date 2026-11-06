# Directories.
## Include.
INC_DIR = inc
## Source.
SRC_DIR = src
## Test.
TST_DIR = tst

## Artifacts from build: object files, dependency files, test binaries, etc.
BUILD_DIR = build
## Compiled library for distribution.
DIST_DIR = dist

## Directories to remove when cleaning.
ROOT_NEW_DIRS := $(BUILD_DIR) $(DIST_DIR)



# General-purpose flags.
WARN_CFLAGS = -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes -Werror
DEP_CFLAGS = -MMD -MP

OPT_CFLAGS = 
BUILD_SUBDIR =
IS_RELEASE =

## Depending on the environment variables:
## optimize, or debug optionnally switching the traces on.
DEBUG ?=
TRACE ?= 
ifdef DEBUG
	OPT_CFLAGS += -g -DDEBUG
	BUILD_SUBDIR = debug
	ifdef TRACE
		OPT_CFLAGS += -DTRACE
		BUILD_SUBDIR := $(BUILD_SUBDIR)_trace
	endif
else
	OPT_CFLAGS += -O2
	BUILD_SUBDIR = release
	IS_RELEASE = 1
endif


GLOBAL_CFLAGS := $(WARN_CFLAGS) $(DEP_CFLAGS) $(OPT_CFLAGS)
BUILD_PATH := $(BUILD_DIR)/$(BUILD_SUBDIR)



# Directories to create.
NEW_DIRS := $(BUILD_DIR) $(BUILD_PATH) $(DIST_DIR)



# Compilation of the library.
RA_SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
RA_DEP_FILES := $(RA_SRC_FILES:$(SRC_DIR)/%.c=$(BUILD_PATH)/%.d)
RA_OBJ_FILES := $(RA_SRC_FILES:$(SRC_DIR)/%.c=$(BUILD_PATH)/%.o)

RA_CFLAGS := -fPIC $(GLOBAL_CFLAGS)
RA_CPPFLAGS := -I$(INC_DIR)
RA_LDFLAGS := -shared
RA_LDLIBS :=

## The name of the library can be changed, for example to avoid collision.
## The names of the symbols of the library can be changed by a wrapper.
RA_LIB_NAME ?= resizable_array
RA_LIB_FILENAME := lib$(RA_LIB_NAME).so

RA_LIB_PATH_BUILD := $(BUILD_PATH)/$(RA_LIB_FILENAME)
RA_LIB_PATH_DIST := $(DIST_DIR)/$(RA_LIB_FILENAME)



# Tests.
## The mock lib.
MOCK_SRC_FILES := $(wildcard $(TST_DIR)/mock_*.c)
MOCK_DEP_FILES := $(MOCK_SRC_FILES:$(TST_DIR)/%.c=$(BUILD_PATH)/%.d)
MOCK_OBJ_FILES := $(MOCK_SRC_FILES:$(TST_DIR)/%.c=$(BUILD_PATH)/%.o)

MOCK_LIB_NAME = mock
MOCK_LIB_PATH := $(BUILD_PATH)/lib$(MOCK_LIB_NAME).so

MOCK_CFLAGS := -fPIC $(GLOBAL_CFLAGS) -D_GNU_SOURCE
MOCK_CPPFLAGS := -I$(TST_DIR)
MOCK_LDFLAGS := -shared
MOCK_LDLIBS := -ldl

## The test source files to their executables.
TEST_SRC_FILES := $(sort $(wildcard $(TST_DIR)/test*.c))
TEST_DEP_FILES := $(TEST_SRC_FILES:$(TST_DIR)/%.c=$(BUILD_PATH)/%.d)
TEST_OBJ_FILES := $(TEST_SRC_FILES:$(TST_DIR)/%.c=$(BUILD_PATH)/%.o)
TEST_BIN_FILES := $(TEST_OBJ_FILES:$(BUILD_PATH)/%.o=$(BUILD_PATH)/%.tst)

TEST_CFLAGS := $(GLOBAL_CFLAGS) -D_GNU_SOURCE
TEST_CPPFLAGS := $(RA_CPPFLAGS) -I$(TST_DIR)
TEST_LDFLAGS := -rdynamic -L$(abspath $(BUILD_PATH))
TEST_LDLIBS := -l$(RA_LIB_NAME) -ldl -Wl,-rpath,$(abspath $(BUILD_PATH))

## The phony targets for the execution of the test binaries.
TEST_RUN := $(addprefix run-,$(TEST_BIN_FILES))



# Targets.

## General targets.
.DEFAULT: all

.PHONY: all
.NOTPARALLEL: all
all: lib test $(if $(IS_RELEASE),copy-lib)



## Generating the library.
.PHONY: lib
lib: $(RA_LIB_PATH_BUILD)

$(RA_LIB_PATH_BUILD): $(RA_OBJ_FILES) | $(BUILD_PATH)
	$(CC) $(RA_LDFLAGS) -o $@ $(filter-out Makefile,$^) $(RA_LDLIBS)

$(RA_OBJ_FILES): $(BUILD_PATH)/%.o: $(SRC_DIR)/%.c | $(BUILD_PATH)
	$(CC) $(RA_CFLAGS) $(RA_CPPFLAGS) -o $@ -c $<



## The tests.
.PHONY: test
.NOTPARALLEL: test
test: $(TEST_RUN)

.PHONY: $(TEST_RUN)
$(TEST_RUN): run-%: % $(MOCK_LIB_PATH)
	LD_PRELOAD=$(abspath $(MOCK_LIB_PATH)) ./$<

.SECONDARY: $(TEST_BIN_FILES)
$(TEST_BIN_FILES): $(BUILD_PATH)/%.tst: $(BUILD_PATH)/%.o $(RA_LIB_PATH_BUILD) | $(BUILD_PATH)
	$(CC) $(TEST_LDFLAGS) -o $@ $< $(TEST_LDLIBS)

.SECONDARY: $(TEST_OBJ_FILES)
$(TEST_OBJ_FILES): $(BUILD_PATH)/%.o: $(TST_DIR)/%.c | $(BUILD_PATH)
	$(CC) $(TEST_CFLAGS) $(TEST_CPPFLAGS) -o $@ -c $<


.SECONDARY: $(MOCK_LIB_PATH)
$(MOCK_LIB_PATH): $(MOCK_OBJ_FILES) | $(BUILD_PATH)
	$(CC) $(MOCK_LDFLAGS) -o $@ $(filter-out Makefile,$^) $(MOCK_LDLIBS)

.SECONDARY: $(MOCK_OBJ_FILES)
$(MOCK_OBJ_FILES): $(BUILD_PATH)/%.o: $(TST_DIR)/%.c | $(BUILD_PATH)
	$(CC) $(MOCK_CFLAGS) $(MOCK_CPPFLAGS) -o $@ -c $<



## All the dependency files generated should be included.
-include $(RA_DEP_FILES) $(TEST_DEP_FILES) $(MOCK_DEP_FILES)



## Copy the lib ready to be distributed.
## Target run only in release mode (no DEBUG).
.PHONY: copy-lib
copy-lib: $(RA_LIB_PATH_DIST)

$(RA_LIB_PATH_DIST): $(RA_LIB_PATH_BUILD) | $(DIST_DIR)
	cp $< $@



## Directory management.
$(NEW_DIRS):
	mkdir -p $@

.PHONY: clean
clean:
	$(RM) -r $(ROOT_NEW_DIRS)



## All target files should be updated when the Makefile changes.
$(RA_LIB_PATH_DIST) $(RA_LIB_PATH_BUILD) $(RA_OBJ_FILES) $(TEST_BIN_FILES) $(TEST_OBJ_FILES): Makefile
