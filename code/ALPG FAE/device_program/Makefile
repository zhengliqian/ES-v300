MAKEFLAGS := --no-print-directory
OPTIONS :=
SUBMAKEDIR := \
	source \
	pat \
	
all:
	@for dir in $(SUBMAKEDIR); do \
		echo "\n============ Compile $$dir ============"; \
		(cd $$dir && make $(OPTIONS) all) || exit 1; \
	done
	@echo "============ Compile Completed ============"
	
clean:
	@for dir in $(SUBMAKEDIR); do \
		echo "\n============ Clean $$dir ============"; \
		(cd $$dir && make $(OPTIONS) clean) || exit 1; \
	done
	@echo "============ Clean Completed ============"
