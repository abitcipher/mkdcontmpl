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

define _mk_help
printf "\n$(_MK_COLOR_TERM_WHITE)%s$(_MK_COLOR_TERM_RESET)" $(1)
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
