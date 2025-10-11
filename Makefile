# Makefile for building the book

MDBOOK ?= mdbook
BOOK_DIR ?= book

.PHONY: build clean serve

# Build the book (uses mdbook by default)
build:
	@echo "Building book to $(BOOK_DIR)..."
	$(MDBOOK) build

# Remove generated build output
clean:
	@echo "Removing generated book directory: $(BOOK_DIR)"
	rm -rf $(BOOK_DIR)