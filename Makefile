SHELL := /bin/bash

ifneq ($(IMAGE), undefined)
	IPATH = $(wildcard $(IMAGE))
	NAME ?= $(shell basename "$(IMAGE)" | sed 's/-unsplash.*//' | awk -F '-' '{print $$NF}')
endif

help:
	@echo "+ $@"
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m%s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

node_modules: package.json
	@npm install
	@touch $@

dev: node_modules ## Start up local server
	@echo "+ $@"
	@hugo server --buildDrafts --openBrowser
.PHONY: dev

prod: node_modules ## Build production assets
	@echo "+ $@"
	@hugo build --minify
.PHONY: prod

lint: node_modules ## Check for prettier issues
	@echo "+ $@"
	@npm run lint
.PHONY: lint

format: node_modules ## Fix prettier issues
	@echo "+ $@"
	@npm run format
.PHONY: format

proof: prod ## Run html-proofer against our prod build
	@echo "+ $@"
	@docker run --rm \
		-v $(PWD)/public:/public \
		-e INPUT_DIRECTORY=public \
		-e INPUT_SWAP_URLS='{"^https:\\/\\/mlo\\.io\\/": "/"}' \
		anishathalye/proof-html:2.1.4
.PHONY: proof

draft: ## Create a new draft
	@echo "+ $@"
	@read -e -p "Draft name: " draftname && hugo new content "posts/$(shell date +%Y-%m-%d)-$${draftname/ /-}.md"
	@echo "Remember to run make write-good on the post and remove the draft from the frontmatter to publish"
.PHONY: draft

ifneq ("$(IPATH)","")
hero: ## Create a hero image (IMAGE=path/to/image NAME=optional-name)
	@echo "+ $@"
	@command -v magick >/dev/null 2>&1 || (>&2 echo "imagemagick not installed" && exit 1)
	magick "$(IPATH)" -resize 2500 "static/images/hero/$(NAME)-xl.webp"
	magick "$(IPATH)" -resize 1200 "static/images/hero/$(NAME)-lg.webp"
	magick "$(IPATH)" -resize 992 "static/images/hero/$(NAME)-md.webp"
	magick "$(IPATH)" -resize 768 "static/images/hero/$(NAME)-sm.webp"
	magick "$(IPATH)" -resize 576 "static/images/hero/$(NAME).webp"
	@echo "Created hero $(NAME)! To finish add the following lines to assets/css/main.css:"
	@echo ".hero-$(NAME) {"
	@echo "  background-image: url('/images/hero/$(NAME).webp');"
	@echo "  @variant sm {"
	@echo "    background-image: url('/images/hero/$(NAME)-sm.webp');"
	@echo "  }"
	@echo "  @variant md {"
	@echo "    background-image: url('/images/hero/$(NAME)-md.webp');"
	@echo "  }"
	@echo "  @variant lg {"
	@echo "    background-image: url('/images/hero/$(NAME)-lg.webp');"
	@echo "  }"
	@echo "  @variant xl {"
	@echo "    background-image: url('/images/hero/$(NAME)-xl.webp');"
	@echo "  }"
	@echo "}"
else
hero:
	@echo "usage: make hero IMAGE=path/to/image NAME=optional-name" >&2
	@exit 1
endif
.PHONY: hero

ifneq ("$(wildcard $(POST))", "")
write-good: ## Check a post for writing fixes and improvements
	@echo "+ $@"
	@aspell -M -x check "$(POST)"
	@npx write-good "$(POST)" || true
	@npx alex "$(POST)" || true
else
write-good:
	@echo "usage: make write-good POST=path/to/post" >&2
	@exit 1
endif
.PHONY: write-good
