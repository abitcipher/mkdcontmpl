# INCLUDE LIBs *.mk
# ?.DEFAULT_GOAL := test
__is_context := 1
#
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

_MK_IS_CONTEX_EXIST = 0
_MK_NO_CTX_CHECK_EARLY_EXIT = 0


_MK_LOG_MODE := default
ifneq ($(LOG_MODE),)
	_MK_LOG_MODE := $(LOG_MODE)
endif

DEF_CTX := default

_MK_DEF_ENV_DIR  :=

_MK_ENV_SRC_DIRS := .


_TEMPLATE_DEFAULT_DIR_PATH ?= $(_MK_DIR_PATH_TEMPLATE)/$(DEF_CTX)

# SET CONTEXT - dir name with init variable files
ifneq ($(CONTEXT),)
CTX := $(CONTEXT)
endif

ifneq (,$(NEWCTX)) 
_MK_CTX_DIR := $(NEWCTX)
NEWCONTEXT  := $(NEWCTX)
CTX := $(NEWCTX)
endif

ifneq (,$(NEWCONTEXT)) 
_MK_CTX_DIR := $(NEWCONTEXT)
NEWCTX := $(NEWCONTEXT)
CTX := $(NEWCONTEXT)
endif

ifneq (,$(CTX)) 
_MK_CTX_DIR := $(CTX)
NEWCONTEXT  := $(CTX)
NEWCTX := $(CTX)
endif

## Return context name
define get_context =
$(CTX)
endef


# For CTX set context directory path
$(eval _MK_CTX_DIR=$(CTX))
$(eval _MK_CTX_PATH=$(addprefix $(_MK_DIR_PATH_CONTEXT)/, $(_MK_CTX_DIR)))


### TEMPLATE PATHs + include pattern
$(eval _MK_DIR_TARGET_CTX_YML_MASKED = $(subst .,\., $(subst /,\/, $(_MK_DIR_TARGET_CTX_YML))))

$(eval _MK_PATH_TARGET_SERVICE_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_SERVICES)))
$(eval _MK_SERVICE_MASKED_RELATIVE_FILE_PATH = ..\\/$(_MK_DIR_TARGET_CTX_YML_MASKED)$(SRV).service$(_SRV_AFFIX))
$(eval _NEW_INCLUDE_SRV = {% include '$(_MK_SERVICE_MASKED_RELATIVE_FILE_PATH)' %})

$(eval _MK_PATH_TARGET_VOLUME_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_VOLUMES)))
$(eval _MK_VOLUME_MASKED_RELATIVE_FILE_PATH = ..\\/$(_MK_DIR_TARGET_CTX_YML_MASKED)$(SRV).volume$(_VOL_AFFIX))
$(eval _NEW_INCLUDE_VOL = {% include '$(_MK_VOLUME_MASKED_RELATIVE_FILE_PATH)' %})

## 
## B: SERVICE PART - for service linked targets
$(eval _SRV_SRC_FILE_NAME = $(addprefix $(SRV),$(_SRV_AFFIX)))
$(eval _VOL_SRC_FILE_NAME = $(addprefix $(SRV),$(_VOL_AFFIX)))
$(eval _ENV_SRC_FILE_NAME = $(addprefix $(SRV),$(_ENV_AFFIX)))

$(eval _SRV_TARGET_FILE_NAME = $(addprefix $(SRV),$(addprefix ".service",$(_SRV_AFFIX))))
$(eval _VOL_TARGET_FILE_NAME = $(addprefix $(SRV),$(addprefix ".volume",$(_VOL_AFFIX))))
$(eval _ENV_TARGET_FILE_NAME = $(addprefix $(SRV),$(_ENV_AFFIX)))

$(eval _SRV_SRC_FILE_PATH = $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES)/$(_SRV_SRC_FILE_NAME))
$(eval _VOL_SRC_FILE_PATH = $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_VOLUMES)/$(_VOL_SRC_FILE_NAME))
$(eval _ENV_SRC_FILE_PATH = $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_ENV)/$(_ENV_SRC_FILE_NAME))

