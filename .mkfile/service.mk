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

### Aliase, set service name
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

### Checks if the service-file of some service included in the context template - added into `dc.services.tmpl`
define is_service_in_ctx_tmpl
$(eval _MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_SRV_REGEX)/p\" $(_MK_PATH_TARGET_SERVICE_TMPL)`" ) )
$(eval _MK_IS_CTX_SRV_EXIST= $(shell echo -n "`[ \"\" = \"$(_MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE)\" ] &&  echo -n \"0\" || echo -n \"1\";`"))

$(eval $(1) = $(_MK_IS_CTX_SRV_EXIST))
endef

### Checks if the volume-file of some service included in the context template - added into `dc.volumes.tmpl`
define is_volume_in_ctx_tmpl
$(eval _MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_VOL_REGEX)/p\" $(_MK_PATH_TARGET_VOLUME_TMPL)`" ) )
$(eval _MK_IS_CTX_VOL_EXIST= $(shell echo -n "`[ \"\" = \"$(_MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME)\" ] &&  echo -n \"0\" || echo -n \"1\";`"))

$(eval $(1) = $(_MK_IS_CTX_VOL_EXIST))
endef



### Updates the context template by adding a reference to the `service` file
define add_service_to_ctx_tmpl
$(eval _MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_SRV_REGEX)/p\" $(_MK_PATH_TARGET_SERVICE_TMPL)`" ) )

$(shell echo -n "if [ ! -f \"$(_CTX_SRV_TARGET_FILE_PATH)\" ]; then \
  printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_CTX_SRV_TARGET_FILE_PATH)\\\n\"; \
  else \
    if [ \"\" = \"$(_MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE)\" ]; then \
      sed -i \"/{{SERVICES}}/s//$(_NEW_INCLUDE_SRV)\\\n{{SERVICES}}/\" $(_MK_PATH_TARGET_SERVICE_TMPL); \
    else \
      printf \"Already  exist: SRV:  |%s| \\\n\" $(SRV); \
    fi; \
  fi; ";
)

endef

### Updates the context template by adding a reference to the `volume` file
define add_volume_to_ctx_tmpl
$(eval _MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_VOL_REGEX)/p\" $(_MK_PATH_TARGET_VOLUME_TMPL)`" ) )

$(shell echo -n "if [ ! -f \"$(_CTX_VOL_TARGET_FILE_PATH)\" ]; then \
  printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_CTX_VOL_TARGET_FILE_PATH)\\\n\"; \
  else \
    if [ \"\" = \"$(_MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME)\" ]; then \
      sed -i \"/{{VOLUMES}}/s//$(_NEW_INCLUDE_VOL)\\\n{{VOLUMES}}/\" $(_MK_PATH_TARGET_VOLUME_TMPL); \
    else \
      printf \"Already  exist: VOL:  |%s| \\\n\" $(SRV); \
    fi; \
  fi; ";
)

endef

### Removes the reference to the `service` file from the context template
define remove_service_from_ctx_tmpl
$(shell [ -f $(_MK_PATH_TARGET_SERVICE_TMPL) ] \
  && sed -i "/$(_NEW_INCLUDE_SRV_REGEX)/d" $(_MK_PATH_TARGET_SERVICE_TMPL) \
  || echo -n "printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_MK_PATH_TARGET_SERVICE_TMPL)\\\n\"; \
  exit 1; ")
endef

### Removes the reference to the `volume` file from the context template
define remove_volume_from_ctx_tmpl
$(shell [ -f $(_MK_PATH_TARGET_VOLUME_TMPL) ] \
  && sed -i "/$(_NEW_INCLUDE_VOL_REGEX)/d" $(_MK_PATH_TARGET_VOLUME_TMPL) \
  || echo -n "printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_MK_PATH_TARGET_VOLUME_TMPL)\\\n\"; \
  exit 1; ")
endef

### Prints the available services at default template directory
service_list:
	@$(call _mk_inf, "Search at: $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES)");
	@printf "\n\n"
	@$(shell echo -n "ls -1 $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES) | sed  '/$(_SRV_AFFIX)/s///' | sort | pr -4 -t ; ")
	@printf "\n"

service_version_list:
ifeq (1,$(_MK_IS_CONTEX_EXIST))
ifneq (,$(SRV))
	@$(eval _SRV_NAMES=$(shell echo -n "`find $(_MK_DIR_PATH_TARGET_CTX_YML) -type f -name '*$(SRV)*' -printf '%f\n' | grep '.service' | grep $(SRV) | sed  '/\.service$(_SRV_AFFIX)/s///' | sort ; `"))
else
	@$(eval _SRV_NAMES=$(shell echo -n "`ls -1 $(_MK_DIR_PATH_TARGET_CTX_YML) | grep ".service" | sed  '/\.service$(_SRV_AFFIX)/s///' | sort ; `"))
endif
	@$(eval _SRV_NAME_AFFIX=$(addprefix .service,$(_SRV_AFFIX)))
	@$(eval _ENV_NAME_AFFIX=$(_ENV_AFFIX))
	@$(eval _DIR_PATH_SERVICES_YML=$(_MK_DIR_PATH_TARGET_CTX_YML:/=))
	@$(eval _DIR_PATH_SERVICES_ENV=$(_MK_DIR_PATH_TARGET_CTX_ENV:/=))
