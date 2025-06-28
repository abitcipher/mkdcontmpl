__is_help := 1

HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'targets'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
	print "${_MK_VERSION} - Usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${_MK_COLOR_TERM_WHITE}$$_:${_MK_COLOR_TERM_RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (20 - length $$_->[0]); \
	print "  ${_MK_COLOR_TERM_YELLOW}$$_->[0]${_MK_COLOR_TERM_RESET}$$sep${_MK_COLOR_TERM_GREEN}$$_->[1]${_MK_COLOR_TERM_RESET}\n"; \
	}; \
	print "\n"; }
