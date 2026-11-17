.DEFAULT_GOAL := all
include common.mk
# The path of this current Makefile.
export MAKEFILE_DEPS := $(realpath $(firstword $(MAKEFILE_LIST)))


# Targets.
.PHONY: all clean dist help \
	install install-headers install-lib install-pkgconfig \
	lib test $(SUB_DIRS) \
	uninstall uninstall-headers uninstall-lib uninstall-pkgconfig \
	version

all: ## Compile and test the project (default target).
lib: ## Compile only the library files.
test: ## Test the library.
dist: ## Copy the library files into the dist folder.
install install-headers install-lib install-pkgconfig: ## Install the library fully or partially.
uninstall uninstall-headers uninstall-lib uninstall-pkgconfig: ## Uninstall the library fully or partially.
version: ## Print the current version, based on git tag.
clean: ## Clean the files generated.

all: dist
lib: $(SRC_DIR)
test: lib $(TST_DIR)
dist: test
	$(MAKE) -C $(SRC_DIR) $@
install install-headers install-lib install-pkgconfig: dist
	$(MAKE) -C $(SRC_DIR) $@
uninstall uninstall-headers uninstall-lib uninstall-pkgconfig:
	$(MAKE) -C $(SRC_DIR) $@
## Generic rule to enter sub-makefiles.
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
	@echo "  DEBUG=1           Activate debugging symbols and remove -O2"
	@echo "  TRACE=1           Activate traces"
	@echo "  SCALAR_TYPE=type  Type of the elements, default $(SCALAR_TYPE_DEFAULT)"
	@echo "  RA_LIB_NAME=name  Name of the library, default $(RA_LIB_NAME_DEFAULT)"
