.DEFAULT_GOAL := all
include ../common.mk



include $(TST_DIR)/mk/mock.mk
include $(TST_DIR)/mk/run.mk



.PHONY: all

all: $(TEST_RUN)



ALL_MAKEFILES := $(sort $(MAKEFILE_DEPS) $(MAKEFILE_LIST))
$(MOCK_OBJ_FILES) $(TEST_OBJ_FILES): $(ALL_MAKEFILES)



include $(ROOT_DIR)/rules.mk
-include $(TEST_DEP_FILES) $(MOCK_DEP_FILES)
