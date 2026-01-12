# Deployment Guide

This guide explains how the ADbS documentation site is deployed to GitHub Pages.

## Automatic Deployment

The site is automatically deployed via GitHub Actions when you push to the `main` branch.

### How It Works

1. **Trigger**: Push to `main` branch
2. **Build**: GitHub Actions runs `.github/workflows/pages.yml`
3. **Deploy**: Built site is deployed to GitHub Pages

### Workflow Steps

1. Checkout repository with submodules
2. Setup Hugo Extended
3. Install PaperMod theme (if needed)
4. Build Hugo site
5. Deploy to GitHub Pages

## Manual Deployment

If you need to deploy manually:

```bash
cd docs-site
hugo --minify
# Then push the public/ directory to gh-pages branch
```

## GitHub Pages Configuration

### Initial Setup

1. Go to repository **Settings** → **Pages**
2. Under **Source**, select **GitHub Actions**
3. The workflow will automatically deploy on the next push to `main`

### Custom Domain (Optional)

If you want to use a custom domain:

1. Add `CNAME` file to `docs-site/static/` with your domain
2. Configure DNS settings as per GitHub Pages documentation
3. Update `baseURL` in `docs-site/config.yaml`

## Troubleshooting

### Build Fails

- Check GitHub Actions logs for errors
- Ensure Hugo Extended is used (not regular Hugo)
- Verify theme submodule is initialized

### Theme Not Found

```bash
cd docs-site
git submodule update --init --recursive
```

### Site Not Updating

- Check GitHub Actions workflow status
- Verify Pages source is set to "GitHub Actions"
- Clear browser cache

## Local Testing

Before pushing, test locally:

```bash
cd docs-site
hugo server
```

Visit http://localhost:1313 to preview.

## Site URL

The site will be available at:
- **GitHub Pages**: `https://oyi77.github.io/ADbS/`
- **Custom domain**: (if configured)

---

For issues, see the [GitHub Actions workflow](.github/workflows/pages.yml) or open an issue.

