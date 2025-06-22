VERBOSE_TARGET_PRINT := 0
__is_io_console := 1

ifeq (,$(shell which tput))
    _MK_COLOR_TERM_RED     := ""
    _MK_COLOR_TERM_GREEN   := ""
    _MK_COLOR_TERM_YELLOW  := ""
    _MK_COLOR_TERM_LPURPLE := ""
    _MK_COLOR_TERM_PURPLE  := ""
    _MK_COLOR_TERM_BLUE    := ""
    _MK_COLOR_TERM_WHITE   := ""
    _MK_COLOR_TERM_RESET   := ""
else ifneq (,$(findstring xterm,${TERM}))
    _MK_COLOR_TERM_RED     := $(shell tput -Txterm setaf 1)
    _MK_COLOR_TERM_GREEN   := $(shell tput -Txterm setaf 2)
    _MK_COLOR_TERM_YELLOW  := $(shell tput -Txterm setaf 3)
    _MK_COLOR_TERM_LPURPLE := $(shell tput -Txterm setaf 4)
    _MK_COLOR_TERM_PURPLE  := $(shell tput -Txterm setaf 5)
    _MK_COLOR_TERM_BLUE    := $(shell tput -Txterm setaf 6)
    _MK_COLOR_TERM_WHITE   := $(shell tput -Txterm setaf 7)
    _MK_COLOR_TERM_RESET   := $(shell tput -Txterm sgr0)
else
    _MK_COLOR_TERM_RED     := ""
    _MK_COLOR_TERM_GREEN   := ""
    _MK_COLOR_TERM_YELLOW  := ""
    _MK_COLOR_TERM_LPURPLE := ""
    _MK_COLOR_TERM_PURPLE  := ""
    _MK_COLOR_TERM_BLUE    := ""
    _MK_COLOR_TERM_WHITE   := ""
    _MK_COLOR_TERM_RESET   := ""
endif


define _mk_ok
printf "\n$(_MK_COLOR_TERM_GREEN)OK:      $(_MK_COLOR_TERM_WHITE)%s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_done
printf "\n$(_MK_COLOR_TERM_GREEN)DONE:    $(_MK_COLOR_TERM_WHITE)%s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_run
printf "\n$(_MK_COLOR_TERM_GREEN)RUN:     $(_MK_COLOR_TERM_WHITE)%s$(_MK_COLOR_TERM_RESET)" $(1)
endef


define _mk_err
printf "\n$(_MK_COLOR_TERM_RED)ERROR:   $(_MK_COLOR_TERM_WHITE)%s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_inf
printf "\n$(_MK_COLOR_TERM_BLUE)INFO:    %s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_warn
printf "\n$(_MK_COLOR_TERM_YELLOW)WARNING: %s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_wh
printf "\n$(_MK_COLOR_TERM_WHITE)WARNING: %s$(_MK_COLOR_TERM_RESET)" $(1)
endef

define _mk_verbose
printf "\n$(_MK_COLOR_TERM_PURPLE)         %s$(_MK_COLOR_TERM_RESET)" $(1)
endef


define _mk_getnotempty
var1=$(shell echo "$(1)" | tr -d " ") && \
var2=$(shell echo "$(2)" | tr -d " ") && \
[ ! -z "$${var1}" ] && \
printf "%s" $${var1} || \
printf "%s" $${var2}
endef

# .PHONY: io.console.test
io.console.test:
	@$(call _mk_inf,  "$@")
	@printf "\n"


define add_service_to_ctx_tmpl 
$(eval _MK_PATH_TARGET_SERVICE_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_SERVICES)))
$(eval _MK_SERVICE_RELATIVE_FILE_PATH = ../$(_MK_DIR_TARGET_CTX_YML)$(_MK_DIR_TARGET_CTX_YML_MASKED)$(SRV).service$(_SRV_AFFIX))
$(eval _MK_SERVICE_MASKED_RELATIVE_FILE_PATH = $(subst /,\/, $(_MK_SERVICE_RELATIVE_FILE_PATH)))

$(eval _NEW_INCLUDE_SRV = {% include '$(_MK_SERVICE_MASKED_RELATIVE_FILE_PATH)' %})

$(shell [ "0" -eq "$(_MK_IS_CONTEX_EXIST)" ] \
  && echo -n "printf \"\\\nUNKNOWN CTX: '$(CTX)' \\\n \"; exit 1; ")

$(eval _MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_SRV)/p\" $(_MK_PATH_TARGET_SERVICE_TMPL)`" ) )

$(shell echo -n "if [ ! -f \"$(_CTX_SRV_TARGET_FILE_PATH)\" ]; then \
  printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_CTX_SRV_TARGET_FILE_PATH)\\\n\"; \
  else \
    if [ \"\" = \"$(_MK_IS_PATH_TARGET_SERVICE_TMPL_ALREADY_WITH_SERVICE)\" ]; then \
      sed -i \"/{{SERVICES}}/s//$(_NEW_INCLUDE_SRV)\\\n{{SERVICES}}/\" $(_MK_PATH_TARGET_SERVICE_TMPL); \
    else \
      printf \"Already exist: SRV: |%s| \\\n\" $(SRV); \
    fi; \
  fi; "; 
)

