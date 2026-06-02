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
	@printf '' > "$(PACKAGES_DIR)/.newly_built"; \
	for d in $(CHART_DIRS); do \
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
		echo "$${name}/$${version}" >> "$(PACKAGES_DIR)/.newly_built"; \
	done

index: check-tools
	@mkdir -p "$(PACKAGES_DIR)"
	@known_names=$$(mktemp); \
	tmpdir=$$(mktemp -d); \
	newly_built="$(PACKAGES_DIR)/.newly_built"; \
	trap 'rm -f "$$known_names" "$$newly_built"; rm -rf "$$tmpdir"' EXIT; \
	for d in $(CHART_DIRS); do \
		$(YQ) -r '.name' "$${d%/}/Chart.yaml"; \
	done | sort -u > "$$known_names"; \
	purged="$$tmpdir/purged"; : > "$$purged"; \
	for pkg in "$(PACKAGES_DIR)"/*.tgz; do \
		[ -f "$$pkg" ] || continue; \
		base=$$(basename "$$pkg" .tgz); \
		matched=0; \
		while read -r name; do \
			case "$$base" in "$$name"-[0-9]*|"$$name"-v[0-9]*) matched=1; break;; esac; \
		done < "$$known_names"; \
		if [ "$$matched" -eq 0 ]; then \
			echo "purge $$pkg"; \
			echo "$$base.tgz" >> "$$purged"; \
			rm -f "$$pkg"; \
		fi; \
	done; \
	if [ ! -s "$(INDEX_FILE)" ]; then \
		$(HELM) repo index "$(PACKAGES_DIR)" --url "$(REPO_PACKAGES_URL)"; \
		mv "$(PACKAGES_DIR)/index.yaml" "$(INDEX_FILE)"; \
		echo "index $(INDEX_FILE) created"; \
		exit 0; \
	fi; \
	if [ ! -s "$$purged" ] && [ ! -s "$$newly_built" ]; then \
		echo "index $(INDEX_FILE) up-to-date"; \
		exit 0; \
	fi; \
	work="$$tmpdir/work.yaml"; \
	cp "$(INDEX_FILE)" "$$work"; \
	if [ -s "$$purged" ]; then \
		while read -r fname; do \
			[ -n "$$fname" ] || continue; \
			FNAME="$$fname" $(YQ) -i 'del(.entries[][] | select((.urls[0] | split("/") | .[-1]) == env(FNAME)))' "$$work"; \
		done < "$$purged"; \
		$(YQ) -i 'del(.entries[] | select(length == 0))' "$$work"; \
	fi; \
	if [ -s "$$newly_built" ]; then \
		new_pkg_dir="$$tmpdir/new_pkgs"; mkdir -p "$$new_pkg_dir"; \
		while IFS=/ read -r nb_name nb_ver; do \
			[ -n "$$nb_name" ] || continue; \
			NB_NAME="$$nb_name" NB_VER="$$nb_ver" $(YQ) -i 'del(.entries[env(NB_NAME)][] | select(.version == env(NB_VER)))' "$$work"; \
			ln -s "$$(pwd)/$(PACKAGES_DIR)/$${nb_name}-$${nb_ver}.tgz" "$$new_pkg_dir/$${nb_name}-$${nb_ver}.tgz"; \
		done < "$$newly_built"; \
		$(HELM) repo index "$$new_pkg_dir" --url "$(REPO_PACKAGES_URL)"; \
		$(YQ) -i '.entries = (.entries *+ load("'"$$new_pkg_dir/index.yaml"'").entries)' "$$work"; \
	fi; \
	if diff -q "$$work" "$(INDEX_FILE)" > /dev/null 2>&1; then \
		echo "index $(INDEX_FILE) up-to-date"; \
	else \
		mv "$$work" "$(INDEX_FILE)"; \
		echo "index $(INDEX_FILE) updated"; \
	fi
