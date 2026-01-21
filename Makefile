# ifeq ($(origin .RECIPEPREFIX), undefined)
#   $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
# endif
# .RECIPEPREFIX = >

# INITIAL VARS
CURRENT_MAKEFILE := $(lastword $(MAKEFILE_LIST))
_MKFILE_PATH = $(shell readlink $(CURRENT_MAKEFILE) || ls -1 $(CURRENT_MAKEFILE))
_MKFILE_REALPATH = $(abspath $(lastword $(_MKFILE_PATH)))
_MKFILE_REALPATH_DIR = $(dir $(abspath $(lastword $(_MKFILE_PATH))) )

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

## _TARGET_ENDPOINT_RAW_POSTFIX := Raw
_TARGET_ENDPOINT_UNKNOWN := unknown

##
_MK_DIR_THIS_MAKEFILE := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

#?_MK_IS_CTX_SRV_EXIST = 9
_ENVMAKEFILEPATH := $(call addprefix, $(_MKFILE_REALPATH_DIR), .envmake)
## INCLUSE BASE ENV-file `.envmake` OR SET DEFAULT

_INCPATH = $(_MKFILE_REALPATH_DIR)

ifneq (,$(wildcard $(_ENVMAKEFILEPATH)))
    _ENVMAKE_FILE_EXIST = 1
#ifeq ($(shell test -L $(CURRENT_MAKEFILE) && echo -n yes || echo -n no),no)
    include $(_ENVMAKEFILEPATH) 
#.envmake
#else
#	include .envmake
#endif
else
    _ENVMAKE_FILE_EXIST = 0

    _SRV_AFFIX ?= .yml
    _VOL_AFFIX ?= .yml
    _ENV_AFFIX ?= .env

    _MK_DIR_MKFILE ?= .mkfile/
    _MK_DIR_TEST   ?= .test/
    _MK_DIR_TEMPLATE ?= .template/
    _MK_DIR_CONTEXT  ?= .context/
    _MK_DIR_KVDB     ?= .kvdb/

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

    _MK_DC_TMPL_DEFAULT_ENV ?= .default.env
    _MK_DC_DEFAULT_ENV      ?= default.env

    _MK_FN_DC_DEFAULT_YML   ?= docker-compose.yml
    _MK_FN_DC_DEFAULT_ENV   ?= .env
    _MK_FN_DEFAULT_KVDB     ?= kv.db.txt
    _MK_FN_HELP_KVDB        ?= kv.help.db.txt

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

## KEYMAP
_MK_FN_PATH_RELATIVE_KVDB ?= $(call addprefix, $(_MK_DIR_KVDB), $(_MK_FN_DEFAULT_KVDB))
_MK_FN_PATH_KVDB ?= $(realpath $(_MK_FN_PATH_RELATIVE_KVDB))

# _MK_KEYMAP_FILES ?= $(_MK_FN_PATH_KVDB)
# include $(call addprefix, $(_MK_DIR_MKFILE), keymap.mk)

## B: INCLUDE LIBRARY mk-files
_MK_FILE_NAME_INCLUDE_LIST := const.mk io.console.mk condition.mk context.mk service.mk help.mk

# include $(_MK_FILE_FULLNAME_INCLUDE_LIST)
ifeq ($(shell test -L $(CURRENT_MAKEFILE) && echo -n yes || echo -n no),no)

_MK_FILE_FULLNAME_INCLUDE_LIST := $(strip $(foreach m, $(_MK_FILE_NAME_INCLUDE_LIST), $(call addprefix, $(_MK_DIR_MKFILE), $m)))
include $(_MK_FILE_FULLNAME_INCLUDE_LIST)

else

_MKFILE_LINK := 1
# _MKFILE_PATH = $(shell readlink $(CURRENT_MAKEFILE))
# _MKFILE_REALPATH = $(abspath $(lastword $(_MKFILE_PATH)))
# _MKFILE_REALPATH_DIR = $(dir $(abspath $(lastword $(_MKFILE_PATH))) )
# ?_MKFILE_REALPATH_DIR_MKFILE := $(call addprefix, $(_MKFILE_REALPATH_DIR), $(_MK_DIR_MKFILE))
# ?_MK_FILE_FULLNAME_INCLUDE_LIST := $(strip $(foreach m, $(_MK_FILE_NAME_INCLUDE_LIST), $(call addprefix, $(_MKFILE_REALPATH_DIR_MKFILE), $m)))
_MK_FILE_FULLNAME_INCLUDE_LIST := $(strip $(foreach m, $(_MK_FILE_NAME_INCLUDE_LIST), $(call addprefix, $(_MK_DIR_MKFILE), $m)))
include $(_MK_FILE_FULLNAME_INCLUDE_LIST)

endif
## E: INCLUDE LIBRARY mk-files

