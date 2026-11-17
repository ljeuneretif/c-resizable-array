.PHONY: dist

# Copy the files ready to be distributed.
dist: $(RA_LIB_FILE_DIST) $(RA_LIB_SONAME_DIST) $(RA_LIB_VERSIONNED_DIST) $(PKGCONFIG_DIST)

$(RA_LIB_VERSIONNED_DIST): $(RA_LIB_VERSIONNED_BUILD) | $(DIST_DIR)
	cp $< $@

$(RA_LIB_SONAME_DIST): $(RA_LIB_VERSIONNED_DIST)
	ln -sf $(notdir $<) $@

$(RA_LIB_FILE_DIST): $(RA_LIB_SONAME_DIST)
	ln -sf $(notdir $<) $@

$(PKGCONFIG_DIST): $(PKGCONFIG_BUILD)
	cp $< $@
