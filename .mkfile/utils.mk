__is_utils := 1
###########################################################
## Retrieve the directory of the current makefile
## Must be called before including any other makefile!!
###########################################################
# Figure out where we are.
define my-dir
$(strip \
  $(eval LOCAL_MODULE_MAKEFILE := $$(lastword $$(MAKEFILE_LIST))) \
  $(if $(filter $(BUILD_SYSTEM)/% $(OUT_DIR)/%,$(LOCAL_MODULE_MAKEFILE)), \
    $(error my-dir must be called before including any other makefile.) \
    , \
    $(patsubst %/,%,$(dir $(LOCAL_MODULE_MAKEFILE))) \
    ) \
)
endef

# $(call file-exists, file-name)
#   Return non-null if a file exists.
file-exists = $(wildcard $1)


# $(call maybe-mkdir, directory-name-opt)
#   Create a directory if it doesn't exist.
#   If directory-name-opt is omitted use $@ for the directory-name.
maybe-mkdir = $(if $(call file-exists, \
                $(if $1,$1,$(dir $@))),, \
                $(MKDIR) $(if $1,$1,$(dir $@)))