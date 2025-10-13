# Makefile for building the book

PANDOC ?= pandoc
MDBOOK ?= mdbook
TEXLIVE ?= mactex
BOOK_DIR ?= book

# When set to 1 the Makefile allows failures to propagate (CI/main should set this).
FAIL_ON_ERROR ?= 0

# Default PDF engine to the mactex xelatex installation; can be overridden by environment
PDF_ENGINE ?= xelatex
OUT_DIR ?= out
TEST_OUT_DIR ?= $(OUT_DIR)/tests
CONVERT_SCRIPT ?= scripts/convert_spread.sh
TEST_SCRIPT ?= tests/convert_examples.sh

# Repeated tasks
.PHONY: build clean convert convert-all test book book-fragments book-dry print-ready book-ci

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


# Render fragments and concatenate into a master LaTeX file without compiling.
book-fragments: $(OUT_DIR)/book
	@echo "Rendering per-spread LaTeX fragments into $(OUT_DIR)/book/fragments"
	@for f in $(shell find src/manuscript -name '*.md' | sort); do \
		bn=$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g'); \
		bn="$${bn%.md}.tex"; \
		echo "  $$f -> $(OUT_DIR)/book/fragments/$$bn"; \
		$(PANDOC) "$$f" --to=latex --from markdown+yaml_metadata_block --lua-filter=filters/split_columns.lua --template=templates/fragment-template.tex -o "$(OUT_DIR)/book/fragments/$$bn"; \
		done
	@echo "Concatenating fragments into master LaTeX..."
	@cat templates/book-header.tex $(OUT_DIR)/book/fragments/*.tex templates/book-footer.tex > $(OUT_DIR)/book/book.tex

# Compile the concatenated LaTeX into PDF.
book: $(OUT_DIR)/book book-fragments
	@echo "Cleaning old LaTeX aux files and compiling master book PDF with $(PDF_ENGINE) (non-interactive)..."
	@cd $(OUT_DIR)/book && rm -f book.aux book.toc book.log book.out book.pdf || true
	@cd $(OUT_DIR)/book && if [ "$(FAIL_ON_ERROR)" = "1" ]; then \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1; \
		else \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1 || true; \
		fi
	@cd $(OUT_DIR)/book && if [ "$(FAIL_ON_ERROR)" = "1" ]; then \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1; \
		else \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1 || true; \
		fi
	@cd $(OUT_DIR)/book && if [ -f book.pdf ]; then \
		echo "Wrote $(OUT_DIR)/book/book.pdf"; \
		else echo "PDF not produced. Showing last 200 lines of book.log:"; tail -n 200 book.log; fi

# Dry-run target: render fragments and produce book.tex but do not compile.
book-dry: book-fragments
	@echo "Dry run complete: $(OUT_DIR)/book/book.tex created (no PDF compiled)."
	@echo "Run 'make book' or 'make book-ci' on main to produce PDFs."

# Create a print-ready, prepress-quality PDF using Ghostscript.
# This is intentionally separate so CI can call `make book-ci` to
# produce both the regular and print-ready PDFs reproducibly.
print-ready: $(OUT_DIR)/book
	@echo "Generating print-ready PDF $(OUT_DIR)/book/book_print_ready.pdf..."
	@if [ "$(FAIL_ON_ERROR)" = "1" ]; then \
		gs -dBATCH -dNOPAUSE -dSAFER -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress \
			-dCompatibilityLevel=1.6 -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true \
			-dAutoRotatePages=/None -dColorImageResolution=300 -dGrayImageResolution=300 \
			-dMonoImageResolution=600 -sOutputFile=$(OUT_DIR)/book/book_print_ready.pdf $(OUT_DIR)/book/book.pdf; \
		else \
		gs -dBATCH -dNOPAUSE -dSAFER -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress \
			-dCompatibilityLevel=1.6 -dEmbedAllFonts=true -dSubsetFonts=true -dCompressFonts=true \
			-dAutoRotatePages=/None -dColorImageResolution=300 -dGrayImageResolution=300 \
			-dMonoImageResolution=600 -sOutputFile=$(OUT_DIR)/book/book_print_ready.pdf $(OUT_DIR)/book/book.pdf || true; \
		fi
	@if [ -f $(OUT_DIR)/book/book_print_ready.pdf ]; then \
		echo "Wrote $(OUT_DIR)/book/book_print_ready.pdf"; \
		else echo "Failed to write print-ready PDF"; fi

# CI-oriented target: build the book and create the print-ready PDF
book-ci: book print-ready
	@echo "Built CI artifacts in $(OUT_DIR)/book"

.PHONY: book-debug
book-debug:
	@echo "Running incremental book debug to find problematic fragment..."
	@bash scripts/book_debug.sh $(OUT_DIR)/book