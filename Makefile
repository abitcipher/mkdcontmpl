# ifeq ($(origin .RECIPEPREFIX), undefined)
#   $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
# endif
# .RECIPEPREFIX = >

# INITIAL VARS
.DEFAULT_GOAL := help
_ENVMAKE_FILE_EXIST = 0

EARLYEXIT ?= 1
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

##
_MK_DIR_THIS_MAKEFILE := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

## INCLUSE BASE ENV-file `.envmake` OR SET DEFAULT
ifneq (,$(wildcard .envmake))
    _ENVMAKE_FILE_EXIST = 1
    include .envmake
else
    _ENVMAKE_FILE_EXIST = 0

    _SRV_AFFIX ?= .yml
    _VOL_AFFIX ?= .yml
    _ENV_AFFIX ?= .env

    _MK_DIR_MKFILE ?= .mkfile/
    _MK_DIR_TEST   ?= .test/
    _MK_DIR_TEMPLATE ?= .template/
    _MK_DIR_CONTEXT  ?= .context/

    _MK_DIR_DOCKER_COMPOSE ?= docker.compose/
    _MK_DIR_DOCKER_COMPOSE_ENV ?= docker.compose.env/
    _MK_DIR_YML_SERVICES ?= services/
    _MK_DIR_YML_VOLUMES  ?= volumes/

    _MK_DIR_TARGET_CTX_TMPL ?= .tmpl/
    _MK_DIR_TARGET_CTX_YML  ?= .yml/
    _MK_DIR_TARGET_CTX_ENV  ?= .env/

    _MK_DC_TMPL_HEAD     ?= dc.head.tmpl
    _MK_DC_TMPL_NETWORK  ?= dc.network.tmpl
    _MK_DC_TMPL_SERVICES ?= dc.services.tmpl
    _MK_DC_TMPL_TAIL     ?= dc.tail.tmpl
    _MK_DC_TMPL_MAIN     ?= dc.tmpl
    _MK_DC_TMPL_VOLUMES  ?= dc.volumes.tmpl

    _MK_DIR_TEMPLATE_DOCKER_COMPOSE = $(_MK_DIR_TEMPLATE)$(_MK_DIR_DOCKER_COMPOSE)
    _MK_DIR_TEMPLATE_DOCKER_COMPOSE_ENV = $(_MK_DIR_TEMPLATE)$(_MK_DIR_DOCKER_COMPOSE_ENV)
    _MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES = $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE)$(_MK_DIR_YML_SERVICES)
    _MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_VOLUMES = $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE)$(_MK_DIR_YML_VOLUMES)
    _MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE = $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE)$(_MK_DIR_TEMPLATE)
endif

_MK_DIR_PATH_MKFILE = $(realpath $(_MK_DIR_MKFILE))
_MK_DIR_PATH_TEST = $(realpath $(_MK_DIR_TEST))
_MK_DIR_PATH_TEMPLATE ?= $(realpath $(_MK_DIR_TEMPLATE))
_MK_DIR_PATH_CONTEXT ?= $(realpath $(_MK_DIR_CONTEXT))

_MK_DIR_PATH_DOCKER_COMPOSE = $(realpath $(_MK_DIR_DOCKER_COMPOSE))
_MK_DIR_PATH_DOCKER_COMPOSE_ENV ?= $(realpath $(_MK_DIR_DOCKER_COMPOSE_ENV))
_MK_DIR_PATH_YML_SERVICES ?= $(realpath $(_MK_DIR_YML_SERVICES))
_MK_DIR_PATH_YML_VOLUMES ?= $(realpath $(_MK_DIR_YML_VOLUMES))

_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE = $(realpath $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE))
_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_ENV = $(realpath $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE_ENV))
_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES = $(realpath $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES))
_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_VOLUMES = $(realpath $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_VOLUMES))
_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE = $(realpath $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE))

