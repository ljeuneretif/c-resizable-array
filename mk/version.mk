LATEST_TAG := $(shell git describe --abbrev=0 --tags 2> /dev/null || echo "v0.0.0")

VERSION_TRIMMED := $(patsubst v%,%,$(LATEST_TAG))
VERSION_SPLIT := $(subst ., ,$(VERSION_TRIMMED))

VERSION_MAJOR := $(word 1,$(VERSION_SPLIT))
VERSION_MINOR := $(word 2,$(VERSION_SPLIT))
VERSION_PATCH := $(word 3,$(VERSION_SPLIT))

VERSION := $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
