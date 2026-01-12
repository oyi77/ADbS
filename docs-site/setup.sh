#!/bin/bash
# Setup script for ADbS documentation site

set -e

echo "Setting up ADbS documentation site..."

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo "❌ Hugo is not installed."
    echo "Please install Hugo Extended:"
    echo "  macOS: brew install hugo"
    echo "  Linux: See https://gohugo.io/installation/"
    echo "  Windows: See https://gohugo.io/installation/"
    exit 1
fi

# Check Hugo version (need extended)
HUGO_VERSION=$(hugo version)
if [[ ! "$HUGO_VERSION" == *"extended"* ]]; then
    echo "⚠️  Warning: Hugo Extended is recommended for this theme."
    echo "Current version: $HUGO_VERSION"
fi

# Initialize submodules if not already done
if [ ! -d "themes/PaperMod" ]; then
    echo "📦 Installing PaperMod theme..."
    git submodule update --init --recursive
else
    echo "✅ Theme already installed"
fi

# Update submodules
echo "🔄 Updating submodules..."
git submodule update --remote --merge

echo ""
echo "✅ Setup complete!"
echo ""
echo "To start the development server:"
echo "  cd docs-site"
echo "  hugo server"
echo ""
echo "The site will be available at http://localhost:1313"

