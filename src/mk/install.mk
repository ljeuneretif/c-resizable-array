INSTALL_DIR_DEFAULT := /usr/local
INSTALL_HDR_SUBDIR_DEFAULT := include/$(RA_LIB_NAME)
INSTALL_LIB_SUBDIR_DEFAULT := lib/$(RA_LIB_NAME)
INSTALL_PKG_SUBDIR_DEFAULT := lib/pkgconfig

INSTALL_DIR ?= $(INSTALL_DIR_DEFAULT)
INSTALL_HDR_SUBDIR ?= $(INSTALL_HDR_SUBDIR_DEFAULT)
INSTALL_LIB_SUBDIR ?= $(INSTALL_LIB_SUBDIR_DEFAULT)
INSTALL_PKG_SUBDIR ?= $(INSTALL_PKG_SUBDIR_DEFAULT)

INSTALL_HDR_DIR ?= $(INSTALL_DIR)/$(INSTALL_HDR_SUBDIR)
INSTALL_LIB_DIR ?= $(INSTALL_DIR)/$(INSTALL_LIB_SUBDIR)
INSTALL_PKG_DIR ?= $(INSTALL_DIR)/$(INSTALL_PKG_SUBDIR)

NEW_DIRS += $(INSTALL_HDR_DIR) $(INSTALL_LIB_DIR) $(INSTALL_PKG_DIR)



.PHONY: install install-headers install-lib-shared install-lib-static install-pkgconfig \
	uninstall uninstall-headers uninstall-lib-shared uninstall-lib-static uninstall-pkgconfig



install: install-headers install-lib-shared install-lib-static install-pkgconfig

install-headers: $(RA_HDR_OUT) | $(INSTALL_HDR_DIR)
	install -m 0644 $(RA_HDR_OUT) $(INSTALL_HDR_DIR)/

install-lib-shared: $(RA_LIB_SHARED_VERSIONNED_OUT) | $(INSTALL_LIB_DIR)
	install -m 0755 $(RA_LIB_SHARED_VERSIONNED_OUT) $(INSTALL_LIB_DIR)/
	cd $(INSTALL_LIB_DIR) && \
	ln -sf $(RA_LIB_SHARED_VERSIONNED_FILENAME) $(RA_LIB_SHARED_SONAME) && \
	ln -sf $(RA_LIB_SHARED_SONAME) $(RA_LIB_SHARED_FILENAME)

install-lib-static: $(RA_LIB_STATIC_FILE_OUT) | $(INSTALL_LIB_DIR)
	install -m 0644 $(RA_LIB_STATIC_FILE_OUT) $(INSTALL_LIB_DIR)/

install-pkgconfig: $(PKGCONFIG_OUT) | $(INSTALL_PKG_DIR)
	install -m 0644 $< $(INSTALL_PKG_DIR)/



uninstall: uninstall-headers uninstall-lib-shared uninstall-lib-static uninstall-pkgconfig

uninstall-headers:
	$(RM) $(INSTALL_HDR_DIR)/$(RA_LIB_NAME).h
	-rmdir $(INSTALL_HDR_DIR) 2>/dev/null || true

uninstall-lib-shared:
	$(RM) $(INSTALL_LIB_DIR)/$(RA_LIB_SHARED_FILENAME) \
				$(INSTALL_LIB_DIR)/$(RA_LIB_SHARED_SONAME) \
				$(INSTALL_LIB_DIR)/$(RA_LIB_SHARED_VERSIONNED_FILENAME)
	-rmdir $(INSTALL_LIB_DIR) 2>/dev/null || true

uninstall-lib-static:
	$(RM) $(INSTALL_LIB_DIR)/$(RA_LIB_STATIC_FILENAME)
	-rmdir $(INSTALL_LIB_DIR) 2>/dev/null || true

uninstall-pkgconfig:
	$(RM) $(INSTALL_PKG_DIR)/$(PKGCONFIG_FILE)
