.DEFAULT_GOAL := all
include ../common.mk



include $(SRC_DIR)/mk/lib.mk
include $(SRC_DIR)/mk/out.mk
include $(SRC_DIR)/mk/install.mk



.PHONY: all

all: $(RA_HDR_OUT) \
	$(RA_LIB_FILE_BUILD) $(RA_LIB_SONAME_BUILD) $(RA_LIB_VERSIONNED_BUILD) \
	$(PKGCONFIG_BUILD)



ALL_MAKEFILES := $(sort $(MAKEFILE_DEPS) $(MAKEFILE_LIST))
$(RA_HDR_BUILD) $(RA_SRC_BUILD) $(PKGCONFIG_BUILD): $(ALL_MAKEFILES)



-include $(RA_DEP_FILES)
include $(ROOT_DIR)/rules.mk
