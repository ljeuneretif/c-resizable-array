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

PKGCONFIG_IN := $(SRC_DIR)/resizable_array.pc.in
PKGCONFIG_FILE := $(RA_LIB_NAME).pc
PKGCONFIG_BUILD := $(BUILD_PATH)/$(PKGCONFIG_FILE)
PKGCONFIG_DIST := $(DIST_DIR)/$(PKGCONFIG_FILE)


# TODO add support for static library.


# Directly write the polymorphed header.
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
	$(CC) $(RA_LDFLAGS) -o $@ $^ $(RA_LDLIBS)

$(RA_OBJ_FILES): $(BUILD_PATH)/%.o: $(SRC_DIR)/%.c | $(BUILD_PATH)
	$(CC) $(RA_CFLAGS) $(RA_CPPFLAGS) -o $@ -c $<


$(PKGCONFIG_BUILD): $(PKGCONFIG_IN) $(MAKEFILE_DEPS) | $(BUILD_PATH)
	sed -e 's|@PREFIX@|$(INSTALL_DIR)|g' \
	    -e 's|@LIBDIR@|$(INSTALL_LIB_DIR)|g' \
	    -e 's|@INCLUDEDIR@|$(INSTALL_HDR_DIR)|g' \
	    -e 's|@LIBNAME@|$(RA_LIB_NAME)|g' \
	    -e 's|@VERSION@|$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)|g' \
	    $< > $@
