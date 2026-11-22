PKGCONFIG_IN := $(SRC_DIR)/resizable_array.pc.in
PKGCONFIG_FILE := $(RA_LIB_NAME).pc
PKGCONFIG_BUILD := $(BUILD_DIR)/$(PKGCONFIG_FILE)



$(PKGCONFIG_BUILD): $(PKGCONFIG_IN) | $(BUILD_DIR)
	sed -e 's|@PREFIX@|$(INSTALL_DIR)|g' \
	    -e 's|@LIBDIR@|$(INSTALL_LIB_DIR)|g' \
	    -e 's|@INCLUDEDIR@|$(INSTALL_HDR_DIR)|g' \
	    -e 's|@LIBNAME@|$(RA_LIB_NAME)|g' \
	    -e 's|@VERSION@|$(VERSION)|g' \
	    $< > $@
