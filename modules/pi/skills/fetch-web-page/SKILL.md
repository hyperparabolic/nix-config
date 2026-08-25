---
name: fetch-web-page
description: Fetch web pages over HTTP(S) and convert them to readable Markdown. Use whenever you need to read, open, summarize, quote, fact-check, or extract content from a URL or web page. Honors robots.txt, never retries throttled requests, caps size and time. Requires python3; uses the html2text package for conversion and falls back to raw HTML without it.
compatibility: python3 (stdlib) plus the html2text Python module; Alpine guests get it via the py3-html2text rootfs package.
---

# Fetch Web Page

Fetches URLs sequentially, converts HTML to Markdown via `html2text`, strips
nothing you'd want to quote. robots.txt is checked automatically per site.

## Usage

```bash
./scripts/fetch_page.py <url> [url ...]   # converted Markdown to stdout
./scripts/fetch_page.py <url> -o /tmp/p.md  # save large pages to a file
./scripts/fetch_page.py <url> --raw       # original HTML instead of Markdown
./scripts/fetch_page.py <url> --timeout 30 --max-bytes 10000000
```

Batch multiple URLs in one invocation — requests are sequential and honor
each site's Crawl-delay.

## Rules

- **robots.txt is authoritative.** If a fetch is skipped as disallowed, do
  not work around it — no UA spoofing, no curl end-run.
- **Throttling (HTTP 429/503) aborts the run** with the exact status and
  `Retry-After` on stderr. Never retry, never switch tools to dodge it;
  report the error verbatim to the user and stop.
- Prefer `-o <file>` for big pages, then read the file selectively instead of
  flooding context.
- JS-rendered SPAs return little text. Check `--raw` for `__NEXT_DATA__`,
  embedded JSON APIs, or try `/rss`, `/feed`, `sitemap.xml`.
- Egress may be TLS-intercepted/proxied. Never send credentials through this.

## Out of scope

Use curl directly for: response headers/status checks (`curl -sIL <url>`),
binary downloads (`curl -fL -o <file>`), authenticated or API POST requests.
