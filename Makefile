# Makefile for building the book

PANDOC ?= pandoc
MDBOOK ?= mdbook
TEXLIVE ?= mactex
BOOK_DIR ?= book

# If DRAFT=1 is set, pass draft metadata to pandoc so templates can show debug info
DRAFT_FLAGS :=
ifeq ($(DRAFT),1)
DRAFT_FLAGS := --metadata=draft:true
endif

# When set to 1 the Makefile allows failures to propagate (CI/main should set this).
FAIL_ON_ERROR ?= 0

# Default PDF engine to the mactex xelatex installation; can be overridden by environment
PDF_ENGINE ?= xelatex
OUT_DIR ?= out
TEST_OUT_DIR ?= $(OUT_DIR)/tests
CONVERT_SCRIPT ?= scripts/convert_spread.sh
TEST_SCRIPT ?= tests/convert_examples.sh
TOC_SCRIPT ?= scripts/generate_toc.py

# Repeated tasks
.PHONY: build clean convert convert-all test book book-fragments book-dry print-ready book-ci toc
.PHONY: list-book-fragments list-spreads test-order

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
	@for f in $(shell scripts/list_spreads.sh); do \
			out=$(OUT_DIR)/$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g; s#\.md$$#.pdf#'); \
			echo "Converting $$f -> $$out"; \
			bash $(CONVERT_SCRIPT) "$$f" "$$out"; \
		done

# Convenience: print the ordered list of book fragments
list-book-fragments:
	@./scripts/list_book_fragments.sh

# Convenience: print the ordered list of spreads
list-spreads:
	@./scripts/list_spreads.sh

# Run ordering test (used by CI)
test-order:
	@chmod +x tests/check_ordering.sh
	@./tests/check_ordering.sh

# Build a single combined LaTeX book from all manuscript spreads
$(OUT_DIR)/book:
	@mkdir -p $(OUT_DIR)/book/fragments


# Render fragments and concatenate into a master LaTeX file without compiling.
book-fragments: $(OUT_DIR)/book toc
	@echo "Rendering per-spread LaTeX fragments into $(OUT_DIR)/book/fragments"
	@for f in $(shell scripts/list_book_fragments.sh); do \
		bn=$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g'); \
		bn="$${bn%.md}.tex"; \
		echo "  $$f -> $(OUT_DIR)/book/fragments/$$bn"; \
		label=$$(echo $$f | sed 's#src/manuscript/##; s#/#_#g; s#\.md##'); \
		if echo "$$f" | grep -q '/SPREAD_'; then \
			$(PANDOC) "$$f" --to=latex --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart $(DRAFT_FLAGS) --lua-filter=filters/footnotes_to_footer.lua --lua-filter=filters/custom_divs.lua --lua-filter=filters/split_columns.lua --lua-filter=filters/blockquote_box.lua --template=templates/fragment-template.tex -o "$(OUT_DIR)/book/fragments/$$bn.tmp"; \
		else \
			$(PANDOC) "$$f" --to=latex --from markdown+yaml_metadata_block+definition_lists+footnotes+pipe_tables+grid_tables+fenced_divs+bracketed_spans+inline_code_attributes+fenced_code_attributes+strikeout+superscript+subscript+task_lists+smart $(DRAFT_FLAGS) --lua-filter=filters/footnotes_to_footer.lua --lua-filter=filters/custom_divs.lua --lua-filter=filters/blockquote_box.lua --template=templates/fragment-template.tex -o "$(OUT_DIR)/book/fragments/$$bn.tmp"; \
		fi; \
		printf "\\\phantomsection\\\label{frag:%s}\\n" "$$label" > "$(OUT_DIR)/book/fragments/$$bn"; \
		cat "$(OUT_DIR)/book/fragments/$$bn.tmp" >> "$(OUT_DIR)/book/fragments/$$bn"; \
		rm -f "$(OUT_DIR)/book/fragments/$$bn.tmp"; \
	done
	@echo "Concatenating fragments into master LaTeX..."
	@# Concatenate: header, front matter (00_*), content (non-00_*), footer
	@cat templates/book-header.tex > $(OUT_DIR)/book/book.tex
	@cat $(OUT_DIR)/book/fragments/00_*.tex >> $(OUT_DIR)/book/book.tex
	@ls $(OUT_DIR)/book/fragments/*.tex | grep -v '/00_' | xargs cat >> $(OUT_DIR)/book/book.tex
	@cat templates/book-footer.tex >> $(OUT_DIR)/book/book.tex

# Compile the concatenated LaTeX into PDF.
book: $(OUT_DIR)/book book-fragments
	@echo "Cleaning old LaTeX aux files and compiling master book PDF with $(PDF_ENGINE) (non-interactive)..."
	@cd $(OUT_DIR)/book && rm -f book.aux book.toc book.log book.out book.pdf || true
	@cd $(OUT_DIR)/book && if [ "$(FAIL_ON_ERROR)" = "1" ]; then \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1; \
		else \
		$(PDF_ENGINE) -interaction=nonstopmode -file-line-error book.tex >book.log 2>&1 || true; \
		fi
	@echo "Updating TOC with page numbers from AUX..."
	@python3 $(TOC_SCRIPT) --aux "$(OUT_DIR)/book/book.aux"
	@$(MAKE) book-fragments
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

.PHONY: draft
draft:
	@echo "Running draft build (includes front-matter debug info)..."
	@$(MAKE) DRAFT=1 book

# Generate/refresh the Table of Contents page (00_05_TOC.md) before rendering fragments
.PHONY: toc
toc:
	@echo "Generating manuscript Table of Contents (00_05_TOC.md)..."
	@if [ -f $(OUT_DIR)/book/book.aux ]; then \
		python3 $(TOC_SCRIPT) --aux "$(OUT_DIR)/book/book.aux"; \
	else \
		python3 $(TOC_SCRIPT); \
	fi