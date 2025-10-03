.PHONY: all build build-with-image clean install uninstall help

# Package configuration
PACKAGE_NAME := swarm-cli
VERSION := 1.0.0
ARCHITECTURE := all
BUILD_DIR := build
DEB_FILE := $(PACKAGE_NAME)_$(VERSION)_$(ARCHITECTURE).deb
PACKAGE_DIR := $(BUILD_DIR)/$(PACKAGE_NAME)
DOCKER_IMAGE := ghcr.io/metaprovide/swarm-cli:latest
DOCKER_IMAGE_TAR := swarm-cli-docker-image.tar.gz

# Colors for output
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[0;33m
NC := \033[0m

all: build

help:
	@echo "$(BLUE)Swarm CLI Debian Package Makefile$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(GREEN)make build$(NC)         - Build the Debian package (without Docker image)"
	@echo "  $(GREEN)make build-with-image$(NC) - Build package with bundled Docker image"
	@echo "  $(GREEN)make clean$(NC)         - Clean build artifacts"
	@echo "  $(GREEN)make install$(NC)       - Install the package (requires sudo)"
	@echo "  $(GREEN)make uninstall$(NC)     - Uninstall the package (requires sudo)"
	@echo "  $(GREEN)make help$(NC)          - Show this help message"
	@echo ""

build: clean
	@echo "$(BLUE)Building $(PACKAGE_NAME) Debian package (without Docker image)...$(NC)"
	@echo "Creating package structure..."
	@mkdir -p $(PACKAGE_DIR)
	
	@echo "Copying package files..."
	@cp -r debian/* $(PACKAGE_DIR)/
	
	@echo "Setting permissions..."
	@chmod 755 $(PACKAGE_DIR)/DEBIAN
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/postinst
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/prerm
	@chmod 755 $(PACKAGE_DIR)/usr/bin/swarm-cli
	
	@echo "Building .deb package..."
	@dpkg-deb --build $(PACKAGE_DIR) $(BUILD_DIR)/$(DEB_FILE)
	
	@echo "Moving package to root directory..."
	@mv $(BUILD_DIR)/$(DEB_FILE) .
	
	@echo "$(GREEN)✓ Package built successfully: $(DEB_FILE)$(NC)"
	@echo ""
	@echo "To install the package, run:"
	@echo "  $(BLUE)make install$(NC)"
	@echo ""

build-with-image: clean
	@echo "$(BLUE)Building $(PACKAGE_NAME) Debian package with bundled Docker image...$(NC)"
	@echo "Creating package structure..."
	@mkdir -p $(PACKAGE_DIR)/usr/share/swarm-cli
	
	@echo "Copying package files..."
	@cp -r debian/* $(PACKAGE_DIR)/
	
	@echo "Pulling Docker image..."
	@docker pull $(DOCKER_IMAGE)
	
	@echo "Exporting Docker image to tar.gz..."
	@docker save $(DOCKER_IMAGE) | gzip > $(PACKAGE_DIR)/usr/share/swarm-cli/$(DOCKER_IMAGE_TAR)
	
	@echo "Setting permissions..."
	@chmod 755 $(PACKAGE_DIR)/DEBIAN
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/postinst
	@chmod 755 $(PACKAGE_DIR)/DEBIAN/prerm
	@chmod 755 $(PACKAGE_DIR)/usr/bin/swarm-cli
	@chmod 644 $(PACKAGE_DIR)/usr/share/swarm-cli/$(DOCKER_IMAGE_TAR)
	
	@echo "Building .deb package..."
	@dpkg-deb --build $(PACKAGE_DIR) $(BUILD_DIR)/$(DEB_FILE)
	
	@echo "Moving package to root directory..."
	@mv $(BUILD_DIR)/$(DEB_FILE) .
	
	@echo "$(GREEN)✓ Package with bundled image built successfully: $(DEB_FILE)$(NC)"
	@echo "$(YELLOW)Note: Package size is larger due to bundled Docker image$(NC)"
	@echo ""
	@echo "To install the package, run:"
	@echo "  $(BLUE)make install$(NC)"
	@echo ""

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(PACKAGE_NAME)_*.deb
	@echo "$(GREEN)✓ Clean complete$(NC)"

install: $(DEB_FILE)
	@echo "$(BLUE)Installing $(DEB_FILE)...$(NC)"
	@sudo apt install ./$(DEB_FILE)
	@echo "$(GREEN)✓ Installation complete$(NC)"

uninstall:
	@echo "$(YELLOW)Uninstalling $(PACKAGE_NAME)...$(NC)"
	@sudo apt remove $(PACKAGE_NAME)
	@echo "$(GREEN)✓ Uninstall complete$(NC)"

$(DEB_FILE):
	@echo "$(YELLOW)Package not found. Building...$(NC)"
	@$(MAKE) build
