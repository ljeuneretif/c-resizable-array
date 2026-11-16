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

# Directories to create.
NEW_DIRS := $(BUILD_DIR) $(DIST_DIR)

## Directories to remove when cleaning.
CLEAN_DIRS := $(BUILD_DIR) $(DIST_DIR)



# Extract version numbers.
LATEST_TAG := $(shell git describe --abbrev=0 --tags 2> /dev/null || echo "v0.0.0")

VERSION_TRIMMED := $(patsubst v%,%,$(LATEST_TAG))
VERSION_SPLIT := $(subst ., ,$(VERSION_TRIMMED))

VERSION_MAJOR := $(word 1,$(VERSION_SPLIT))
VERSION_MINOR := $(word 2,$(VERSION_SPLIT))
VERSION_PATCH := $(word 3,$(VERSION_SPLIT))



# Debug, trace, etc flags.
## Depending on the environment variables:
## optimize, or debug optionnally switching the traces on.
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
		BUILD_SUBDIR := $(BUILD_SUBDIR)_trace
	endif
else
	OPT_CFLAGS += -O2
	BUILD_SUBDIR = release
	IS_RELEASE = 1
endif



# Polymorphism of the library.
SCALAR_TYPE ?= int

## The name of the library can be changed to accomodate polymorphism.
## The symbols are prefixed with the name of the library.
RA_LIB_NAME ?= resizable_array



# Name of the compiled files of the library.
RA_LIB_FILENAME := lib$(RA_LIB_NAME).so
RA_LIB_SONAME := $(RA_LIB_FILENAME).$(VERSION_MAJOR)
RA_LIB_VERSIONNED_FILENAME := $(RA_LIB_FILENAME).$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)


# General-purpose flags.
WARN_CFLAGS = -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes -Werror
DEP_CFLAGS = -MMD -MP

GLOBAL_CFLAGS := $(WARN_CFLAGS) $(DEP_CFLAGS) $(OPT_CFLAGS)
BUILD_PATH := $(BUILD_DIR)/$(BUILD_SUBDIR)

NEW_DIRS += $(BUILD_PATH)



# Compilation of the library.
RA_HDR_FILE := $(INC_DIR)/resizable_array.h
RA_HDR_BUILD := $(BUILD_PATH)/$(RA_LIB_NAME).h

RA_SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
RA_DEP_FILES := $(RA_SRC_FILES:$(SRC_DIR)/%.c=$(BUILD_PATH)/%.d)
RA_OBJ_FILES := $(RA_SRC_FILES:$(SRC_DIR)/%.c=$(BUILD_PATH)/%.o)

RA_CFLAGS := -fPIC $(GLOBAL_CFLAGS) -D"SCALAR_TYPE=$(SCALAR_TYPE)" -D"RA_LIB_NAME=$(RA_LIB_NAME)"
RA_CPPFLAGS := -I$(INC_DIR)
RA_LDFLAGS := -shared -Wl,-soname,$(RA_LIB_SONAME)
RA_LDLIBS :=

RA_LIB_FILE_BUILD := $(BUILD_PATH)/$(RA_LIB_FILENAME)
RA_LIB_SONAME_BUILD := $(BUILD_PATH)/$(RA_LIB_SONAME)
RA_LIB_VERSIONNED_BUILD := $(BUILD_PATH)/$(RA_LIB_VERSIONNED_FILENAME)

RA_LIB_FILE_DIST := $(DIST_DIR)/$(RA_LIB_FILENAME)
RA_LIB_SONAME_DIST := $(DIST_DIR)/$(RA_LIB_SONAME)
RA_LIB_VERSIONNED_DIST := $(DIST_DIR)/$(RA_LIB_VERSIONNED_FILENAME)



# Installation.
INSTALL_DIR ?= /usr/local
INSTALL_HDR_DIR ?= $(INSTALL_DIR)/include/$(RA_LIB_NAME)
INSTALL_LIB_DIR ?= $(INSTALL_DIR)/lib/$(RA_LIB_NAME)

NEW_DIRS += $(INSTALL_HDR_DIR) $(INSTALL_LIB_DIR)

RA_LIB_VERSIONNED_INSTALL := $(INSTALL_LIB_DIR)/$(RA_LIB_VERSIONNED_FILENAME)



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
TEST_CPPFLAGS := -I$(BUILD_PATH) -I$(TST_DIR)
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
lib: $(RA_HDR_BUILD) $(RA_LIB_FILE_BUILD) $(RA_LIB_SONAME_BUILD) $(RA_LIB_VERSIONNED_BUILD)

$(RA_HDR_BUILD): $(RA_HDR_FILE) | $(BUILD_PATH)
	@echo "/* Header automatically generated - Any modification will be lost */" > $@
	@echo "#ifndef $(RA_LIB_NAME)_H" >> $@
	@echo "#define $(RA_LIB_NAME)_H" >> $@
	@echo "#define SCALAR_TYPE $(SCALAR_TYPE)" >> $@
	@echo "#define RA_LIB_NAME $(RA_LIB_NAME)" >> $@
	@cat $(RA_HDR_FILE) >> $@
	@echo "#endif" >> $@


$(RA_LIB_FILE_BUILD): $(RA_LIB_SONAME_BUILD)
	ln -sf $(notdir $<) $@

$(RA_LIB_SONAME_BUILD): $(RA_LIB_VERSIONNED_BUILD)
	ln -sf $(notdir $<) $@

$(RA_LIB_VERSIONNED_BUILD): $(RA_OBJ_FILES) | $(BUILD_PATH)
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
$(TEST_BIN_FILES): $(BUILD_PATH)/%.tst: $(BUILD_PATH)/%.o $(RA_LIB_SONAME_BUILD) | $(BUILD_PATH)
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
copy-lib: $(RA_LIB_FILE_DIST) $(RA_LIB_SONAME_DIST) $(RA_LIB_VERSIONNED_DIST)

$(RA_LIB_VERSIONNED_DIST): $(RA_LIB_VERSIONNED_BUILD) | $(DIST_DIR)
	cp $< $@

$(RA_LIB_SONAME_DIST): $(RA_LIB_VERSIONNED_DIST)
	ln -sf $(notdir $<) $@

$(RA_LIB_FILE_DIST): $(RA_LIB_SONAME_DIST)
	ln -sf $(notdir $<) $@



.PHONY: install
install: install-headers install-lib

.PHONY: install-headers
install-headers: | $(INSTALL_HDR_DIR)
	install -m 0755 $(RA_HDR_BUILD) $(INSTALL_HDR_DIR)/

.PHONY: install-lib
install-lib: | $(INSTALL_LIB_DIR)
	install -m 0755 $(RA_LIB_VERSIONNED_DIST) $(RA_LIB_VERSIONNED_INSTALL)
	cd $(INSTALL_LIB_DIR); \
	ln -sf $(RA_LIB_VERSIONNED_FILENAME) $(RA_LIB_SONAME); \
	ln -sf $(RA_LIB_SONAME) $(RA_LIB_FILENAME)



.PHONY: version
version:
	@echo "Version $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)"



## Directory management.
$(NEW_DIRS):
	mkdir -p $@

.PHONY: clean
clean:
	$(RM) -r $(CLEAN_DIRS)



## All target files should be updated when the Makefile changes.
$(RA_LIB_FILE_DIST) $(RA_LIB_SONAME_DIST) $(RA_LIB_VERSIONNED_DIST) \
	$(RA_LIB_FILE_BUILD) \
	$(RA_HDR_BUILD) \
	$(RA_OBJ_FILES) \
	$(TEST_BIN_FILES) $(TEST_OBJ_FILES): Makefile
