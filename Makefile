# ADbS Cross-Compilation Makefile

# Environment
NAME := adbs
VERSION := 1.0.0
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Output directory
DIST := dist

# Go parameters
LDFLAGS := -s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE)

# Platforms to build
PLATFORMS := \
	linux-amd64 \
	linux-arm64 \
	linux-386 \
	darwin-amd64 \
	darwin-arm64 \
	windows-amd64

.PHONY: all clean build build-all lint test install

# Default target
all: build

# Build for current platform
build:
	go build -ldflags="$(LDFLAGS)" -o $(NAME) ./cmd/adbs

# Build for all platforms
build-all: $(addprefix build-,$(PLATFORMS))
	@echo "Build complete in $(DIST)/"

$(DIST):
	mkdir -p $(DIST)

build-linux-amd64: $(DIST)
	GOOS=linux GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-linux-amd64 ./cmd/adbs

build-linux-arm64: $(DIST)
	GOOS=linux GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-linux-arm64 ./cmd/adbs

build-linux-386: $(DIST)
	GOOS=linux GOARCH=386 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-linux-386 ./cmd/adbs

build-darwin-amd64: $(DIST)
	GOOS=darwin GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-darwin-amd64 ./cmd/adbs

build-darwin-arm64: $(DIST)
	GOOS=darwin GOARCH=arm64 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-darwin-arm64 ./cmd/adbs

build-windows-amd64: $(DIST)
	GOOS=windows GOARCH=amd64 go build -ldflags="$(LDFLAGS)" -o $(DIST)/$(NAME)-windows-amd64.exe ./cmd/adbs

# Clean build artifacts
clean:
	rm -rf $(DIST)

# Run tests
test:
	go test ./...

# Install to system
install:
	go install -ldflags="$(LDFLAGS)" ./cmd/adbs

# Show help
help:
	@echo "ADbS Build System"
	@echo ""
	@echo "Targets:"
	@echo "  build          Build for current platform"
	@echo "  build-all      Build for all platforms"
	@echo "  clean          Remove build artifacts"
	@echo "  test           Run tests"
	@echo "  install        Install to system"
	@echo "  help           Show this help"