## INCLUDE LIBRARY mk-files
_MK_FILE_NAME_INCLUDE_LIST := const.mk io.console.mk condition.mk context.mk service.mk help.mk
_MK_FILE_FULLNAME_INCLUDE_LIST := $(strip $(foreach m, $(_MK_FILE_NAME_INCLUDE_LIST), $(call addprefix, $(_MK_DIR_MKFILE), $m)))

include $(_MK_FILE_FULLNAME_INCLUDE_LIST)

## INCLUDE CONFIG IF EXISTS - this file leaves the ability to redefine variables without editing the main files
ifneq ($(wildcard $(call addprefix, $(_MK_DIR_MKFILE), config.mk)),)
include $(call addprefix, $(_MK_DIR_MKFILE), config.mk)
endif

## ARGS = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))
### TAGETs:
test:
	@$(call _mk_inf,  "$@")
	@printf "\n"

test-%:
	@$(MAKE) --no-print-directory "$*.test";

### ---

.PHONY: help
help: ##@other Show this help
	@$(MAKE) --no-print-directory checkdeps ## > /dev/null
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

### ---

.PHONY: checkdeps
checkdeps:
	@printf "\n"
# @echo -n "\nCheck dependencies"
# @echo -n "\n_ENVMAKE_FILE_EXIST: $(_ENVMAKE_FILE_EXIST)"
# @echo -n "\n_MKFILE_ENV: $(_MKFILE_ENV)"
# @echo -n "\n"
# @echo -n "\nCTX: get_context:" $(call get_context)


### ---

# CHECK: - is directory (context) present
@PHONY: isCtx ctx.check check.ctx
isCtx: context_check_is_exists ##@other Check is 'context' exists: CTX=<context>
	@$(call _mk_run, "Context exist: '$(CTX)'" );
	@printf "\n"
isCTX: isCtx
check.ctx: isCtx
ctx.check: isCtx

### ---

# INIT: new context - create directory (context) & copy files from '.default'
@PHONY: initCtx init.ctx ctx.init new.ctx ctx.new
initCtx: context_init ##@other Create new 'context' from .default: NEWCTX=<context>
initCTX: initCtx
init.ctx: initCtx
ctx.init: initCtx
new.ctx: initCtx
ctx.new: initCtx

### ---

# ADD: add context - add `env` for directory (context) & copy files from '.default'
# @PHONY: addCtx add.ctx ctx.add
# addCtx: context_add ##@other Add new 'env' from .default for CTX=<context>

listCtx: context_list ##@other List all contexts
listCTX: listCtx
list.ctx: listCtx
ctx.list: listCtx

rmCtx: context_remove ##@other Remove context: CTX=<context>
rmCTX: rmCtx
rm.ctx: rmCtx
ctx.rm: rmCtx


isSrv: service_check_is_exists ##@other Check is 'service' exists: SNAME=<service>
	@$(call _mk_run, "Service exist: '$(SERVICE)'" );
	@printf "\n"
isSRV: isSrv

listSrv: service_list ##@other List all services in context
listSRV: listSrv

addCtxSrv:   context_add_service ##@other Add service to context: CTX=<context> SNAME=<service> [SARGS=<service_args>]
add.ctx.srv: addCtxSrv
ctx.add.srv: addCtxSrv
srv.add.ctx: addCtxSrv
srv.ctx.add: addCtxSrv


rmCtxSrv: context_remove_service ##@other Remove service from context: CTX=<context> SNAME=<service>
rm.ctx.srv: rmCtxSrv
ctx.rm.srv: rmCtxSrv
srv.rm.ctx: rmCtxSrv
srv.ctx.rm: rmCtxSrv

rescueCtxSrv: is_context_contain_service_entire ##@other Check and resque service files
resqueCtxSrv: rescueCtxSrv
rescue.ctx.srv: rescueCtxSrv
ctx.rescue.srv: rescueCtxSrv
srv.ctx.rescue: rescueCtxSrv

buildCtx: context_build ##@other Build context: CTX=<context>
build.ctx: buildCtx
ctx.build: buildCtx
