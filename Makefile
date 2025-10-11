.PHONY: all build build-all clean help

# Package configuration
PACKAGE_NAME := swarm-cli
VERSION := 1.0.0
BUILD_DIR := build

# Colors for output
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
NC := \033[0m

all: build

help:
	@echo "$(BLUE)Swarm CLI Build System$(NC)"
	@echo ""
	@echo "$(YELLOW)Available Targets:$(NC)"
	@echo "  $(GREEN)make build$(NC)      - Build binary for Linux"
	@echo "  $(GREEN)make build-all$(NC)  - Build binaries for all platforms"
	@echo "  $(GREEN)make clean$(NC)      - Clean build artifacts"
	@echo "  $(GREEN)make help$(NC)       - Show this help message"
	@echo ""
	@echo "$(YELLOW)Requirements:$(NC)"
	@echo "  - Node.js 22+ (for building only)"
	@echo "  - pnpm (will be auto-installed if missing)"
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  1. pnpm install"
	@echo "  2. make build"
	@echo "  3. ./build/swarm-cli-linux --help"
	@echo ""

build:
	@node build.js linux

build-all:
	@node build.js all

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✓ Clean complete$(NC)"
