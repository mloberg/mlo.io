SHELL := /bin/bash

help:
	@echo "+ $@"
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m%s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

setup: ## Setup project
	@echo "+ $@"
	@npm install
	@bundle install --path=vendor/bundle --jobs=4 --retry=3
.PHONY: setup

dev: ## Serve the project
	@echo "+ $@"
	@bundle exec jekyll browsersync --drafts --open
.PHONY: dev

draft: ## Create a new draft
	@echo "+ $@"
	@read -e -p "Draft name: " draftname && bundle exec jekyll draft "$$draftname"
.PHONY: draft