else
ifneq (,$(SRV))
	@$(eval _SRV_NAMES=$(shell echo -n "`find $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES) -type f -name '*$(SRV)*' -printf '%f\n' | sed  '/$(_SRV_AFFIX)/s///'`"))
else
	@$(eval _SRV_NAMES=$(shell echo -n "`ls -1 $(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES) | sed  '/$(_SRV_AFFIX)/s///' | sort ; `"))
endif
	@$(eval _SRV_NAME_AFFIX=$(_SRV_AFFIX))
	@$(eval _ENV_NAME_AFFIX=$(_ENV_AFFIX))
	@$(eval _DIR_PATH_SERVICES_YML=$(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_YML_SERVICES))
	@$(eval _DIR_PATH_SERVICES_ENV=$(_MK_DIR_PATH_TEMPLATE_DOCKER_COMPOSE_ENV))
endif
	@for sN in $(_SRV_NAMES); do \
		sN_upper=`echo $${sN} | tr '[:lower:]' '[:upper:]'`; \
		sN_yml_path="$(_DIR_PATH_SERVICES_YML)/$${sN}$(_SRV_NAME_AFFIX)"; \
		sN_env_path="$(_DIR_PATH_SERVICES_ENV)/$${sN}$(_ENV_NAME_AFFIX)"; \
		sN_regex_yml_version='s/[^0-9]*([0-9\.]+([0-9\.]+)?).*/\1/'; \
		sN_version_num=""; \
		sN_env_version=""; \
		sN_yml_docker_configuration=""; \
		\
		sN_yml_version=`$(CAT) "$${sN_yml_path}" | grep "_VERSION" \
		| sed "/^\ */d" \
		| sed "/^#*/d" \
		| sed  -E "$${sN_regex_yml_version}";` ; \
		\
		sN_yml_env_variable_name_version=`$(CAT) "$${sN_yml_path}" \
		| grep "_VERSION" \
		| grep "$${sN_upper}" \
		| sed -E  's/.+\{([^\ \-\=\:}]+_VERSION).*/\1/' | uniq ;` ; \
		\
		sN_yml_image_version=`$(CAT) "$${sN_yml_path}" | grep "image" | grep -v "#" \
		| sed -E "s/[^#]*image[\ \t]*:[\ \t]*([^\ \t]+)/\1/";` ; \
		\
		sN_yml_image_docker_version=`$(CAT) "$${sN_yml_path}" \
		| sed -n "/^[^#]*\(context\|dockerfile\|build\)/p" ;` ; \
		\
		if [ ! -z "$${sN_yml_env_variable_name_version}" ]; then \
			sN_env_version=`$(CAT) "$${sN_env_path}" | grep "$${sN_yml_env_variable_name_version}=" \
			| sed  -nE "s/^[^0-9#]*([0-9\.]+([0-9\.]+)?).*/\1/p";` ; \
		fi; \
		\
		sN_yml_image_count=`echo "$${sN_yml_image_version}" | wc -l`; \
		sN_yml_docker_configuration=`echo "$${sN_yml_image_docker_version}" \
		| while read line; do \
			[ ! -z "$${line}" ] && echo -n "> $${line} "; \
		done;` ; \
		\
		printf "\n$${sN_upper}:"; \
		sN_yml_version_num=$${sN_yml_version}; \
		if [ -z "$${sN_yml_version_num}" ]; then \
			sN_yml_version_num="None"; \
		fi; \
		if [ ! -z "$${sN_yml_image_version}" ] && [ -z "$${sN_yml_version}" ] && [ -z "$${sN_yml_image_docker_version}" ]; then \
			[ ! -z "$${sN_yml_image_version}" ] && printf "\nDocker: image |$${sN_yml_image_version}|"; \
			[ ! -z "$${sN_yml_docker_configuration}" ] && printf "\nDocker: build |$${sN_yml_docker_configuration}|"; \
		fi; \
		if [ ! -z "$${sN_yml_image_docker_version}" ]; then \
			[ ! -z "${sN_yml_image_version}" ] && printf "\nDocker: image |$${sN_yml_image_version}|"; \
			[ ! -z "$${sN_yml_docker_configuration}" ] && printf "\nDocker: build |$${sN_yml_docker_configuration}|"; \
		fi; \
		\
		[ ! -z "$${sN_yml_env_variable_name_version}" ] && printf "\nENV variable: |$${sN_yml_env_variable_name_version}|"; \
		[ ! -z "$${sN_env_version}" ] && printf "\nENV version:  |$${sN_env_version}|"; \
		[ ! -z "$${sN_yml_version}" ] && printf "\nYML version:  |$${sN_yml_version}|"; \
		if [ "$${sN_yml_image_count}" -gt 1 ]; then \
			$(call _mk_warn, "Too many images |$${sN_yml_image_count}| declared in the one service"); \
			$(call _mk_warn, "check the file: |$${sN_yml_path}|"); \
			printf "\n"; \
		fi; \
	printf "\n"; \
	done;
	@printf "\n";

