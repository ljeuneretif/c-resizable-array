# Polymorphism of the library.
SCALAR_TYPE_DEFAULT := int
SCALAR_TYPE ?= $(SCALAR_TYPE_DEFAULT)

# The name of the library can be changed to accomodate polymorphism.
# The symbols of the library are prefixed with the name of the library.
RA_LIB_NAME_DEFAULT := resizable_array
RA_LIB_NAME ?= $(RA_LIB_NAME_DEFAULT)

RA_LIB_SHARED_FILENAME := lib$(RA_LIB_NAME).so
RA_LIB_SHARED_SONAME := $(RA_LIB_SHARED_FILENAME).$(VERSION_MAJOR)
RA_LIB_SHARED_VERSIONNED_FILENAME := $(RA_LIB_SHARED_FILENAME).$(VERSION)

RA_LIB_STATIC_FILENAME := lib$(RA_LIB_NAME).a


# If the tests should be run.
SHOULD_RUN_TESTS := 1
ifneq ($(SCALAR_TYPE),$(SCALAR_TYPE_DEFAULT))
	SHOULD_RUN_TESTS := 0
endif
ifneq ($(RA_LIB_NAME),$(RA_LIB_NAME_DEFAULT))
	SHOULD_RUN_TESTS := 0
endif

TEST_PREREQ :=
ifeq ($(SHOULD_RUN_TESTS),1)
	TEST_PREREQ += test
endif
