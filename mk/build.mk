VALID_BUILDS := release debug trace

ifneq ($(filter $(VALID_BUILDS),$(MAKECMDGOALS)),)
    BUILD := $(firstword $(filter $(VALID_BUILDS),$(MAKECMDGOALS)))
else
    BUILD ?= release
endif

ifeq ($(filter $(BUILD),$(VALID_BUILDS)),)
    $(error Unknown build: '$(BUILD)'. Choose among: $(VALID_BUILDS))
endif

BUILD_SUBDIR := $(BUILD)
