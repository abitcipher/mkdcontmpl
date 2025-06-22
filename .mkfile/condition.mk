__is_condition := 1

ifndef_any_of = $(filter undefined,$(foreach v,$(1),$(origin $(v))))
ifdef_any_of = $(filter-out undefined,$(foreach v,$(1),$(origin $(v))))

# increment adds 1 to its argument, decrement subtracts 1.
# Note that decrement does not range check and hence will not underflow, but
# will incorrectly say that 0 - 1 = 0

increment = $1 x
decrement = $(wordlist 2,$(words $1),$1)

upper = $(shell echo '$1' | tr '[:lower:]' '[:upper:]')
lower = $(shell echo '$1' | tr '[:upper:]' '[:lower:]')

file_exists = $(wildcard $1)
# The following operators return a non-empty string if their result
# is true:
#
# gt  First argument greater than second argument
# gte First argument greater than or equal to second argument
# lt  First argument less than second argument

# lte First argument less than or equal to second argument
# eq  First argument is numerically equal to the second argument
# ne  First argument is not numerically equal to the second argument

gt = $(filter-out $(words $2),$(words $(call max,$1,$2)))
lt = $(filter-out $(words $1),$(words $(call max,$1,$2)))
eq = $(filter $(words $1),$(words $2))
ne = $(filter-out $(words $1),$(words $2))
gte = $(call gt,$1,$2)$(call eq,$1,$2)
lte = $(call lt,$1,$2)$(call eq,$1,$2)

### is_defined: check if variable is defined in a Makefile
### example `$(call is_defined, var1)` will stop with `error` if not
is_defined = \
    $(strip $(foreach 1,$1, \
        $(call __is_defined,$1,$(strip $(value 2)))))
__is_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))