# _FILE_OF_MARK_CTX := $(call addprefix, $(_MKFILE_REALPATH_DIR), $(_MK_FN_DC_DEFAULT_ENV))
# CTX_CURRENT := $(notdir $(patsubst %/,%,$(dir $(shell echo -n  "`readlink $(_FILE_OF_MARK_CTX)`"))))


## INCLUDE CONFIG IF EXISTS - this file leaves the ability to redefine variables without editing the main files
ifneq ($(wildcard $(call addprefix, $(_MK_DIR_MKFILE), config.mk)),)
include $(call addprefix, $(_MK_DIR_MKFILE), config.mk)
endif

##	make -s $(1) CTX=$(CTX_CURRENT); 
##	make -s $(1);

# define __set_target_name
# printf "$(1)"
# endef

##
## __try_context_overwrite
##  build new `make` command using first parameter 
##  as name of new target (callback)
define __try_context_overwrite
	$(eval ifeq (,$(1)) 
		$(eval _TARGET_NAME_REDIRECT_RAW = $(addprefix $@, $(_TARGET_ENDPOINT_UNKNOWN)))
		else 
		$(eval _TARGET_NAME_REDIRECT_RAW = $(1))
	endif)

	$(eval NEW_COMMAND_VARIABLES = $(shell echo -n $(-*-command-variables-*-) | sed 's/\(CTX\=[^\ ]*\)//') )
	$(eval _TARGET_NAME_RAW = $(_TARGET_NAME_REDIRECT_RAW))

	@if [ "0" -eq "$(_MK_IS_CONTEX_EXIST)" ]; then \
		if [ "" = "$(CTX_CURRENT)" ]; then \
			$(call _mk_err, "Not found context - undefined CTX value and current context CTX_CURRENT not set"); printf "\n";\
		else \
			if [ "" = "$(CTX)" ]; then \
				make -s $(_TARGET_NAME_RAW) $(-*-command-variables-*-) CTX=$(CTX_CURRENT); \
			else \
				$(call _mk_warn, "Not found  context  CTX: '$(CTX)'."); \
				$(call _mk_warn, "Default behavior is set: CTX=CTX_CURRENT - '$(CTX_CURRENT)'"); \
				$(call _mk_ok, "– are you sure? [y/N]" ); \
				read answer \
				&& if [ $${answer:-'N'} = 'y' ]; then \
					make -s $(_TARGET_NAME_RAW) $(NEW_COMMAND_VARIABLES) CTX=$(CTX_CURRENT); \
				else \
					$(call _mk_inf, "Canceled..."); \
				fi; \
				printf "\n"; \
			fi; \
		fi; \
	else \
		make -s $(_TARGET_NAME_RAW) $(-*-command-variables-*-); \
	fi;
endef

# printf "cd $(_MKFILE_REALPATH_DIR) &&  make -s -f $(_MKFILE_REALPATH) $1 $(-*-command-variables-*-);";\
# make -s -f $(_MKFILE_REALPATH) $1 $(-*-command-variables-*-); 
#
#if [ "1" = "$(_MKFILE_LINK)" ]; then \
# 		printf "cd $(_MKFILE_REALPATH_DIR) &&  make -s -C $(_MKFILE_REALPATH_DIR) $1 $(-*-command-variables-*-);";\
# 		cd $(_MKFILE_REALPATH_DIR) \
# 		&& make -s -C $(_MKFILE_REALPATH_DIR) $1 $(-*-command-variables-*-) \
# 		&& exit 1; 
# fi; 
define __pre_target
	$(eval _MK_DIR_PATH_CONTEXT = $(call addprefix, $(_MKFILE_REALPATH_DIR),$(_MK_CTX_PATH)))
endef

## ARGS = $(foreach a,$($(subst -,_,$1)_args),$(if $(value $a),$a="$($a)"))
### TAGETs:
test:
#	@printf "$(CURRENT_MAKEFILE)"
#	@printf "$(MKFILE_PATH)"
	
	@printf "_ENVMAKEFILEPATH: $(_ENVMAKEFILEPATH)\n"
	@printf "_MKFILE_REALPATH_DIR: $(_MKFILE_REALPATH_DIR)\n"
	@printf "_MK_DIR_PATH_CONTEXT: $(_MK_DIR_PATH_CONTEXT)\n"
	@printf "CTX_CURRENT: $(CTX_CURRENT)\n"
	@printf "_MK_FN_DC_DEFAULT_ENV: $(_MK_FN_DC_DEFAULT_ENV)\n"
	@$(call _mk_inf,  "$@")
	@printf "\n"

test-%:
	@$(MAKE) --no-print-directory "$*.test";

### ---

#.PHONY: help
help: ## Show this help; `help.%`  —  detail helps; Check `help.about`
	@$(MAKE) --no-print-directory checkdeps ## > /dev/null
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

### ---