$(eval _CTX_TARGET_YML_PATH=$(addprefix $(_MK_CTX_PATH)/,$(_MK_DIR_TARGET_CTX_YML)))
$(eval _CTX_TARGET_ENV_PATH=$(addprefix $(_MK_CTX_PATH)/,$(_MK_DIR_TARGET_CTX_ENV)))

$(eval _CTX_SRV_TARGET_FILE_PATH = $(addprefix $(_CTX_TARGET_YML_PATH),$(_SRV_TARGET_FILE_NAME)))
$(eval _CTX_VOL_TARGET_FILE_PATH = $(addprefix $(_CTX_TARGET_YML_PATH),$(_VOL_TARGET_FILE_NAME)))
$(eval _CTX_ENV_TARGET_FILE_PATH = $(addprefix $(_CTX_TARGET_ENV_PATH),$(_ENV_TARGET_FILE_NAME)))

$(eval _MK_DIR_PATH_TARGET_CTX_YML  = $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_YML)))
$(eval _MK_DIR_PATH_TARGET_CTX_ENV  = $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_ENV)))
$(eval _MK_DIR_PATH_TARGET_CTX_TMPL = $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)))


_MK_CTX_SERVICE_DISABLE_ENV := 0
_MK_CTX_SERVICE_DISABLE_VOL := 0
_MK_CTX_SERVICE_DISABLE_SRV := 0

## Checks is CTX service files exists
ifeq ($(shell test -f $(_CTX_SRV_TARGET_FILE_PATH) \
			&& test -f $(_CTX_VOL_TARGET_FILE_PATH) \
 			&& test -f $(_CTX_ENV_TARGET_FILE_PATH) \
 			&& echo -n yes),yes)
_MK_IS_CTX_SERVICE_EXIST := 1
else
_MK_IS_CTX_SERVICE_EXIST := 0

## B: Checks every file needed for service (SRV) describe in context (CTX)
ifeq ($(shell  ! test -f $(_CTX_ENV_TARGET_FILE_PATH) && echo -n no),no) 
_MK_CTX_SERVICE_DISABLE_ENV := 1
endif
ifeq ($(shell  ! test -f $(_CTX_VOL_TARGET_FILE_PATH) && echo -n no),no) 
_MK_CTX_SERVICE_DISABLE_VOL := 1
endif
ifeq ($(shell  ! test -f $(_CTX_SRV_TARGET_FILE_PATH) && echo -n no),no) 
_MK_CTX_SERVICE_DISABLE_SRV := 1
endif
## E: Checks every file needed for service describe in context

endif

## ??? why it no work:ifneq ($(wildcard $(_CTX_SRV_TARGET_FILE_PATH)),)
ifeq ($(shell test -f $(_CTX_SRV_TARGET_FILE_PATH) && echo -n yes),yes)
_CTX_SRV := 1
else
_CTX_SRV := 0
endif

## ??? why it no work: ifneq ($(strip $(_CTX_VOL_EXIST)),)
ifeq ($(shell test -f $(_CTX_VOL_TARGET_FILE_PATH) && echo -n yes),yes)
_CTX_VOL := 1
else
_CTX_VOL := 0
endif
## E: SERVICE PART - for service linked targets


##
## Return context directory path
define get_context_path =
$(_MK_CTX_PATH)
endef 

ifneq (,$(CTX)) 
ifneq (,$(wildcard $(call get_context_path)))
$(eval _MK_IS_CONTEX_EXIST = 1)
endif
endif


## Return is context exists
define is_context_exists = 
$(_MK_IS_CONTEX_EXIST)
endef


## Check is context exists - if does't, then exit with error
context_check_is_exists: ##@other Check is context exists
ifeq ($(_MK_IS_CONTEX_EXIST),0)
	$(call error, "CONTEX: not found...")
endif


## Init context - create directory structure with default files
context_init:
ifeq (1,$(call is_context_exists))
	@$(call error, "CTX: '$(CTX)' - context reinit forbidden")
endif

ifeq (1,$(call is_context_exists))
	@$(call _mk_warn, "CTX: Attempt to rеwrite files at existing namespace.");
	@$(call _mk_warn, "     If you really want to overwrite config files with default ones");
	@$(call _mk_warn, "     please use the explicit parameter - UNLOCK_EXIST_CTX=1");
	@printf "\n";
	@exit 1;
