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

#?_MK_IS_CTX_SRV_EXIST = 9

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
help: ## Show this help
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
isCtx: context_check_is_exists ## Check is  'context'  exists: CTX=<context>
	@$(call _mk_run, "Context exist: '$(CTX)'" );
	@printf "\n"
isCTX: isCtx
check.ctx: isCtx
ctx.check: isCtx

### ---

# INIT: new context - create directory (context) & copy files from '.default'
@PHONY: initCtx init.ctx ctx.init new.ctx ctx.new
initCtx: context_init ## Create new 'context'-folder: CTX=<context>
initCTX: initCtx
init.ctx: initCtx
ctx.init: initCtx
new.ctx: initCtx
ctx.new: initCtx

### ---

# ADD: add context - add `env` for directory (context) & copy files from '.default'
# @PHONY: addCtx add.ctx ctx.add
# addCtx: context_add ## Add new 'env' from .default for CTX=<context>


# Prints exists contexts names
listCtx: context_list ## List all contexts
listCTX: listCtx
list.ctx: listCtx
ctx.list: listCtx

# Remove context - remove directory (context) & remove files
rmCtx: context_remove ## Remove 'context'-folder:     CTX=<context>
rmCTX: rmCtx
rm.ctx: rmCtx
ctx.rm: rmCtx

# Checks is exist service with given name
isSrv: ## Check is 'service'  template exists: SRV=<service>
ifeq (1, $(_MK_IS_SERVICE_EXIST))
	@$(call _mk_run, "Service exist: '$(SERVICE)'" )
	@$(call _mk_inf, "$(_MK_SRV_PATH)")
else
	@$(call _mk_warn, "Service not exist: '$(SERVICE)'" )
endif
	@printf "\n"


isSRV: isSrv

# Checks whether a service with the specified name exists in the specified context
isCtxSrv: context_check_is_exists ## Check is service in context: CTX=<context> SRV=<service>
	@$(call is_service_in_ctx_tmpl, _MK_IS_CTX_SRV_EXIST)

	@if [ "1" -eq "$(_MK_IS_CTX_SRV_EXIST)" ]; then \
		$(call _mk_run, "Service: '$(SERVICE)' enabled at CTX: '$(CTX)'" ); \
	else \
		$(call _mk_err, "Service: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
	fi;
	@printf "\n"	

# Prints the list of know services
listSrv: service_list ## List all services in context
listSRV: listSrv


# Adds service to context - copy service template files (<SRV>.yml; <SRV>.env) to context (direcotry) 
# and update CTX template files: `dc.services.tmpl` and `dc.volumes.tmpl`
addCtxSrv:   context_add_service ## Add service to context:      CTX=<context> SRV=<service> [SARGS=<service_args>]
add.ctx.srv: addCtxSrv
ctx.add.srv: addCtxSrv
srv.add.ctx: addCtxSrv
srv.ctx.add: addCtxSrv


# Checks is service-file included to context service-template (`dc.services.tmpl`)
isCtxSrvEnabled:
	@$(call _mk_run, "isCtxSrvEnabled: '$(SERVICE)'" );
	@printf "\n"
	@$(call is_service_in_ctx_tmpl)


# Includes service file to context service-template (`dc.services.tmpl`)
enableCtxSrv: context_enable_service ## Enable service in context:   CTX=<context> SRV=<service>
enable.ctx.srv: enableCtxSrv
ctx.enable.srv: enableCtxSrv


# Excludes service file from services-template (`dc.services.tmpl`) for given context <CTX>
disableCtxSrv: context_disable_service ## Disable service in context:  CTX=<context> SRV=<service>
disable.ctx.srv: disableCtxSrv
ctx.disable.srv: disableCtxSrv

# Removes service from context - remove service files (<SRV>.yml; <SRV>.env) from context (directory)
# and clear services and volumes templates: `dc.services.tmpl` and `dc.volumes.tmpl`
rmCtxSrv: context_remove_service ## Remove service from context: CTX=<context> SRV=<service>
rm.ctx.srv: rmCtxSrv
ctx.rm.srv: rmCtxSrv
srv.rm.ctx: rmCtxSrv
srv.ctx.rm: rmCtxSrv


# Try to rescue some syntax errors, tries to eliminate discrepancies (WIP)
rescueCtxSrv: is_context_contain_service_entire ## Check and resque service files
resqueCtxSrv: rescueCtxSrv
rescue.ctx.srv: rescueCtxSrv
ctx.rescue.srv: rescueCtxSrv
srv.ctx.rescue: rescueCtxSrv


# Build context - create 'docker-compose.yml' & '.env' files
buildCtx: context_build ## Build context: CTX=<context> - create 'docker-compose.yml' & '.env' files
build.ctx: buildCtx
ctx.build: buildCtx

