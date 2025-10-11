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
.PHONY: build clean convert convert-all test book

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

# Build a single combined LaTeX book from all manuscript spreads
$(OUT_DIR)/book:
	@mkdir -p $(OUT_DIR)/book/fragments

book: $(OUT_DIR)/book
	@echo "Rendering per-spread LaTeX fragments into $(OUT_DIR)/book/fragments"
	@for f in $(shell find src/manuscript -name '*.md' | sort); do \
	bn=$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g'); \
	bn="$${bn%.md}.tex"; \
	echo "  $$f -> $(OUT_DIR)/book/fragments/$$bn"; \
	$(PANDOC) "$$f" --from markdown+yaml_metadata_block --lua-filter=filters/split_columns.lua --template=templates/fragment-template.tex -o "$(OUT_DIR)/book/fragments/$$bn"; \
	done
	@echo "Concatenating fragments into master LaTeX..."
	@cat templates/book-header.tex $(OUT_DIR)/book/fragments/*.tex templates/book-footer.tex > $(OUT_DIR)/book/book.tex
	@echo "Compiling master book PDF with $(PDF_ENGINE)..."
	@cd $(OUT_DIR)/book && $(PDF_ENGINE) book.tex >/dev/null 2>&1 || true
	@cd $(OUT_DIR)/book && $(PDF_ENGINE) book.tex >/dev/null 2>&1 || true
	@echo "Wrote $(OUT_DIR)/book/book.pdf"