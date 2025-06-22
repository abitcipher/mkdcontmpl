# SHELL := /bin/bash
DATA  := .
DATATMPL := ..

_MK_RELPATH_MKFILE ?= ../../
_MK_DIR_MKFILE ?= $(addprefix $(_MK_RELPATH_MKFILE), .mkfile/)

## CHECK SHELL SETUP
_MAKEFILE_KNOWN_SHELL := /bin/sh /bin/bash /usr/bin/tcsh /bin/zsh /home/linuxbrew/.linuxbrew/bin/nu
_MAKEFILE_DEFSHELL := $(SHELL)
#SHELL =
#SHELLFLAGS :=

_MAKEFILE_KNOWN_SHELL_NAME := $(strip $(foreach a,$(_MAKEFILE_KNOWN_SHELL),$(call notdir,$a)))

ifneq ("$(wildcard $(USESHELL))","")
ifneq ($(filter $(call notdir, $(USESHELL)),$(_MAKEFILE_KNOWN_SHELL_NAME)),)
#    $(info Current shell is: $(USESHELL) )
    SHELL = $(USESHELL)
else
    $(info Unknown shell: $(USESHELL); Use default: $(SHELL))
endif
endif

_MK_DIR_THIS_MAKEFILE := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

## INCLUDE LIBRARY mk-files
_MK_FILE_NAME_INCLUDE_LIST := const.mk io.console.mk condition.mk context.mk service.mk help.mk
_MK_FILE_FULLNAME_INCLUDE_LIST := $(strip $(foreach m, $(_MK_FILE_NAME_INCLUDE_LIST), $(call addprefix, $(_MK_DIR_MKFILE), $m)))

include $(_MK_FILE_FULLNAME_INCLUDE_LIST)

.PHONY = $(PHONY)
all: test


test:
	@$(call _mk_inf,  "$@")
	@printf "\n"
