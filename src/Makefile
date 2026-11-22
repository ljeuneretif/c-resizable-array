.DEFAULT_GOAL := all
include ../common.mk



include $(SRC_DIR)/mk/generate-header-source.mk
include $(SRC_DIR)/mk/deps.mk
include $(SRC_DIR)/mk/lib-flags.mk
include $(SRC_DIR)/mk/lib-shared.mk
include $(SRC_DIR)/mk/lib-static.mk
include $(SRC_DIR)/mk/pkgconfig.mk
include $(SRC_DIR)/mk/out.mk
include $(SRC_DIR)/mk/install.mk



.PHONY: all
all: $(RA_HDR_OUT) \
	$(RA_LIB_SHARED_FILE_OUT) $(RA_LIB_SHARED_SONAME_OUT) $(RA_LIB_SHARED_VERSIONNED_OUT) \
	$(RA_LIB_STATIC_FILE_OUT) \
	$(PKGCONFIG_OUT)



ALL_MAKEFILES := $(sort $(MAKEFILE_DEPS) $(MAKEFILE_LIST))
$(RA_HDR_BUILD) $(RA_SRC_BUILD) $(PKGCONFIG_BUILD): $(ALL_MAKEFILES)



-include $(RA_DEP_FILES)
include $(ROOT_DIR)/rules.mk
