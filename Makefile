help:

	@echo "Run 'make build' to build the docs, or make-stage to stage the docs."

.PHONY: help build stage

build:

	@echo "Building docs. Output goes to `public/`"
	@hugo

stage:
	@(./stage.sh)
