# Input dirs.
INC_DIR := $(call require_path,$(ROOT_DIR)/src)
SRC_DIR := $(call require_path,$(ROOT_DIR)/src)
TST_DIR := $(call require_path,$(ROOT_DIR)/tst)

SUB_DIRS := $(sort $(INC_DIR) $(SRC_DIR) $(TST_DIR))



# Output dirs.
BUILD_ROOT_DIR := $(ROOT_DIR)/build
OUT_DIR := $(ROOT_DIR)/out

BUILD_DIR ?= $(BUILD_ROOT_DIR)/$(BUILD)



# Directories to create as required by the operation demanded.
NEW_DIRS := $(BUILD_ROOT_DIR) $(OUT_DIR) $(BUILD_DIR)



# Directories to remove when cleaning.
CLEAN_DIRS := $(BUILD_ROOT_DIR) $(OUT_DIR)
