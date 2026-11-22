RA_HDR_FILE := $(INC_DIR)/resizable_array.h
RA_HDR_BUILD := $(BUILD_DIR)/$(RA_LIB_NAME).h

RA_SRC_FILES := $(wildcard $(SRC_DIR)/*.c)
RA_SRC_BUILD := $(RA_SRC_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.c)



$(RA_HDR_BUILD): $(RA_HDR_FILE) | $(BUILD_DIR)
	sed -e 's|@SCALAR_TYPE@|$(SCALAR_TYPE)|g' \
			-e 's|@RA_LIB_NAME@|$(RA_LIB_NAME)|g' \
			$< > $@

$(RA_SRC_BUILD): $(BUILD_DIR)/%.c: $(SRC_DIR)/%.c | $(BUILD_DIR)
	sed -e 's|@SCALAR_TYPE@|$(SCALAR_TYPE)|g' \
			-e 's|@RA_LIB_NAME@|$(RA_LIB_NAME)|g' \
			$< > $@
