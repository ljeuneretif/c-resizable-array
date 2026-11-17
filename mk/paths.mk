INC_DIR := $(call require_path,$(ROOT_DIR)/src)
SRC_DIR := $(call require_path,$(ROOT_DIR)/src)
TST_DIR := $(call require_path,$(ROOT_DIR)/tst)

SUB_DIRS = $(sort $(INC_DIR) $(SRC_DIR) $(TST_DIR))

BUILD_DIR = $(ROOT_DIR)/build
DIST_DIR = $(ROOT_DIR)/dist

# Directories to create.
NEW_DIRS := $(BUILD_DIR) $(DIST_DIR)

# Directories to remove when cleaning.
CLEAN_DIRS := $(BUILD_DIR) $(DIST_DIR)
