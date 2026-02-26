SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

.DEFAULT_GOAL := help

HELM ?= helm
YQ ?= yq

CHARTS_DIR ?= helm-chart-sources
PACKAGES_DIR ?= helm-chart-revisions
INDEX_FILE ?= index.yaml
REPO_URL ?= https://blog.beget.com/kaas-helm-charts
REPO_PACKAGES_URL ?= $(REPO_URL)/$(PACKAGES_DIR)

CHART_DIRS := $(sort $(dir $(wildcard $(CHARTS_DIR)/*/Chart.yaml)))

.PHONY: help all check-helm check-yq check-tools lint create-packages index

help:
	@echo "Targets:"
	@echo "  make create-packages  Build missing charts into $(PACKAGES_DIR)"
	@echo "  make index            Generate repo index and copy to $(INDEX_FILE)"
	@echo "  make all              create-packages + index"
	@echo "  make lint             helm lint for all charts"

all: create-packages index

check-helm:
	@command -v $(HELM) >/dev/null

check-yq:
	@command -v $(YQ) >/dev/null

check-tools: check-helm check-yq

lint: check-helm
	@$(HELM) lint $(CHARTS_DIR)/*

create-packages: check-tools
	@mkdir -p "$(PACKAGES_DIR)"
	@for d in $(CHART_DIRS); do \
		chart="$${d%/}"; \
		name=$$($(YQ) -r '.name' "$$chart/Chart.yaml"); \
		version=$$($(YQ) -r '.version' "$$chart/Chart.yaml"); \
		pkg="$(PACKAGES_DIR)/$${name}-$${version}.tgz"; \
		if [ -f "$$pkg" ]; then \
			echo "skip  $$pkg"; \
			continue; \
		fi; \
		echo "pack  $$chart -> $$pkg"; \
		$(HELM) package "$$chart" --destination "$(PACKAGES_DIR)" >/dev/null; \
	done

index: check-tools
	@mkdir -p "$(PACKAGES_DIR)"
	@expected=$$(mktemp); \
	old_index=$$(mktemp); \
	trap 'rm -f "$$expected" "$$old_index" "$(PACKAGES_DIR)/index.yaml"' EXIT; \
	for d in $(CHART_DIRS); do \
		chart="$${d%/}"; \
		name=$$($(YQ) -r '.name' "$$chart/Chart.yaml"); \
		version=$$($(YQ) -r '.version' "$$chart/Chart.yaml"); \
		echo "$${name}-$${version}.tgz"; \
	done > "$$expected"; \
	for pkg in "$(PACKAGES_DIR)"/*.tgz; do \
		[ -f "$$pkg" ] || continue; \
		base=$$(basename "$$pkg"); \
		if ! grep -qxF "$$base" "$$expected"; then \
			echo "purge $$pkg"; \
			rm -f "$$pkg"; \
		fi; \
	done; \
	if [ -s "$(INDEX_FILE)" ]; then \
		cp "$(INDEX_FILE)" "$$old_index"; \
	fi; \
	$(HELM) repo index "$(PACKAGES_DIR)" --url "$(REPO_PACKAGES_URL)"; \
	cp "$(PACKAGES_DIR)/index.yaml" "$(INDEX_FILE)"; \
	if [ -s "$$old_index" ]; then \
		$(YQ) -r -s '.[0].entries as $$old | .[1].entries | to_entries[] | .value[] | . as $$e | ($$old[.name] // [] | map(select(.version == $$e.version and .digest == $$e.digest)) | .[0].created) as $$oc | select($$oc != null and $$oc != $$e.created) | "\($$e.created)\t\($$oc)"' "$$old_index" "$(PACKAGES_DIR)/index.yaml" \
		| while IFS=$$'\t' read -r new_date old_date; do \
			sed -i "s|$$new_date|$$old_date|" "$(INDEX_FILE)"; \
		done; \
	fi; \
	rm -f "$(PACKAGES_DIR)/index.yaml"; \
	echo "index $(INDEX_FILE) updated"
