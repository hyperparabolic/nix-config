#!/usr/bin/env python3
"""Fetch web pages and emit Markdown.

Thin orchestrator: handles robots.txt, throttling, size/time limits and
error reporting; delegates HTML-to-Markdown conversion to the html2text
package (run as a module to avoid clashing with unrelated `html2text`
binaries). Falls back to raw HTML when html2text is unavailable.

Behavior contract:
- robots.txt is honored per site, including Crawl-delay.
- A throttled response (429/503) is reported verbatim and aborts all
  remaining URLs. This tool never retries automatically.
"""

import argparse
import gzip
import re
import ssl
import subprocess
import sys
import time
import urllib.error
import urllib.robotparser
import urllib.request
from html import unescape
from urllib.parse import urlsplit

USER_AGENT = "pi-fetch/1.0 (automated; honors robots.txt)"
THROTTLE_CODES = {429, 503}
MAX_CRAWL_DELAY = 60  # seconds; longer delays are noted and skipped

_title_re = re.compile(r"<title[^>]*>(.*?)</title>", re.I | re.S)
_desc_re = re.compile(
    r"""<meta[^>]+(?:name|property)=["'](?:description|og:description)["'][^>]*>""",
    re.I,
)
_content_re = re.compile(r"""content=["'](.*?)["']""", re.I | re.S)

_robots_cache: dict = {}


def normalize(url: str) -> str:
    return url if "://" in url else "https://" + url


def robots_for(url):
    """Return a RobotFileParser for url's origin, or None if unreachable."""
    parts = urlsplit(url)
    origin = f"{parts.scheme}://{parts.netloc}"
    if origin in _robots_cache:
        return _robots_cache[origin]
    rp = urllib.robotparser.RobotFileParser()
    try:
        req = urllib.request.Request(
            f"{origin}/robots.txt", headers={"User-Agent": USER_AGENT}
        )
        with urllib.request.urlopen(req, timeout=10) as resp:
            rp.parse(resp.read(256 * 1024).decode("utf-8", "replace").splitlines())
    except urllib.error.HTTPError as e:
        if e.code in (401, 403):
            rp.disallow_all = True
        else:  # 404 and friends: no restrictions published
            rp.allow_all = True
    except Exception as e:
        print(f"note: robots.txt unreachable for {origin} ({e}); continuing",
              file=sys.stderr)
        rp = None
    _robots_cache[origin] = rp
    return rp


def crawl_delay(rp) -> float | None:
    if rp is None:
        return None
    delay = rp.crawl_delay("pi-fetch")
    if delay is None:
        delay = rp.crawl_delay("*")
    return min(float(delay), MAX_CRAWL_DELAY) if delay else None


def fetch(url: str, timeout: int, max_bytes: int):
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml;q=0.9,text/*;q=0.8,*/*;q=0.5",
            "Accept-Encoding": "gzip",
        },
    )
    with urllib.request.urlopen(
        req, timeout=timeout, context=ssl.create_default_context()
    ) as resp:
        final_url = resp.geturl()
        ctype = resp.headers.get("Content-Type", "")
        data = resp.read(max_bytes + 1)
    truncated = len(data) > max_bytes
    data = data[:max_bytes]
    if (resp.headers.get("Content-Encoding") or "").lower() == "gzip":
        try:
            data = gzip.decompress(data)
        except OSError:
            pass
    return final_url, ctype, truncated, data


def to_markdown(data: bytes) -> tuple[str, str | None]:
    """Convert via html2text; returns (markdown, warning-or-None)."""
    proc = subprocess.run(
        [sys.executable, "-m", "html2text", "--body-width=0"],
        input=data,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=30,
        check=False,
    )
    if proc.returncode == 0:
        return proc.stdout.decode("utf-8", "replace"), None
    if b"No module named" in proc.stderr:
        return "", "html2text not installed; emitting raw HTML"
    raise RuntimeError(f"html2text failed: {proc.stderr.decode(errors='replace')[:300]}")


