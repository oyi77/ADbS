# Quick Start for Documentation Site

Get the documentation site running locally in minutes.

## Prerequisites

Install Hugo Extended:

**macOS:**
```bash
brew install hugo
```

**Linux:**
```bash
# Download from https://gohugo.io/installation/
# Or use package manager
```

**Windows:**
Download from [Hugo releases](https://github.com/gohugoio/hugo/releases)

Verify installation:
```bash
hugo version
# Should show: hugo v0.x.x+extended
```

## Setup

1. **Initialize theme** (first time only):
   ```bash
   cd docs-site
   git submodule update --init --recursive
   ```

2. **Start development server**:
   ```bash
   hugo server
   ```

3. **View site**:
   Open http://localhost:1313 in your browser

## Building for Production

```bash
cd docs-site
hugo --minify
```

Output will be in `docs-site/public/` directory.

## Making Changes

1. Edit markdown files in `docs-site/content/`
2. Hugo automatically rebuilds (in server mode)
3. Refresh browser to see changes

## Project Structure

```
docs-site/
├── config.yaml          # Hugo configuration
├── content/             # Markdown content
│   ├── _index.md       # Homepage
│   ├── installation.md
│   ├── usage.md
│   ├── demo.md
│   ├── contributing.md
│   └── docs/           # Documentation section
├── themes/              # Hugo themes (PaperMod)
└── public/             # Generated site (gitignored)
```

## Common Commands

```bash
# Start server
hugo server

# Build site
hugo

# Build with minification
hugo --minify

# Build for production
hugo --minify --baseURL "https://oyi77.github.io/ADbS/"
```

## Troubleshooting

**Theme not found:**
```bash
git submodule update --init --recursive
```

**Port already in use:**
```bash
hugo server --port 1314
```

**Changes not showing:**
- Restart Hugo server
- Clear browser cache
- Check for syntax errors in markdown

---

For more details, see [README.md](README.md) or [DEPLOYMENT.md](DEPLOYMENT.md).

