# victorsalles.com — Setup Guide

## Local Development

```bash
# 1. Clone the repo (after creating it on GitHub)
git clone git@github.com:victor-salles/victorsalles.com.git
cd victorsalles.com

# 2. Install Hugo (macOS)
brew install hugo

# 3. Add the theme as a git submodule
git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod

# 4. Run the dev server
hugo server -D

# Site is now live at http://localhost:1313/
```

## Deployment (GitHub Pages)

Deployment is automatic via GitHub Actions on every push to `main`.

### One-time DNS setup (Namecheap):

1. Go to Namecheap → Domain List → victorsalles.com → Manage → Advanced DNS
2. Remove any existing A records or CNAME records
3. Add these records:

| Type  | Host | Value                     | TTL       |
|-------|------|---------------------------|-----------|
| A     | @    | 185.199.108.153           | Automatic |
| A     | @    | 185.199.109.153           | Automatic |
| A     | @    | 185.199.110.153           | Automatic |
| A     | @    | 185.199.111.153           | Automatic |
| CNAME | www  | victor-salles.github.io.  | Automatic |

4. In GitHub repo → Settings → Pages:
   - Source: GitHub Actions
   - Custom domain: victorsalles.com
   - Check "Enforce HTTPS"

DNS propagation takes 10-30 minutes.

## Adding a New Blog Post

```bash
hugo new posts/my-new-post.md
# Edit content/posts/my-new-post.md
# Push to main — auto-deploys
```

## Adding a New Project

Create a new file in `content/projects/` following the existing format.
