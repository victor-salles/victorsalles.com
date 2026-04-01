#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
hugo --minify >/dev/null
for f in public/en/posts/index.html public/en/projects/index.html public/en/about/index.html \
  public/en/contact/index.html public/en/search/index.html public/en/archives/index.html \
  public/en/index.xml public/archives/index.html; do
  test -f "$f" || { echo "missing $f" >&2; exit 1; }
done
grep -q 'href=/en/index.xml' public/en/index.html || { echo "expected EN home RSS href=/en/index.xml" >&2; exit 1; }
grep -q 'href=/index.xml' public/index.html || { echo "expected PT home RSS href=/index.xml" >&2; exit 1; }
