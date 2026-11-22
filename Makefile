.DEFAULT_GOAL := all
include common.mk
# The path of this current Makefile.
export MAKEFILE_DEPS := $(realpath $(firstword $(MAKEFILE_LIST)))


.PHONY: all clean dist out help \
	install install-headers install-lib-shared install-lib-static install-pkgconfig \
	lib test $(SUB_DIRS) \
	uninstall uninstall-headers uninstall-lib-shared uninstall-lib-static uninstall-pkgconfig \
	version


all: ## Compile and test the project (default target to release mode).
lib: ## Compile only the library files.
test: ## Test the library.
out: ## Copy the library files into the out folder.
install install-headers install-lib-shared install-lib-static install-pkgconfig: ## Install the library fully or partially.
uninstall uninstall-headers uninstall-lib-shared uninstall-lib-static uninstall-pkgconfig: ## Uninstall the library fully or partially.
version: ## Print the current version, based on git tag.
clean: ## Clean the files generated.


all dist out: test
	$(MAKE) -C $(SRC_DIR) $@

test: lib $(TST_DIR)

lib: $(SRC_DIR)

install install-headers install-lib-shared install-lib-static install-pkgconfig \
uninstall uninstall-headers uninstall-lib-shared uninstall-lib-static uninstall-pkgconfig:
	$(MAKE) -C $(SRC_DIR) $@

$(SUB_DIRS):
	$(MAKE) -C $@

version:
	@echo "Version $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)"

clean:
	$(RM) -r $(CLEAN_DIRS)

help:
	@echo "Usage make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets available:"
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""
	@echo "Configuration options:"
	@echo "  BUILD=build                   Type of build, valid builds are: $(VALID_BUILDS)"
	@echo "  SCALAR_TYPE=type              Type of the elements, default $(SCALAR_TYPE_DEFAULT)"
	@echo "  RA_LIB_NAME=name              Name of the library, default $(RA_LIB_NAME_DEFAULT)"
	@echo ""
	@echo "  INSTALL_DIR=path              Path to folder installing all generated files, defaults to $(INSTALL_DIR_DEFAULT)"
	@echo "  INSTALL_HDR_SUBDIR=subpath    Subpath rooted in INSTALL_DIR for generated header files, defaults to include/\$$(RA_LIB_NAME)"
	@echo "  INSTALL_LIB_SUBDIR=subpath    Subpath rooted in INSTALL_DIR for generated lib files, defaults to lib/\$$(RA_LIB_NAME)"
	@echo "  INSTALL_PKG_SUBDIR=subpath    Subpath rooted in INSTALL_DIR for pkg-config files, defaults to lib/pkgconfig"
	@echo "  INSTALL_HDR_DIR=path          Path to folder for the generated headers, overrides path above, defaults to $(INSTALL_DIR_DEFAULT)/include/\$$(RA_LIB_NAME)"
	@echo "  INSTALL_LIB_DIR=path          Path to folder for the generated lib files, overrides path above, defaults to $(INSTALL_DIR_DEFAULT)/lib/\$$(RA_LIB_NAME)"
	@echo "  INSTALL_PKG_DIR=path          Path to folder for the pkg-config files, overrides path above, defaults to $(INSTALL_DIR_DEFAULT)/$(INSTALL_PKG_SUBDIR_DEFAULT)"
