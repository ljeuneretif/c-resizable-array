INSTALL_DIR ?= /usr/local
INSTALL_HDR_DIR ?= $(INSTALL_DIR)/include/$(RA_LIB_NAME)
INSTALL_LIB_DIR ?= $(INSTALL_DIR)/lib/$(RA_LIB_NAME)
INSTALL_PKG_DIR ?= $(INSTALL_DIR)/lib/pkgconfig

NEW_DIRS += $(INSTALL_HDR_DIR) $(INSTALL_LIB_DIR) $(INSTALL_PKG_DIR)



.PHONY: install install-headers install-lib install-pkgconfig \
	uninstall uninstall-headers uninstall-lib uninstall-pkgconfig



install: install-headers install-lib install-pkgconfig

install-headers: | $(INSTALL_HDR_DIR)
	install -m 0644 $(RA_HDR_BUILD) $(INSTALL_HDR_DIR)/

install-lib: | $(INSTALL_LIB_DIR)
	install -m 0755 $(RA_LIB_VERSIONNED_DIST) $(INSTALL_LIB_DIR)/$(RA_LIB_VERSIONNED_FILENAME)
	cd $(INSTALL_LIB_DIR); \
	ln -sf $(RA_LIB_VERSIONNED_FILENAME) $(RA_LIB_SONAME); \
	ln -sf $(RA_LIB_SONAME) $(RA_LIB_FILENAME)

install-pkgconfig: $(PKGCONFIG_DIST) | $(INSTALL_PKG_DIR)
	install -m 0644 $< $(INSTALL_PKG_DIR)/



uninstall: uninstall-headers uninstall-lib uninstall-pkgconfig

uninstall-headers:
	$(RM) $(INSTALL_HDR_DIR)/$(RA_LIB_NAME).h
	-rmdir $(INSTALL_HDR_DIR) 2>/dev/null || true

uninstall-lib:
	$(RM) $(INSTALL_LIB_DIR)/$(RA_LIB_FILENAME) \
				$(INSTALL_LIB_DIR)/$(RA_LIB_SONAME) \
				$(INSTALL_LIB_DIR)/$(RA_LIB_VERSIONNED_FILENAME)
	-rmdir $(INSTALL_LIB_DIR) 2>/dev/null || true

uninstall-pkgconfig:
	$(RM) $(INSTALL_PKG_DIR)/$(PKGCONFIG_FILE)
