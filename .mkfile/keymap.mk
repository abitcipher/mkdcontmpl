__is_keymap := 1

.SUFFIXES:
MAKEFLAGS += -r
SHELL := /bin/bash


### _MK_KEYMAP_FILES: List of files with (key,value) pairs. Keys in later files override keys in earlier files.
ifndef _MK_KEYMAP_FILES
_MK_KEYMAP_FILES = \
	$(shell ! [ -r KEYS ] || echo KEYS) \
	$(shell ! [ -r KEYS.local ] || echo KEYS.local)
endif


# _MK_KEYMAP_PREFIX - Prefix for make variables holding the map.
ifndef _MK_KEYMAP_PREFIX
_MK_KEYMAP_PREFIX = KV
endif


# _MK_KEYMAP_SEPARATOR - Separator for keys.
ifndef _MK_KEYMAP_SEPARATOR
_MK_KEYMAP_SEPARATOR = ¦
endif


### load keymap
cat_keymap_file := "cat ${_MK_KEYMAP_FILES} \
					| egrep -v \"^ *($$|\#)\" \
					| awk '{if (sub(/\\\\$$/,\"\")) printf \"%s\", \$$0; else print}'"

##? > cat .test/kv.db.txt | egrep -v "^ *($|#)" | awk '{if (sub(/\\$/,"")) printf "%s", $0; else print}'
##? test
##? test¦key             value
##? test¦oneline         one line value
##? test¦multiline   --multi   --line
##? testkv               key+value
##? md5sum               e65b0dce58cbecf21e7c9ff7318f3b57
##? url                  https://test.net
##? url¦subdir           https://test.net/subdir
##? url¦subdir¦slug      https://test.net/subdir/slug
##? url¦subdir¦param     https://test.net/subdir?param=1234567890

lines := $(shell eval ${cat_keymap_file})

# ?kvLines -> lines := $(shell eval ${cat_keymap_file})
define kvPrefix
$(shell eval ${cat_keymap_file} \
| awk -v prefix="${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}" \
		'NR==${i} { \
			key=$$1; \
			for(i=2; i<=NF; ++i) $$(i-1)=$$i; \
			NF-=1; \
			print prefix key " := " $$0 \
		}' \
)
endef


$(foreach i, \
	$(shell seq 1 $(shell eval ${cat_keymap_file} | wc -l)), \
		$(eval $(shell eval ${cat_keymap_file} \
				| awk -v prefix="${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}" \
						'NR==${i} { \
							key=$$1; \
							for(i=2; i<=NF; ++i) $$(i-1)=$$i; \
							NF-=1; \
							print prefix key " := " $$0 \
						}' \
				) \
		) \
)

_MK_KEYMAP_KEY_LIST := $(patsubst ${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}%,%,$(filter ${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}%,${.VARIABLES}))


### compute prefix lists
_MK_KEYMAP_KEY_PREFIX_LIST_DELIMITED := \
	$(shell eval ${cat_keymap_file} \
	| awk -v delim="${_MK_KEYMAP_SEPARATOR}" '{ \
				n=split($$1,a,delim); \
				p=""; \
				for(i=1;i<=n;++i) { \
					print p delim; \
					p = p delim a[i]; \
				} \
			}' \
	| sort | uniq)

_MK_KEYMAP_KEY_PREFIX_LIST := \
	$(foreach kp, ${_MK_KEYMAP_KEY_PREFIX_LIST_DELIMITED}, \
		$(patsubst ${_MK_KEYMAP_SEPARATOR}%,%,$(patsubst %${_MK_KEYMAP_SEPARATOR},%,${kp})) \
	)


### initialize prefix lists
$(foreach kp, ${_MK_KEYMAP_KEY_PREFIX_LIST_DELIMITED}, \
	$(eval $(shell { \
		echo -n "${_MK_KEYMAP_PREFIX}${kp} := "; \
		eval ${cat_keymap_file} \
		| awk 	-v delim="${_MK_KEYMAP_SEPARATOR}" \
				-v kp="$(patsubst ${_MK_KEYMAP_SEPARATOR}%,%,${kp})" \
				'BEGIN{kp_len=length(kp)} \
					substr($$1,1,kp_len)==kp { \
					 	s=substr($$1,kp_len+1); \
						n=split(s,a,delim); \
						print a[1]; \
					}' | sort | uniq; \
			}) \
	) \
)


### keymap_val: Get value for full key.
keymap_val = $(${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}${1})

kmval = $(shell echo -n "echo \"${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}$(1)\"")

### keymap_key_list: List next components for partial key.
keymap_key_list = $($(if ${1},${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}${1}${_MK_KEYMAP_SEPARATOR},${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}))


define kvList
$(foreach v, $(.VARIABLES), \
		$(if $(filter file,$(origin $(v))), \
			$(if $(filter $(_MK_KEYMAP_PREFIX)%, $(v)), \
			$(info '$(v)=$($(v))')) \
		) \
	)
endef


### kv_set:
define kv_set 
$(eval kvKey=${1})
$(eval kvVal=${2})
$(shell cat ${_MK_KEYMAP_FILES} | grep $(kvKey))
$(call _mk_inf, "kvKey: $(kvKey)...")
$(call _mk_inf, "kvVal: $(kvVal)...")
printf "\n"
endef

print-%:
	@echo '$* = $(subst ','\'',${$*})'


# e.g.,
# print-${_MK_KEYMAP_PREFIX}${_MK_KEYMAP_SEPARATOR}