else
	@$(shell $(MKDIR) -p $(_MK_CTX_PATH))
	@$(if $(wildcard  $(_MK_CTX_PATH)), $(call _mk_inf, "CTX: created"), $(call _mk_inf, "CTX: $(_MK_COLOR_TERM_RED)$(_MK_CTX_PATH) - failed..." ) )

	@$(shell $(LN) $(addprefix ../../, $(addprefix $(_MK_DIR_TEMPLATE), $(DEF_CTX)/Makefile))  $(_MK_CTX_PATH)/Makefile )

	@$(shell $(MKDIR) $(_MK_DIR_PATH_TARGET_CTX_TMPL))
	@$(shell $(MKDIR) $(_MK_DIR_PATH_TARGET_CTX_YML))
	@$(shell $(MKDIR) $(_MK_DIR_PATH_TARGET_CTX_ENV))

	@$(shell $(CP) $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE)/* $(_MK_DIR_PATH_TARGET_CTX_TMPL))
##  ?copy empty defaault files?	
	@$(if $(wildcard  $(_MK_DIR_PATH_TARGET_CTX_TMPL)), $(call _mk_inf, "CTX: template added"), $(call _mk_err, "CTX: $(_MK_DIR_PATH_TARGET_CTX_TMPL) - failed to copy template files...") )
	@$(call _mk_done, "initcontext: $(_MK_CTX_PATH)")
	@printf "\n"
endif

## Get context - print path to context directory
context_get: context_check_is_exists
	@$(call _mk_inf, "CTX @: $(_MK_CTX_PATH)")
	@printf "\n" 

## List all contexts - print in two columns
context_list:
	@$(SHELL) -c "ls -1 $(_MK_DIR_PATH_CONTEXT) | sort | pr -2 -t"
	@printf "\n";

## Remove context - remove directory with context files
context_remove: context_check_is_exists
ifeq (1,$(call is_context_exists))
	@$(call _mk_inf, "$(CTX)");
	@$(call _mk_warn, "This context will be removed are you sure? [y/N] ");
	@read answer \
	&& if [ $${answer:-'N'} = 'y' ]; then \
		rm -rf $(_MK_CTX_PATH); \
		if [ ! -d "$(_MK_CTX_PATH)" ]; \
		then \
			$(call _mk_ok, "Successfully removed: $(CTX)"); \
		else \
			$(call _mk_err, "Unsuccessful remove: $(CTX)"); \
		fi; \
	else \
		$(call _mk_inf, "Canceled..."); \
	fi;
	@printf "\n"
endif
ifneq (1,$(call is_context_exists))
	@$(call _mk_inf, "$(CTX) - context is not exists");
	@printf "\n";
endif


## Check if service file exists in given context and all files present
is_context_contain_service_entire: context_check_is_exists
#? service_exit_is_not_exists
# AND (&&) logic:
ifeq ($(filter 0,$(_CTX_SRV) $(_CTX_VOL)), )
	@$(call _mk_inf, "Service and Volume file exists in CTX: $(CTX)")
else
## check and fix if service OR volume files are not present in context
	@$(call _mk_err, "SRV: $(SRV) - files are not entirety in CTX: $(CTX)")
ifeq (0,$(_CTX_SRV))
	@$(call _mk_err, "Service file disabled");
	@$(eval _SRC_SERVICE_FILE_PATH=$(_SRV_SRC_FILE_PATH))
	@$(eval _TARGET_SERVICE_FILE_PATH=$(_CTX_SRV_TARGET_FILE_PATH))
endif
ifeq (0,$(_CTX_VOL))
	@$(call _mk_err, "Volume file disabled");
	@$(eval _SRC_SERVICE_FILE_PATH=$(_VOL_SRC_FILE_PATH))
	@$(eval _TARGET_SERVICE_FILE_PATH=$(_CTX_VOL_TARGET_FILE_PATH))
endif
	@$(call _mk_warn, "Would you want add default one? [y/N] ");
	@read answer \
	&& if [ $${answer:-'N'} = 'y' ]; then \
		$(CP) $(_SRC_SERVICE_FILE_PATH) $(_TARGET_SERVICE_FILE_PATH); \
		if [ -f $(_TARGET_SERVICE_FILE_PATH) ]; then \
			$(call _mk_ok, "Successfully added: $(SRV)"); \
		else \
			$(call _mk_err, "Unsuccessful added: $(CTX)"); \
		fi; \
	else \
		$(call _mk_inf, "Canceled..."); \
	fi;
endif
	@printf "\n"


## Add service to context - check if context exists and service file exists
context_add_service: context_check_is_exists
#? service_exit_is_not_exists
	@if [ "0" -eq "$(_MK_IS_SERVICE_EXIST)" ]; then \
		$(call _mk_err, "SRV: '$(SRV)' service not found..."); \
		printf "\n"; \
		exit 1; \
	fi;

ifeq ($(filter 0,$(_CTX_SRV) $(_CTX_VOL)), )
	@$(call _mk_warn, "SRV: '$(SRV)' already in CTX: '$(CTX)'")
	@$(call _mk_help,  $(shell echo -n "\
	'Try including it in the template using target \`enableCtxSrv\` \
	or use \`removeCtxSrv\` for remove it from context before adding \
	new service with the same name from \
	default templates' | fmt -w 68"))
	@printf "\n"
	@exit 1;
#?	$(call error, "CONTEX: not found...")
endif

## copy default service and volume files to context directory
	@$(CP) $(_VOL_SRC_FILE_PATH) $(_CTX_VOL_TARGET_FILE_PATH);
	@$(CP) $(_SRV_SRC_FILE_PATH) $(_CTX_SRV_TARGET_FILE_PATH);
	@$(CP) $(_ENV_SRC_FILE_PATH) $(_CTX_ENV_TARGET_FILE_PATH);

## check trustworthiness of copied files
	@if [ -f $(_CTX_SRV_TARGET_FILE_PATH) ] \
	&& [ -f $(_CTX_VOL_TARGET_FILE_PATH) ]; then \
		$(call _mk_ok, "Successfully added: '$(CTX)' < '$(SRV)'"); \
	else \
		$(call _mk_err, "Unsuccessful added: '$(SRV)' - use 'resqueSrv' target for fix it..."); \
	fi;
	@printf "\n";
	@$(call _mk_inf, "Add service files to context template...")
	@printf "\n";
ifeq (,$(widcard$(_CTX_SRV_TARGET_FILE_PATH)))
	@$(call add_service_to_ctx_tmpl)
endif
ifeq (,$(widcard$(_CTX_VOL_TARGET_FILE_PATH)))
	@$(call add_volume_to_ctx_tmpl)
endif

### Printing test results
	@_SRV_EXIST="`sed -n \"/$(_NEW_INCLUDE_SRV)/p\" $(_MK_PATH_TARGET_SERVICE_TMPL)`"; \
	if [ "" != "$${_SRV_EXIST}" ]; then \
		_MK_IS_CTX_SRV_ENABLED=1; \
		$(call _mk_ok, "Service: '$(SERVICE)' added to CTX: '$(CTX)'" ); \
	else \
		$(call _mk_err, "FAILED: service: '$(SERVICE)' not added to CTX: '$(CTX)'" ); \
	fi;

	@_VOL_EXIST="`sed -n \"/$(_NEW_INCLUDE_VOL)/p\" $(_MK_PATH_TARGET_VOLUME_TMPL)`"; \
	if [ "" != "$${_VOL_EXIST}" ]; then \
		_MK_IS_CTX_VOL_ENABLED=1; \
		$(call _mk_ok, "Volume:  '$(SERVICE)' added to CTX: '$(CTX)'" ); \
	else \
		$(call _mk_err, "FAILED: volume: '$(SERVICE)' not added to CTX: '$(CTX)'" ); \
	fi;

	@printf "\n";


## Enable service to context (update 'dc.service.tmpl') - check if context exists and service file exists
context_enable_service: context_check_is_exists
#? service_exit_is_not_exists
	@if [ "0" -eq "$(_MK_IS_SERVICE_EXIST)" ]; then \
		$(call _mk_err, "SRV: '$(SRV)' service not found..."); \
		printf "\n"; \
		exit 1; \
	fi;

# ifeq ($(filter 0,$(_CTX_SRV) $(_CTX_VOL)), )
# 	@$(call _mk_warn, "SRV: '$(SRV)' already in CTX: '$(CTX)'")
# 	@printf "\n"
# 	@exit 1;
# #?	$(call error, "CONTEX: not found...")
# endif

## check trustworthiness of copied files
	@if [ -f $(_CTX_SRV_TARGET_FILE_PATH) ] \
	&& [ -f $(_CTX_VOL_TARGET_FILE_PATH) ]; then \
		$(call _mk_ok, "Successfully added: '$(CTX)' < '$(SRV)'"); \
	else \
		$(call _mk_err, "Unsuccessful added: '$(SRV)' - use 'resqueSrv' target for fix it..."); \
	fi;
	@printf "\n";
ifeq (,$(widcard$(_CTX_SRV_TARGET_FILE_PATH)))
#	@$(call _mk_warn, "_CTX_SRV_TARGET_FILE_PATH: $(_CTX_SRV_TARGET_FILE_PATH)")
	@$(call add_service_to_ctx_tmpl)
endif
ifeq (,$(widcard$(_CTX_VOL_TARGET_FILE_PATH)))
#	@$(call _mk_warn, "_CTX_VOL_TARGET_FILE_PATH: $(_CTX_VOL_TARGET_FILE_PATH)")
	@$(call add_volume_to_ctx_tmpl)
endif


## Disable service from context (update 'dc.service.tmpl') - check if context exists and 
context_disable_service: context_check_is_exists
### process `dc.services.tmpl`
### check included service-file from template `dc.services.tmpl`
	@$(call is_service_in_ctx_tmpl, _MK_IS_CTX_SRV_ENABLED)
### process `dc.volumes.tmpl`
	@$(call is_volume_in_ctx_tmpl, _MK_IS_CTX_VOL_ENABLED)
 
	@if [ "0" -eq "$(_MK_IS_CTX_SRV_ENABLED)" ]; then \
		$(call _mk_warn, "Unknow service: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
		printf "\n"; \
		if [ "0" -eq "$(_MK_IS_CTX_VOL_ENABLED)" ]; then \
			$(shell echo -n "exit 1;") \
		fi; \
	fi;
### remove included service-file from template `dc.services.tmpl`
	$(call remove_service_from_ctx_tmpl)
### checks if included service-file successfully removed from template `dc.services.tmpl`
	@$(call is_service_in_ctx_tmpl, _MK_IS_CTX_SRV_EXIST)
	@if [ "1" -eq "$(_MK_IS_CTX_SRV_EXIST)" ]; then \
		$(call _mk_err, "FAILED: service: '$(SERVICE)' still enabled at CTX: '$(CTX)'" ); \
	else \
		$(call _mk_run, "Service config: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
	fi;
#	@printf "\n"

	@if [ "0" -eq "$(_MK_IS_CTX_VOL_ENABLED)" ]; then \
		$(call _mk_warn, "Unknow service volume: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
		printf "\n"; \
		$(shell echo -n "exit 1;") \
	fi;
### remove included service-file from template `dc.volumes.tmpl`
	$(call remove_volume_from_ctx_tmpl)
### checks if included volume-file successfully removed from template `dc.volumes.tmpl`
	@$(call is_volume_in_ctx_tmpl, _MK_IS_CTX_VOL_EXIST)
	@if [ "1" -eq "$(_MK_IS_CTX_VOL_EXIST)" ]; then \
		$(call _mk_err, "FAILED: service volume: '$(SERVICE)' still enabled at CTX: '$(CTX)'" ); \
	else \
		$(call _mk_run, "Service volume: '$(SERVICE)' disabled at CTX: '$(CTX)'" ); \
	fi;
	@printf "\n"


## Remove service from context - check if context exists and service file exists
context_remove_service: context_check_is_exists
#? service_exit_is_not_exists
	@$(call _mk_ok, "SRV: '$(SRV)'")
	@$(eval _MK_REMOVE_SERVICE_ALLOWED = 0)
### User dialog confirmation
	@$(call _mk_inf, $(_CTX_SRV_TARGET_FILE_PATH))
	@$(call _mk_inf, $(_CTX_VOL_TARGET_FILE_PATH))
	@$(call _mk_inf, $(_CTX_ENV_TARGET_FILE_PATH))
	@printf "\n"
	@$(call _mk_warn, "Service files will be removed are you sure? [y/N] ")
	@read answer && \
	if [ $${answer:-'N'} = 'y' ]; then \
		REMOVE_SERVICE_ALLOWED=1; \
	else \
		REMOVE_SERVICE_ALLOWED=0; \
		$(call _mk_inf, "Canceled..."); \
	fi; \
	if [ "0" -eq "$(_MK_IS_CTX_SERVICE_EXIST)" ]; then \
		$(call _mk_warn, "SRV: '$(SRV)' not found in CTX: '$(CTX)'"); \
		if [ "1" -eq "$(_MK_CTX_SERVICE_DISABLE_ENV)" ]; then \
			$(call _mk_err, "Incomplete: SRV: $(SRV) in CTX: $(CTX) not found environment file"); \
		fi; \
		if [ "1" -eq "$(_MK_CTX_SERVICE_DISABLE_VOL)" ]; then \
			$(call _mk_err, "Incomplete: SRV: $(SRV) in CTX: $(CTX) not found volume file"); \
		fi; \
		if [ "1" -eq "$(_MK_CTX_SERVICE_DISABLE_SRV)" ]; then \
			$(call _mk_err, "Incomplete: SRV: $(SRV) in CTX: $(CTX) not found service file"); \
		fi; \
		printf "\n"; \
		exit 1; \
	else \
		if [ "1" -eq "$${REMOVE_SERVICE_ALLOWED}" ]; then \
			$(call _mk_inf, "SRV: '$(SRV)' found in CTX: '$(CTX)'"); \
			rm -f $(_CTX_SRV_TARGET_FILE_PATH); \
			rm -f $(_CTX_VOL_TARGET_FILE_PATH); \
			rm -f $(_CTX_ENV_TARGET_FILE_PATH); \
			if [ ! -f $(_CTX_SRV_TARGET_FILE_PATH) ]  \
			&& [ ! -f $(_CTX_VOL_TARGET_FILE_PATH) ]  \
			&& [ ! -f $(_CTX_ENV_TARGET_FILE_PATH) ]; \
			then \
				$(call _mk_ok, "Successfully removed: $(SRV)"); \
			else \
				$(call _mk_err, "Unsuccessful operation: $(SRV) - use 'resqueSrv' target for fix it..."); \
			fi; \
		fi; \
	fi; \
	printf "\n"; \
	if [ -f "$(_MK_PATH_TARGET_SERVICE_TMPL)" ]; then \
		[ "1" -eq "$${REMOVE_SERVICE_ALLOWED}" ] \
		&& sed -i "/$(_NEW_INCLUDE_SRV)/d" $(_MK_PATH_TARGET_SERVICE_TMPL); \
	else \
		$(call _mk_err, "UNKNOWN SRV:    '$(SRV)'"); \
		$(call _mk_err, "NOT FOUND FILE: $(_MK_PATH_TARGET_SERVICE_TMPL)"); \
	fi; \
	if [ -f "$(_MK_PATH_TARGET_VOLUME_TMPL)" ]; then \
		[ "1" -eq "$${REMOVE_SERVICE_ALLOWED}" ] \
		&& sed -i "/$(_NEW_INCLUDE_VOL)/d" $(_MK_PATH_TARGET_VOLUME_TMPL); \
	else \
		$(call _mk_err, "UNKNOWN SRV:    '$(SRV)'"); \
		$(call _mk_err, "NOT FOUND FILE: $(_MK_PATH_TARGET_SERVICE_TMPL)"); \
	fi;
	@printf "\n"


## Build final files - create result .yml & .env
context_build: context_check_is_exists
	@$(eval _MK_FILE_PATH_TARGET_CTX_TMPL_MAIN = $(addprefix $(_MK_DIR_PATH_TARGET_CTX_TMPL), $(_MK_DC_TMPL_MAIN)))
	@$(eval _TARGET_CTX_DOCKER_COMPOSE_FILE_PATH = $(addprefix $(_MK_CTX_PATH)/, $(_MK_FN_DC_DEFAULT_YML)))
	@$(eval _TARGET_CTX_ENVIRONMENT_FILE_PATH = $(addprefix $(_MK_CTX_PATH)/, $(_MK_FN_DC_DEFAULT_ENV)))
	@$(eval _MK_PATH_TARGET_SERVICE_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_SERVICES)))

##  Process main template (dc.tmpl) to build 'docker-compose.yml' & '.env' files
	@$(shell echo -n "$(JINJA) $(_MK_FILE_PATH_TARGET_CTX_TMPL_MAIN) > $(_TARGET_CTX_DOCKER_COMPOSE_FILE_PATH)")
	@printf "\n"

	@$(eval _TMPL_INCLUDE_PATTERN = {%\ include\ .*\.yml\/\([^\/]*\)\.service\.yml.*\ %})
#	$(shell echo -n "@echo \"_TMPL_INCLUDE_PATTERN:|$(_TMPL_INCLUDE_PATTERN)|\" ")

	$(eval _MK_FN_DC_DEFAULT_INCLUDED_YML = $(shell cat $(_MK_PATH_TARGET_SERVICE_TMPL) \
			| grep include \
			| sed "/$(_TMPL_INCLUDE_PATTERN)/s//\1.env/"))
##  Create empty .env file
	@$(shell echo -n "$(TRUNCATE) -s 0 $(_TARGET_CTX_ENVIRONMENT_FILE_PATH)")

##  Include $(SRV).env files, which are included in main template - and build final '.env' file
	@$(foreach envFile, $(_MK_FN_DC_DEFAULT_INCLUDED_YML), \
		$(shell echo -n "cat $(_MK_DIR_PATH_TARGET_CTX_ENV)$(envFile) >> $(_TARGET_CTX_ENVIRONMENT_FILE_PATH); \
		 		printf \"\\\n\" >> $(_TARGET_CTX_ENVIRONMENT_FILE_PATH); " ) )

##  Check if all files exist at CTX directory - docker-compose.yml & .env
	@$(shell echo -n "if [ -f \"$(_TARGET_CTX_DOCKER_COMPOSE_FILE_PATH)\" ]; then \
		printf \"$(_MK_COLOR_TERM_GREEN)OK: $(_MK_COLOR_TERM_WHITE)Builds was successful  CTX: '%s' - '%s' created.$(_MK_COLOR_TERM_RESET)\" $(CTX) $(_MK_FN_DC_DEFAULT_YML); \
	else \
		printf \"$(_MK_COLOR_TERM_RED)ERROR: $(_MK_COLOR_TERM_WHITE)Unsuccessful build: '%s' - use 'resqueSrv' target for fix it...$(_MK_COLOR_TERM_RESET)\" $(CTX); \
	fi; ")
	@printf "\n"
	@$(shell echo -n "if [ -f \"$(_TARGET_CTX_ENVIRONMENT_FILE_PATH)\" ]; then \
		printf \"$(_MK_COLOR_TERM_GREEN)OK: $(_MK_COLOR_TERM_WHITE)Builds was successful  CTX: '%s' - '%s' created.$(_MK_COLOR_TERM_RESET)\" $(CTX) $(_MK_FN_DC_DEFAULT_ENV); \
	else \
		printf \"$(_MK_COLOR_TERM_RED)ERROR: $(_MK_COLOR_TERM_WHITE)Unsuccessful build: CTX: '%s' - '%s' file filed...$(_MK_COLOR_TERM_RESET)\" $(CTX) $(_MK_FN_DC_DEFAULT_ENV) ; \
	fi; ")
	@printf "\n"


context_print_vars:
ifeq (printvar,$(LOG_MODE))
	@printf "\n"
	@printf "\n_MKFILE_CONTEXT_ROOT_DIR_PATH: |%s|" $(_MKFILE_CONTEXT_ROOT_DIR_PATH)
	@printf "\n_MKFILE_CONTEXT_DIR_MKFILE: |%s|" $(_MKFILE_CONTEXT_DIR_MKFILE)
#	@printf "\n_MKFILE_CONTEXT_REL_PATH: |%s|" $(_MKFILE_CONTEXT_REL_PATH)
	@printf "\n_MK_DIR_PATH_MKFILE: |%s|" $(_MK_DIR_PATH_MKFILE)
# @printf "\n _SRV:$(SRV)"
# @printf "\n _SRV_SRC_FILE_NAME:$(_SRV_SRC_FILE_NAME)"
# @printf "\n _VOL_SRC_FILE_NAME:$(_VOL_SRC_FILE_NAME)"
# @printf "\n _SRV_TARGET_FILE_NAME:$(_SRV_TARGET_FILE_NAME)"
# @printf "\n _VOL_TARGET_FILE_NAME:$(_VOL_TARGET_FILE_NAME)"
# @printf "\n _SRV_SRC_FILE_PATH: $(_SRV_SRC_FILE_PATH)"
# @printf "\n _VOL_SRC_FILE_PATH: $(_VOL_SRC_FILE_PATH)"
	@printf "\n"
	@printf "\n_MK_IS_CONTEX_EXIST: |%s|" $(_MK_IS_CONTEX_EXIST)
	@printf "\n_MK_IS_SERVICE_EXIST: |%s|" $(_MK_IS_SERVICE_EXIST)
	@printf "\n_MK_NO_CTX_CHECK_EARLY_EXIT: |%s|" $(_MK_NO_CTX_CHECK_EARLY_EXIT)
	@printf "\n_MK_DEF_ENV_DIR: |%s|" $(_MK_DEF_ENV_DIR)
	@printf "\n_MK_CTX_PATH: |%s|" $(_MK_CTX_PATH)
	@printf "\n_MK_DIR_TARGET_CTX_YML: |%s|" $(_MK_DIR_TARGET_CTX_YML)
	@printf "\n_CTX_TARGET_YML_PATH: |%s|" $(_CTX_TARGET_YML_PATH)
#	@printf "\n_MK_CTX_PATH: %s..." $(_MK_CTX_PATH)
	@printf "\n_MK_DIR_TARGET_CTX_YML: |%s|" $(_MK_DIR_TARGET_CTX_YML)
	@printf "\n_CTX_TARGET_YML_PATH: |%s|" $(_CTX_TARGET_YML_PATH)
	@printf "\n_CTX_SRV_TARGET_FILE_PATH: |%s|" $(_CTX_SRV_TARGET_FILE_PATH)
	@printf "\n_CTX_VOL_TARGET_FILE_PATH: |%s|" $(_CTX_VOL_TARGET_FILE_PATH)
	@printf "\n_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE: |%s|" $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_TEMPLATE)
	@printf "\n_MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES: |%s|" $(_MK_DIR_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES)
	@printf "\n_CTX_SRV_TARGET_FILE_PATH: |%s|" $(_CTX_SRV_TARGET_FILE_PATH)
	@printf "\n_MK_DIR_PATH_TARGET_CTX_TMPL: |%s|" $(_MK_DIR_PATH_TARGET_CTX_TMPL)
	@printf "\n_MK_DIR_PATH_TARGET_CTX_YML: |%s|" $(_MK_DIR_PATH_TARGET_CTX_YML)
	@printf "\n_MK_DIR_PATH_TARGET_CTX_ENV: |%s|" $(_MK_DIR_PATH_TARGET_CTX_ENV)
	@printf "\n"
	@printf "\n_MK_PATH_TARGET_SERVICE_TMPL: |%s|" $(_MK_PATH_TARGET_SERVICE_TMPL)
	@printf "\n_MK_DIR_TARGET_CTX_YML_MASKED: |%s|" $(_MK_DIR_TARGET_CTX_YML_MASKED)
	@printf "\n_MK_SERVICE_MASKED_RELATIVE_FILE_PATH: |%s|" $(_MK_SERVICE_MASKED_RELATIVE_FILE_PATH)
	@printf "\n_NEW_INCLUDE_SRV: |%s|" $(_NEW_INCLUDE_SRV)		
endif
	@printf "\n"

## Print variables - directory, context, and relative path
.PHONY: context-test
context.test:
	@$(call _mk_inf,  "$@")
	@printf "\n"

