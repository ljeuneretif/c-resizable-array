ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR := $(ROOT_DIR:/=)

include $(ROOT_DIR)/mk/utils.mk
include $(ROOT_DIR)/mk/build.mk
include $(ROOT_DIR)/mk/paths.mk
include $(ROOT_DIR)/mk/version.mk
include $(ROOT_DIR)/mk/lib.mk
include $(ROOT_DIR)/mk/flags.mk