def extract_meta(html_text: str) -> tuple[str, str]:
    title = _title_re.search(html_text)
    desc = _desc_re.search(html_text)
    desc_content = _content_re.search(desc.group(0)) if desc else None
    clean = lambda s: re.sub(r"\s+", " ", unescape(s)).strip()  # noqa: E731
    return (
        clean(title.group(1)) if title else "",
        clean(desc_content.group(1)) if desc_content else "",
    )


def process(url: str, args) -> str:
    rp = robots_for(url)
    if rp is not None and not rp.can_fetch("pi-fetch", url):
        print(f"SKIP  {url}: disallowed by robots.txt", file=sys.stderr)
        return ""
    delay = crawl_delay(rp)
    if delay:
        time.sleep(delay)

    final_url, ctype, truncated, data = fetch(url, args.timeout, args.max_bytes)
    shown_url = f"{url}\n  -> {final_url}" if final_url != url else url
    lines = ["=" * 78, f"URL: {shown_url}",
             f"Status: 200 · type: {ctype or 'unknown'} · bytes: {len(data)}"
             + (" · TRUNCATED (size cap)" if truncated else "")]

    if re.match(r"text/|application/(x?html|json|xml|.*\+xml)", ctype, re.I):
        text = data.decode("utf-8", "replace")
        title, desc = extract_meta(text)
        if title:
            lines.append(f"Title: {title}")
        if desc:
            lines.append(f"Description: {desc}")
        lines.append("")
        if args.raw:
            lines.append(text)
        elif "html" not in ctype.lower():
            lines.append("(non-HTML content emitted as-is)\n" + text)
        else:
            md, warn = to_markdown(data)
            if warn:
                print(f"note: {url}: {warn}", file=sys.stderr)
                lines.append(md or text)
            else:
                lines.append(md)
    else:
        lines += [
            "",
            f"(binary content, {len(data)} bytes — not rendered)",
            "(download deliberately with e.g. curl -fL -o <file>)",
        ]
    return "\n".join(lines)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(
        description="Fetch web pages as Markdown (robots.txt-aware)."
    )
    ap.add_argument("urls", nargs="+", help="one or more URLs")
    ap.add_argument("--raw", action="store_true", help="emit original HTML")
    ap.add_argument("--timeout", type=int, default=20, help="seconds (default 20)")
    ap.add_argument("--max-bytes", type=int, default=2_000_000, help="response cap")
    ap.add_argument("-o", "--output", help="write result to file instead of stdout")
    args = ap.parse_args(argv)

    if args.output and len(args.urls) > 1:
        ap.error("-o/--output requires exactly one URL")

    urls = [normalize(u) for u in args.urls]
    blocks, failures = [], 0
    for url in urls:
        try:
            blocks.append(process(url, args))
        except urllib.error.HTTPError as e:
            failures += 1
            if e.code in THROTTLE_CODES:
                ra = e.headers.get("Retry-After") if e.headers else None
                print(
                    f"THROTTLED {url}: HTTP {e.code} {e.reason}"
                    + (f" (Retry-After: {ra})" if ra else ""),
                    file=sys.stderr,
                )
                print("Not retrying; aborting remaining URLs.", file=sys.stderr)
                return 3
            print(f"ERROR {url}: HTTP {e.code} {e.reason}", file=sys.stderr)
        except Exception as e:
            failures += 1
            print(f"ERROR {url}: {type(e).__name__}: {e}", file=sys.stderr)

    result = "\n\n".join(b for b in blocks if b)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as fh:
            fh.write(result + "\n")
        print(f"wrote {args.output} ({len(result)} chars)", file=sys.stderr)
    elif result:
        print(result)

    return 1 if failures and failures == len(urls) else 0


if __name__ == "__main__":
    sys.exit(main())
