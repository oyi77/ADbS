# ADbS Documentation Site

This directory contains the Hugo static site generator configuration and content for the ADbS GitHub Pages site.

## Prerequisites

Install Hugo Extended (required for this theme):

- **macOS**: `brew install hugo`
- **Linux**: Download from [Hugo releases](https://github.com/gohugoio/hugo/releases)
- **Windows**: Download from [Hugo releases](https://github.com/gohugoio/hugo/releases) or use `choco install hugo-extended`

Verify installation:
```bash
hugo version
# Should show: hugo v0.x.x+extended
```

## Local Development

1. **Initialize theme** (first time only, or if submodule not initialized):
   ```bash
   cd docs-site
   git submodule update --init --recursive
   ```

2. **Start the development server**:
   ```bash
   hugo server
   ```

3. **View the site**:
   Open http://localhost:1313 in your browser

4. **Build for production**:
   ```bash
   hugo --minify
   ```

## Directory Structure

```
docs-site/
├── config.yaml          # Hugo configuration
├── content/             # Markdown content files
│   ├── _index.md       # Homepage
│   ├── installation.md
│   ├── usage.md
│   ├── demo.md
│   ├── contributing.md
│   └── docs/           # Documentation section
├── themes/              # Hugo themes (PaperMod)
├── static/              # Static assets (images, CSS, etc.)
└── public/             # Generated site (gitignored)
```

## Adding Content

- Create new `.md` files in `content/` directory
- Use front matter (YAML) at the top of each file for metadata
- Content is written in Markdown
- Code blocks are automatically highlighted

## Deployment

The site is automatically deployed via GitHub Actions when changes are pushed to the `main` branch. See `.github/workflows/pages.yml` for the workflow configuration.

## Theme

This site uses the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, a fast, clean, and responsive Hugo theme.

