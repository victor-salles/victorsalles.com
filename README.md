# victorsalles.com

Personal website and blog. Built with [Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, deployed to [GitHub Pages](https://pages.github.com/).

## Local development

```bash
# Install Hugo (macOS)
brew install hugo

# Clone with submodules
git clone --recurse-submodules git@github.com:victor-salles/victorsalles.com.git
cd victorsalles.com

# Run the dev server (includes drafts)
hugo server -D
```

The site will be available at `http://localhost:1313/`.

## Deployment

Pushes to `main` trigger a GitHub Actions workflow that builds and deploys to GitHub Pages automatically.

## Structure

```
content/
├── about.md              # About page
├── contact.md            # Contact links
├── posts/                # Blog posts
└── projects/             # Project showcase pages
static/
└── CNAME                 # Custom domain config
.github/workflows/
└── deploy.yml            # CI/CD pipeline
```

## License

Content is copyright Victor Salles. The site source code is available for reference but not for redistribution.