### ---

# INIT: new context - create directory (context) & copy files from '.default'
@PHONY: initCtx init.ctx ctx.init new.ctx ctx.new
initCtx: context_init ## Create new 'context'-folder: CTX=<context>
initCTX: initCtx
init.ctx: initCtx
ctx.init: initCtx
new.ctx: initCtx
ctx.new: initCtx

# Adds service to context - copy service template files (<SRV>.yml; <SRV>.env) to context (direcotry) 
# and update CTX template files: `dc.services.tmpl` and `dc.volumes.tmpl`
addCtxSrvRaw:   context_add_service
addCtxSrv: ## Add service to context:      SRV=<name> [SARGS=<service_args>]
	@$(call __try_context_overwrite, addCtxSrvRaw)
add.ctx.srv: addCtxSrv
ctx.add.srv: addCtxSrv
srv.add.ctx: addCtxSrv
srv.ctx.add: addCtxSrv

# .PHONY: checkdeps
checkdeps:
	@printf "\n"
# @echo -n "\nCheck dependencies"
# @echo -n "\n_ENVMAKE_FILE_EXIST: $(_ENVMAKE_FILE_EXIST)"
# @echo -n "\n_MKFILE_ENV: $(_MKFILE_ENV)"
# @echo -n "\n"
# @echo -n "\nCTX: get_context:" $(call get_context)


### ---

# CHECK: - is directory (context) present
#@PHONY: isCtx ctx.check check.ctx
isCtxRaw: context_check_is_exists
	@$(call _mk_run, "Context exist: '$(CTX)'" );
	@printf "\n"
isCtx: ## Check is  'context'  exists
	@$(call __try_context_overwrite, isCtxRaw)
isCTX: isCtx
check.ctx: isCtx
ctx.check: isCtx

### ---

# ADD: add context - add `env` for directory (context) & copy files from '.default'
# @PHONY: addCtx add.ctx ctx.add
# addCtx: context_add ## Add new 'env' from .default for CTX=<context>


# Prints exists contexts names
listCtx: context_list ## List all contexts
listCTX: listCtx
list.ctx: listCtx
ctx.list: listCtx

currentCtx: context_current ## Show current context
currentCTX: currentCtx
current.ctx: currentCtx
ctx.current: currentCtx
cur.ctx: currentCtx
ctx.cur: currentCtx
curCtx: currentCtx
curCTX: currentCtx

# Remove context - remove directory (context) & remove files
rmCtx: context_remove ## Remove 'context'-folder:     CTX=<context>
rmCTX: rmCtx
rm.ctx: rmCtx
ctx.rm: rmCtx

# Checks is exist service with given name
isSrv: ## Check is 'service'  template exists: SRV=<name>
ifeq (1, $(_MK_IS_SERVICE_EXIST))
	@$(call _mk_run, "Service exist: '$(SERVICE)'" )
	@$(call _mk_inf, "$(_MK_SRV_PATH)")
else
	@$(call _mk_warn, "Service not exist: '$(SERVICE)'" )
endif
	@printf "\n"


isSRV: isSrv

