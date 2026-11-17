.PHONY: out

# Copy the files ready to be distributed.
out: $(RA_LIB_FILE_OUT) $(RA_LIB_SONAME_OUT) $(RA_LIB_VERSIONNED_OUT) $(PKGCONFIG_OUT)

$(RA_LIB_VERSIONNED_OUT): $(RA_LIB_VERSIONNED_BUILD) | $(OUT_DIR)
	cp $< $@

$(RA_LIB_SONAME_OUT): $(RA_LIB_VERSIONNED_OUT)
	ln -sf $(notdir $<) $@

$(RA_LIB_FILE_OUT): $(RA_LIB_SONAME_OUT)
	ln -sf $(notdir $<) $@

$(PKGCONFIG_OUT): $(PKGCONFIG_BUILD)
	cp $< $@
