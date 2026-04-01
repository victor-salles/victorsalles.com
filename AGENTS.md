# AGENTS.md

## Cursor Cloud specific instructions

This is a Hugo static site (personal website/blog) using the PaperMod theme. No databases, backend services, Docker, or package managers are involved.

### Prerequisites

- **Hugo v0.146.0 extended** must be installed (matches CI pipeline version in `.github/workflows/deploy.yml`). Install via the `.deb` from [Hugo releases](https://github.com/gohugoio/hugo/releases/tag/v0.146.0).
- **Git submodules** must be initialized for the PaperMod theme: `git submodule update --init --recursive`.

### Running / Building / Testing

- **Dev server:** `hugo server -D` — serves at `http://localhost:1313/` with live reload and draft posts included.
- **Build:** `hugo --minify` — outputs to `public/`.
- **Verification script:** `bash scripts/verify-hugo-i18n.sh` — builds the site and checks that all expected i18n output files exist and RSS links are correct.
- There is no separate lint or test framework; the verification script is the primary automated check.

### Non-obvious notes

- The site is **bilingual** (Portuguese `pt` default, English `en`). Content files use `.pt.md` / `.en.md` suffixes. When adding content, both language variants should be created.
- The `baseURL` in `hugo.toml` is set to `https://victorsalles.com/`; in local dev Hugo automatically overrides this to `localhost:1313`.
- Hugo's live reload handles content/template changes but does **not** pick up changes to `hugo.toml` — restart the dev server after config edits.