# Checks whether a service with the specified name exists in the specified context
isCtxSrvRaw: context_check_is_exists
	@$(call is_service_in_ctx_tmpl, _MK_IS_CTX_SRV_EXIST)

	@if [ "1" -eq "$(_MK_IS_CTX_SRV_EXIST)" ]; then \
		$(call _mk_run, "Service: '$(SERVICE)' enabled at CTX: '$(CTX)'" ); \
	else \
		$(call _mk_err, "Service: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
	fi;
	@printf "\n"
	
isCtxSrv: ## Check is service in context: SRV=<name>
	@$(call __try_context_overwrite, isCtxSrvRaw)

# Prints the list of know services
listSrv: service_list ## List all known services present in `template` folder
listAllSrv: listSrv
srv.all: listSrv
list.srv: listSrv
srv.list: listSrv
srv.list.all: listSrv
srv.listAll: listSrv
srvList: listSrv
listSRV: listSrv



listSrvVersionRaw: service_version_list
listSrvVersion: ## List services with versions: SRV=<name>
	@$(call __try_context_overwrite, listSrvVersionRaw)
list.srv.ver: listSrvVersion
srv.list.ver: listSrvVersion
srv.ver.list: listSrvVersion
listSrvVer: listSrvVersion
srvVerList: listSrvVersion


# Checks is service-file included to context service-template (`dc.services.tmpl`)
isCtxSrvEnabled:
	@$(call _mk_run, "isCtxSrvEnabled: '$(SERVICE)'" );
	@printf "\n"
	@$(call is_service_in_ctx_tmpl)


# Includes service file to context service-template (`dc.services.tmpl`)
enableCtxSrvRaw: context_enable_service
enableCtxSrv: ## Enable service in context:   SRV=<name>
	@$(call __try_context_overwrite, enableCtxSrvRaw)
enable.ctx.srv: enableCtxSrv
ctx.enable.srv: enableCtxSrv


# Excludes service file from services-template (`dc.services.tmpl`) for given context <CTX>
disableCtxSrvRaw: context_disable_service
disableCtxSrv:  ## Disable service in context:  SRV=<name>
	@$(call __try_context_overwrite, disableCtxSrvRaw)
disable.ctx.srv: disableCtxSrv
ctx.disable.srv: disableCtxSrv


# List services in context - prints list of services in context (directory)
listCtxSrvRaw: context_all_service_list 
listCtxSrv: ## List services in context
	@$(call __pre_target)
	@$(call __try_context_overwrite, listCtxSrvRaw)

list.ctx.srv: listCtxSrv
ctx.list.srv: listCtxSrv
srv.ctx.list: listCtxSrv

list.ctx.all.srv: listCtxSrv
ctx.list.srv.all: listCtxSrv
srv.all.ctx.list: listCtxSrv
# srv.all.list.ctx: listCtxSrv


# List enabled services - prints list of added services in context file `dc.services.tmpl`
listEnabledCtxSrvRaw: context_enabled_service_list 
listEnabledCtxSrv: ## List enabled services in context
	@$(call __try_context_overwrite, listEnabledCtxSrvRaw)
list.ctx.enabled.srv: listEnabledCtxSrv
ctx.list.srv.enabled: listEnabledCtxSrv
srv.enabled.ctx.list: listEnabledCtxSrv
srv.enabled.list.ctx: listEnabledCtxSrv

# Removes service from context - remove service files (<SRV>.yml; <SRV>.env) from context (directory)
# and clear services and volumes templates: `dc.services.tmpl` and `dc.volumes.tmpl`
rmCtxSrvRaw: context_remove_service
rmCtxSrv: ## Remove service from context: SRV=<name>
	@$(call __try_context_overwrite, rmCtxSrvRaw)
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
buildCtxRaw: context_build 
buildCtx: ## Build context  — create 'docker-compose.yml' & '.env' files
#	@$(call __pre_target, $@)
	@$(call __try_context_overwrite, buildCtxRaw)

build.ctx: buildCtx
ctx.build: buildCtx


# Clean current context files - remove 'docker-compose.yml' & '.env' files
## PHONY += rmCurrentCtx cleancontext clean.ctx ctx.clean
rmCurrentCtx: ## Remove current context soft link
#	@$(call __pre_target, $@)
	@rm -f .env
	@rm -f docker-compose.yml


# Set context as current - launch context files to root directory
## PHONY += setCurrentCtx setcontext set.ctx ctx.set
setCurrentCtx: context_check_is_exists ##rmCurrentCtx ## Set context as current default: CTX=<context>
	@$(eval _TARGET_RELATIVE_DEFAULT_YML=$(addprefix $(addprefix $(_MK_DIR_CONTEXT), $(CTX))/, $(_MK_FN_DC_DEFAULT_YML)))
	@$(eval _TARGET_RELATIVE_DEFAULT_ENV=$(addprefix $(addprefix $(_MK_DIR_CONTEXT), $(CTX))/, $(_MK_FN_DC_DEFAULT_ENV)))
	@$(shell echo -n "echo $(_TARGET_RELATIVE_DEFAULT_YML)")
	@$(shell echo -n "echo $(_TARGET_RELATIVE_DEFAULT_ENV)")
	@$(shell echo -n "echo CTX: $(CTX)")
	@ln -sfn $(_TARGET_RELATIVE_DEFAULT_YML) docker-compose.yml
	@ln -sfn $(_TARGET_RELATIVE_DEFAULT_ENV) .env

setcontext: setCurrentCtx
set.ctx: setCurrentCtx
ctx.set: setCurrentCtx

startInit: ## Start initial setup
	@$(call _mk_warn, "This script unpacks the basic structure of files – are you sure? [y/N]" );
	@read answer \
	&& if [ $${answer:-'N'} = 'y' ]; then \
		$(_MK_DIR_TEMPLATE)/makeinit.run; \
	else \
		$(call _mk_inf, "Canceled..."); \
	fi;
	@printf "\n"

## .PHONY: help.%
help.%: ## Show this help.%
	@$(call __pre_target, $@)
	$(eval _helpKey=$(shell printf "%s" $@ | sed 's/\./¦/g'))
#??	@printf "$(_helpKey)"
	@printf "\n"
	$(eval _MK_KEYMAP_FILES = $(realpath $(call addprefix, $(_MK_DIR_KVDB), $(_MK_FN_HELP_KVDB)) ))
	$(eval include $(call addprefix, $(_MK_DIR_MKFILE), keymap.mk))
	@printf "$(call keymap_val,$(_helpKey))"
	@printf "\n"


