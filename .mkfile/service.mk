#_MAKEFILE_DIR_NAME := .mkfile
#_SERVICE_MAKEFILE_REL_PATH := $(dir $(firstword $(foreach F, $(MAKEFILE_LIST) , $(if $(findstring $(_MAKEFILE_DIR_NAME),$F),$F)) ))
__is_service := 1

_MKFILE_CONTEXT_ROOT_DIR_PATH := $(realpath $(shell dirname $(firstword $(MAKEFILE_LIST))))
_MKFILE_CONTEXT_DIR_MKFILE := .mkfile
_MK_DIR_PATH_MKFILE ?= $(_MKFILE_CONTEXT_ROOT_DIR_PATH)/$(_MKFILE_CONTEXT_DIR_MKFILE)


# _MKFILE_CONTEXT_REL_PATH := $(dir $(firstword $(foreach F, $(MAKEFILE_LIST) , $(if $(findstring $(_MKFILE_DIR_NAME),$F),$F)) ))
ifneq ($(__is_io_console),"1")
ifneq ("$(wildcard $(_MK_DIR_PATH_MKFILE)/io.console.mk)","")
_IOCONSOLE_FILE_EXIST := 1
else
_IOCONSOLE_FILE_EXIST := 0
endif
endif

_MK_IS_SERVICE_EXIST = 0
_MK_NO_SRV_CHECK_EARLY_EXIT = 0

_MK_DEFAULT_SERVICE_EXTENSION := .yml
_MK_LOG_MODE := default

ifneq ($(LOG_MODE),)
_MK_LOG_MODE := $(LOG_MODE)
endif

define set_service_exists
_MK_IS_SERVICE_EXIST = $(1)
endef

#SRV ?= default

# SET SERVICE - dir name with init variable files
ifneq ($(SRV),)
SERVICE := $(SRV)
endif
ifneq ($(SERVICE),)
SRV := $(SERVICE)
endif

ifneq (,$(NEWSRV))
_MK_SRV_FILE := $(NEWSRV)
NEWSERVICE  := $(NEWSRV)
SRV := $(NEWSRV)
endif

ifneq (,$(NEWSERVICE))
_MK_SRV_FILE := $(NEWSERVICE)
NEWSRV := $(NEWSERVICE)
SRV := $(NEWSERVICE)
endif

ifneq (,$(SRV))
_MK_SRV_FILE := $(SRV)
NEWSERVICE  := $(SRV)
NEWSRV := $(SRV)
endif

define get_service =
$(SRV)
endef

## Set service path & check is service file exists
$(eval _MK_SRV_FILE=$(addprefix $(SRV), $(_MK_DEFAULT_SERVICE_EXTENSION)))
$(eval _MK_SRV_PATH=$(addprefix $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES)/, $(_MK_SRV_FILE)))
$(if $(wildcard  $(_MK_SRV_PATH)), $(eval _MK_IS_SERVICE_EXIST = 1),$(eval _MK_IS_SERVICE_EXIST = 0))


define get_context_path =
$(_MK_CTX_PATH)
endef

## empty while parameter VERSION is unset
_SERVICE_VERSION:=


## Return is service exists.
define is_service_exists =
$(_MK_IS_SERVICE_EXIST)
endef