endef


define add_volume_to_ctx_tmpl 
$(eval _MK_PATH_TARGET_VOLUME_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_VOLUMES)))
$(eval _MK_VOLUME_RELATIVE_FILE_PATH = ../$(_MK_DIR_TARGET_CTX_YML)$(SRV).volume$(_VOL_AFFIX))
$(eval _MK_VOLUME_MASKED_RELATIVE_FILE_PATH = $(subst /,\\/, $(_MK_VOLUME_RELATIVE_FILE_PATH)))

$(eval _NEW_INCLUDE_VOL = {% include '$(_MK_VOLUME_MASKED_RELATIVE_FILE_PATH)' %})

$(shell [ "0" -eq "$(_MK_IS_CONTEX_EXIST)" ] \
  && echo -n "printf \"\\\nUNKNOWN CTX: '$(CTX)' \\\n \"; exit 1; ")

$(eval _MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME = $(shell echo -n "`sed -n \"/$(_NEW_INCLUDE_VOL)/p\" $(_MK_PATH_TARGET_VOLUME_TMPL)`" ) )

$(shell echo -n "if [ ! -f \"$(_CTX_VOL_TARGET_FILE_PATH)\" ]; then \
  printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_CTX_VOL_TARGET_FILE_PATH)\\\n\"; \
  else \
    if [ \"\" = \"$(_MK_IS_PATH_TARGET_VOLUME_TMPL_ALREADY_WITH_VOLUME)\" ]; then \
      sed -i \"/{{VOLUMES}}/s//$(_NEW_INCLUDE_VOL)\\\n{{VOLUMES}}/\" $(_MK_PATH_TARGET_VOLUME_TMPL); \
    else \
      printf \"Already exist: VOL: |%s| \\\n\" $(SRV); \
    fi; \
  fi; "; 
)

endef


define remove_service_from_ctx_tmpl 
$(eval _MK_PATH_TARGET_SERVICE_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_SERVICES)))
$(eval _MK_DIR_TARGET_CTX_YML_MASKED = $(subst .,\., $(subst /,\/, $(_MK_DIR_TARGET_CTX_YML))))
$(eval _MK_SERVICE_MASKED_RELATIVE_FILE_PATH = ..\\/$(_MK_DIR_TARGET_CTX_YML_MASKED)$(SRV).service$(_SRV_AFFIX))
$(eval _NEW_INCLUDE_SRV = {% include '$(_MK_SERVICE_MASKED_RELATIVE_FILE_PATH)' %})

$(shell [ "0" -eq "$(_MK_IS_CONTEX_EXIST)" ] \
  && echo -n "printf \"\\\nUNKNOWN CTX: '$(CTX)' \\\n \"; exit 1; ")

$(shell [ -f $(_MK_PATH_TARGET_SERVICE_TMPL) ] \
  && sed -i "/$(_NEW_INCLUDE_SRV)/d" $(_MK_PATH_TARGET_SERVICE_TMPL) \
  || echo -n "printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_MK_PATH_TARGET_SERVICE_TMPL)\\\n\"; \
  exit 1; ")
endef


define remove_volume_from_ctx_tmpl 
$(eval _MK_PATH_TARGET_VOLUME_TMPL=$(addprefix $(addprefix $(_MK_CTX_PATH)/, $(_MK_DIR_TARGET_CTX_TMPL)), $(_MK_DC_TMPL_VOLUMES)))
$(eval _MK_DIR_TARGET_CTX_YML_MASKED = $(subst .,\., $(subst /,\/, $(_MK_DIR_TARGET_CTX_YML))))
$(eval _MK_VOLUME_MASKED_RELATIVE_FILE_PATH = ..\\/$(_MK_DIR_TARGET_CTX_YML_MASKED)$(SRV).volume$(_VOL_AFFIX))
$(eval _NEW_INCLUDE_VOL = {% include '$(_MK_VOLUME_MASKED_RELATIVE_FILE_PATH)' %})

$(shell [ "0" -eq "$(_MK_IS_CONTEX_EXIST)" ] \
  && echo -n "printf \"\\\nUNKNOWN CTX: '$(CTX)' \\\n \"; exit 1; ")

$(shell [ -f $(_MK_PATH_TARGET_VOLUME_TMPL) ] \
  && sed -i "/$(_NEW_INCLUDE_VOL)/d" $(_MK_PATH_TARGET_VOLUME_TMPL) \
  || echo -n "printf \"\\\nUNKNOWN SRV:    '$(SRV)'\\\nNOT FOUND FILE: $(_MK_PATH_TARGET_VOLUME_TMPL)\\\n\"; \
  exit 1; ")
endef