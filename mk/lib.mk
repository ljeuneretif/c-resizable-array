# Polymorphism of the library.
SCALAR_TYPE_DEFAULT := int
SCALAR_TYPE ?= $(SCALAR_TYPE_DEFAULT)

# The name of the library can be changed to accomodate polymorphism.
# The symbols of the library are prefixed with the name of the library.
RA_LIB_NAME_DEFAULT := resizable_array
RA_LIB_NAME ?= $(RA_LIB_NAME_DEFAULT)

RA_LIB_FILENAME := lib$(RA_LIB_NAME).so
RA_LIB_SONAME := $(RA_LIB_FILENAME).$(VERSION_MAJOR)
RA_LIB_VERSIONNED_FILENAME := $(RA_LIB_FILENAME).$(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)
