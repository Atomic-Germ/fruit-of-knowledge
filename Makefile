# Makefile for building the book

PANDOC ?= pandoc
MDBOOK ?= mdbook
TEXLIVE ?= mactex
BOOK_DIR ?= book
TEXBIN ?= /Library/TeX/texbin

# Ensure TeX binaries are on PATH so make-invoked scripts can find xelatex/lualatex/pdflatex
export PATH := $(TEXBIN):$(PATH)

# Default PDF engine to the mactex xelatex installation; can be overridden by environment
PDF_ENGINE ?= $(TEXBIN)/xelatex
export PDF_ENGINE
OUT_DIR ?= out
TEST_OUT_DIR ?= $(OUT_DIR)/tests
CONVERT_SCRIPT ?= scripts/convert_spread.sh
TEST_SCRIPT ?= tests/convert_examples.sh
XELATEX ?= /Library/TeX/texbin/xelatex

# Repeated tasks
.PHONY: build clean convert convert-all test

# Build the book (uses mdbook by default)
build:
	@echo "Building book to $(BOOK_DIR)..."
	$(MDBOOK) build

# Remove generated build output
clean:
	@echo "Removing generated build and output directories: $(BOOK_DIR), $(OUT_DIR)"
	rm -rf $(BOOK_DIR) $(OUT_DIR)

# Convert example spreads (test conversion)
$(TEST_OUT_DIR):
	@mkdir -p $(TEST_OUT_DIR)

convert: $(TEST_OUT_DIR)
	@echo "Running example conversions -> $(TEST_OUT_DIR)"
	@bash $(TEST_SCRIPT)

# Convert all manuscript spreads into $(OUT_DIR)
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

convert-all: $(OUT_DIR)
	@echo "Converting all manuscript spreads to $(OUT_DIR)..."
	@for f in $(shell find src/manuscript -name '*.md'); do \
		out=$(OUT_DIR)/$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g; s#\.md$$#.pdf#'); \
		echo "Converting $$f -> $$out"; \
		bash $(CONVERT_SCRIPT) "$$f" "$$out"; \
	done