#!/usr/bin/env python3
"""
probe.py — SearXNG engine/provider probe (stdlib only)

Probes a running SearXNG instance engine-by-engine and reports which ones
actually return results. Use it to decide how to configure `core-config/settings.yml`.

  python3 probe.py                        # probe all enabled engines with default query
  python3 probe.py --query "python 3.12"  # custom query
  python3 probe.py --url http://localhost:8080 --verbose
  python3 probe.py --list-engines         # only list enabled engines from settings.yml
  python3 probe.py --engines google,bing,startpage,wikipedia  # probe specific engines

No third-party deps — only stdlib (urllib, json, argparse, re, concurrent.futures).
Exit codes: 0 = at least one engine returned results, 2 = instance unreachable,
            1 = reachable but zero engines returned results.

SearXNG API: GET /search?q=...&format=json[&engines=...][&categories=...]
See https://docs.searxng.org/user/search_api.html
"""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# Helpers: settings.yml parsing (no yaml dep — regex only)
# ---------------------------------------------------------------------------

DEFAULT_SETTINGS = Path(__file__).parent / "core-config" / "settings.yml"
FALLBACK_SETTINGS = Path("/etc/searxng/settings.yml")

# Candidate web-search engines worth probing even if disabled (to suggest enabling)
CANDIDATE_WEB_ENGINES = [
    "google",
    "bing",
    "brave",
    "braveapi",
    "mojeek",
    "qwant",
    "duckduckgo",
    "presearch",
    "yep",
    "mwmbl",
    "yandex",
    "startpage",
    "naver",
    "seznam",
]


def parse_settings_yml(path: Path) -> list[dict[str, Any]] | None:
    """Return list[dict] of {name, engine, categories, shortcut, disabled, inactive}."""
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8", errors="replace")
    # isolate engines: section
    if "engines:" not in text:
        return None
    eng_section = text.split("engines:", 1)[1]
    # cut off next top-level key (e.g. plugins:, ui:, outgoing:) is tricky;
    # instead split on "\n  - name:" which is unique to engine entries.
    # Prepend newline to simplify first entry.
    blocks = re.split(r"\n\s*- name:", eng_section)
    engines = []
    for block in blocks[1:]:
        name = block.split("\n", 1)[0].strip()
        # strip possible quotes
        name = name.strip("\"'")
        eng_m = re.search(r"^\s*engine:\s*(\S+)", block, re.M)
        cat_m = re.search(r"^\s*categories:\s*(.+)", block, re.M)
        sc_m = re.search(r"^\s*shortcut:\s*(\S+)", block, re.M)
        time_m = re.search(r"^\s*timeout:\s*([0-9.]+)", block, re.M)
        eng = eng_m.group(1).strip() if eng_m else ""
        cats_raw = cat_m.group(1).strip() if cat_m else ""
        shortcut = sc_m.group(1).strip("\"'") if sc_m else ""
        timeout = float(time_m.group(1)) if time_m else None
        disabled = "disabled: true" in block
        inactive = "inactive: true" in block
        # normalise categories
        if not cat_m:
            cats = ["general"]  # SearXNG default
            cats_raw_display = "(implicit general)"
        else:
            # parse like [general, web] or general or "science"
            cats_raw_display = cats_raw
            cats = [
                c.strip(" []\"'")
                for c in re.split(r"[\,\s]+", cats_raw)
                if c.strip(" []\"'")
            ]
            if not cats:
                cats = ["general"]
        engines.append(
            {
                "name": name,
                "engine": eng,
                "categories": cats,
                "categories_raw": cats_raw_display,
                "shortcut": shortcut,
                "timeout": timeout,
                "disabled": disabled,
                "inactive": inactive,
                "enabled": not disabled and not inactive,
            }
        )
    return engines


def find_settings() -> Path | None:
    for p in [
        DEFAULT_SETTINGS,
        FALLBACK_SETTINGS,
        Path("core-config/settings.yml"),
        Path("./settings.yml"),
    ]:
        if p.exists():
            return p
    return None


# ---------------------------------------------------------------------------
# HTTP helpers (stdlib only)
# ---------------------------------------------------------------------------


def fetch_json(
    url: str,
    timeout: float,
    headers: dict[str, Any] | None = None,
    verbose: bool = False,
) -> tuple[int | None, dict[str, Any] | str, float]:
    """GET url, expect JSON. Returns (status, parsed_json_or_error_string, elapsed_s)."""
    t0 = time.monotonic()
    req = urllib.request.Request(url, headers=headers or {})
    # SearXNG sometimes blocks empty UA
    if "User-Agent" not in req.headers:
        req.add_header(
            "User-Agent", "searxng-probe/1.0 (+https://github.com/searxng/searxng)"
        )
    req.add_header("Accept", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            status = resp.status
            body = resp.read()
            elapsed = time.monotonic() - t0
            ctype = resp.headers.get("Content-Type", "")
            if verbose:
                print(
                    f"  DEBUG status={status} ctype={ctype} bytes={len(body)}",
                    file=sys.stderr,
                )
            # try JSON even if ctype is wrong
            try:
                data = json.loads(body.decode("utf-8", errors="replace"))
                return status, data, elapsed
            except json.JSONDecodeError as e:
                # SearXNG may return HTML on error
                snippet = body[:800].decode("utf-8", errors="replace")
                return status, f"non-JSON response ({e}): {snippet[:400]!r}", elapsed
    except urllib.error.HTTPError as e:
        elapsed = time.monotonic() - t0
        try:
            body = e.read().decode("utf-8", errors="replace")[:600]
        except Exception:
            body = str(e)
        return e.code, f"HTTPError {e.code} {e.reason}: {body[:400]!r}", elapsed
    except urllib.error.URLError as e:
        elapsed = time.monotonic() - t0
        return None, f"URLError: {e.reason}", elapsed
    except TimeoutError as e:
        elapsed = time.monotonic() - t0
        return None, f"Timeout after {timeout}s: {e}", elapsed
    except Exception as e:
        elapsed = time.monotonic() - t0
        return None, f"{type(e).__name__}: {e}", elapsed


def check_instance(
    base_url: str, timeout: float, verbose: bool = False
) -> tuple[bool, str]:
    """Check if SearXNG is reachable. Try /healthz then /."""
    base = base_url.rstrip("/")
    for path in ["/healthz", "/config", "/"]:
        url = base + path
        headers = {"User-Agent": "searxng-probe/1.0"}
        t0 = time.monotonic()
        req = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                elapsed = time.monotonic() - t0
                if verbose:
                    print(
                        f"  health {path} -> {resp.status} in {elapsed:.2f}s",
                        file=sys.stderr,
                    )
                return True, f"{path} -> HTTP {resp.status} ({elapsed:.2f}s)"
        except Exception as e:
            if verbose:
                print(f"  health {path} -> {e}", file=sys.stderr)
            continue
    return False, "no health endpoint responded"


# ---------------------------------------------------------------------------
# Probing logic
# ---------------------------------------------------------------------------


def build_search_url(
    base_url: str,
    query: str,
    engine: str | None = None,
    category: str | None = None,
    fmt: str = "json",
) -> str:
    base = base_url.rstrip("/")
    params = {"q": query, "format": fmt}
    if engine:
        params["engines"] = (
            engine  # SearXNG uses 'engines' (plural); some forks use 'engine'
        )
    if category:
        params["categories"] = category
    # SearXNG requires categories or engines; query alone hits general
    return base + "/search?" + urllib.parse.urlencode(params)


def classify_result(
    status: int | None, data: dict[str, Any] | str, elapsed: float
) -> tuple[str, int, str]:
    """
    Returns (STATUS_LABEL, result_count, note).
    STATUS_LABEL: OK | EMPTY | BLOCKED | RATE_LIMITED | ERROR | TIMEOUT
    """
    if status is None:
        msg = str(data)
        if "Timeout" in msg or "timed out" in msg.lower():
            return "TIMEOUT", 0, msg[:180]
        if "refused" in msg.lower() or "URLError" in msg:
            return "ERROR", 0, msg[:180]
        return "ERROR", 0, msg[:180]

    if status == 429:
        return "RATE_LIMITED", 0, str(data)[:180]
    if status in (402, 403):
        return "BLOCKED", 0, str(data)[:180]
    if status >= 400:
        return "ERROR", 0, f"HTTP {status}: {str(data)[:180]}"

    # status 200
    if isinstance(data, str):
        return "ERROR", 0, data[:180]

    # SearXNG JSON shape: { query, number_of_results, results: [...], unresponsive_engines: [...] }
    results = data.get("results") if isinstance(data, dict) else None
    n = len(results) if isinstance(results, list) else 0
    # also check number_of_results
    num = data.get("number_of_results", n) if isinstance(data, dict) else n

    unresponsive = (
        data.get("unresponsive_engines", []) if isinstance(data, dict) else []
    )
    infoboxes = data.get("infoboxes", []) if isinstance(data, dict) else []
    answers = data.get("answers", []) if isinstance(data, dict) else []

    # total usable = results + infoboxes + answers (some engines only populate infobox)
    total = (
        n
        + (len(infoboxes) if isinstance(infoboxes, list) else 0)
        + (len(answers) if isinstance(answers, list) else 0)
    )

    if total > 0:
        # check if this engine is in unresponsive list (means it errored but others succeeded)
        # when probing single engine, unresponsive non-empty + zero results => blocked
        return (
            "OK",
            total,
            f"{n} results"
            + (f" +{len(infoboxes)} infobox" if infoboxes else "")
            + (f", unresponsive={unresponsive}" if unresponsive else ""),
        )

    # zero results but 200 — could be blocked/captcha or genuinely no results
    if unresponsive:
        # SearXNG explicitly says engine failed
        detail = (
            ", ".join(
                f"{e[0] if isinstance(e, (list, tuple)) and e else e}:{(e[1] if isinstance(e, (list, tuple)) and len(e) > 1 else '')}"
                for e in unresponsive[:3]
            )
            if unresponsive
            else ""
        )
        low = detail.lower()
        if any(
            k in low
            for k in (
                "captcha",
                "cloudflare",
                "access denied",
                "403",
                "429",
                "too many",
            )
        ):
            if "captcha" in low or "cloudflare" in low:
                return "BLOCKED", 0, f"engine error: {detail[:160]}"
            if "429" in low or "too many" in low:
                return "RATE_LIMITED", 0, f"engine error: {detail[:160]}"
            return "BLOCKED", 0, f"engine error: {detail[:160]}"
        return (
            "EMPTY",
            0,
            f"unresponsive: {detail[:160]}" if detail else "no results (unresponsive)",
        )

    return "EMPTY", 0, "no results returned (may be blocked or no match for query)"


def probe_engine(
    base_url: str, query: str, engine_name: str, timeout: float, verbose: bool = False
) -> dict[str, Any]:
    """Probe a single engine. Returns dict with keys: engine, status, count, elapsed, note, url."""
    url = build_search_url(base_url, query, engine=engine_name)
    if verbose:
        print(f"  probing {engine_name} -> {url}", file=sys.stderr)
    status, data, elapsed = fetch_json(url, timeout=timeout, verbose=verbose)
    label, count, note = classify_result(status, data, elapsed)
    # fallback: some SearXNG builds use `engine=` singular; retry once if we got 0 and no error detail
    if label in ("EMPTY", "ERROR") and "engines" in url:
        # only retry on EMPTY with no unresponsive detail — might be param ignored
        if (
            isinstance(data, dict)
            and not data.get("unresponsive_engines")
            and count == 0
            and status == 200
        ):
            alt_url = url.replace("engines=", "engine=")
            if verbose:
                print(
                    f"  retry {engine_name} with engine= -> {alt_url}", file=sys.stderr
                )
            s2, d2, e2 = fetch_json(alt_url, timeout=timeout, verbose=verbose)
            l2, c2, n2 = classify_result(s2, d2, e2)
            if c2 > count:
                return {
                    "engine": engine_name,
                    "status": l2,
                    "count": c2,
                    "elapsed": e2,
                    "note": n2,
                    "url": alt_url,
                    "http": s2,
                }
    return {
        "engine": engine_name,
        "status": label,
        "count": count,
        "elapsed": elapsed,
        "note": note,
        "url": url,
        "http": status,
    }


# ---------------------------------------------------------------------------
# Output formatting
# ---------------------------------------------------------------------------

USE_COLOR = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def color(s: str, code: str) -> str:
    return f"\x1b[{code}m{s}\x1b[0m" if USE_COLOR else s


STATUS_COLOR = {
    "OK": "32",  # green
    "EMPTY": "33",  # yellow
    "BLOCKED": "31",  # red
    "RATE_LIMITED": "35",  # magenta
    "ERROR": "31",
    "TIMEOUT": "31",
}
STATUS_ICON = {
    "OK": "✓",
    "EMPTY": "○",
    "BLOCKED": "✗",
    "RATE_LIMITED": "◷",
    "ERROR": "✗",
    "TIMEOUT": "◷",
}


def print_table(rows: list[dict[str, Any]], show_url: bool = False):
    # sort: OK first, then EMPTY, then rest
    order = {
        "OK": 0,
        "EMPTY": 1,
        "RATE_LIMITED": 2,
        "BLOCKED": 3,
        "ERROR": 4,
        "TIMEOUT": 5,
    }
    rows = sorted(
        rows, key=lambda r: (order.get(r["status"], 9), -r["count"], r["engine"])
    )

    # column widths
    w_engine = max(len(r["engine"]) for r in rows) if rows else 6
    w_engine = max(w_engine, 6)
    w_status = 12
    w_count = 7
    w_time = 7

    header = f"{'ENGINE':<{w_engine}}  {'STATUS':<{w_status}}  {'RESULTS':>{w_count}}  {'TIME':>{w_time}}  NOTE"
    print(header)
    print("-" * len(header))
    for r in rows:
        st = r["status"]
        icon = STATUS_ICON.get(st, "?")
        st_disp = color(f"{icon} {st}", STATUS_COLOR.get(st, "0"))
        # pad status without color length: use visible len
        # simple: print without aligning color precisely
        note = r["note"][:90]
        time_s = (
            f"{r['elapsed']:.2f}s" if r["elapsed"] < 100 else f"{r['elapsed']:.1f}s"
        )
        # manual alignment for colored status: pad after stripping
        print(
            f"{r['engine']:<{w_engine}}  {st_disp:<{w_status + 9 if USE_COLOR else w_status}}  {r['count']:>{w_count}}  {time_s:>{w_time}}  {note}"
        )
        if show_url:
            print(f"  {'':<{w_engine}}  URL: {r['url']}")

    print("-" * len(header))


def print_recommendation(
    rows: list[dict[str, Any]],
    settings_path: Path | None,
    all_engines: list[dict[str, Any]] | None,
):
    ok = [r for r in rows if r["status"] == "OK"]
    empty = [r for r in rows if r["status"] == "EMPTY"]
    blocked = [
        r
        for r in rows
        if r["status"] in ("BLOCKED", "RATE_LIMITED", "ERROR", "TIMEOUT")
    ]

    print()
    print("SUMMARY")
    print(
        f"  OK: {len(ok)}  EMPTY: {len(empty)}  BLOCKED/ERROR: {len(blocked)}  TOTAL probed: {len(rows)}"
    )

    if ok:
        print()
        print("Working engines (keep these enabled):")
        for r in sorted(ok, key=lambda x: -x["count"]):
            print(f"  - {r['engine']}  ({r['count']} results, {r['elapsed']:.2f}s)")

    if blocked or empty:
        print()
        print("Not returning results (consider disabling or check network/CAPTCHA):")
        for r in blocked + empty:
            print(f"  - {r['engine']}: {r['status']} — {r['note'][:100]}")

    # General advice about web search
    web_ok = [
        r
        for r in ok
        if r["engine"]
        in (
            "google",
            "bing",
            "brave",
            "braveapi",
            "mojeek",
            "qwant",
            "duckduckgo",
            "startpage",
            "yandex",
            "presearch",
        )
    ]
    if not web_ok and ok:
        print()
        print(color("WARNING: No general-purpose web engine returned results.", "33"))
        print(
            "  Your 'general' category may appear empty even though niche engines (wikipedia, arxiv, …) work."
        )
        print(
            "  Try enabling at least one of: google, brave/braveapi, mojeek, qwant, duckduckgo, startpage"
        )
        print(
            "  and re-run: python3 probe.py --engines google,brave,mojeek,qwant,duckduckgo,startpage --verbose"
        )
    elif not ok:
        print()
        print(
            color(
                "All probed engines failed — SearXNG may be blocked, offline, or the query had no matches.",
                "31",
            )
        )
        print(
            "  Try: curl -s 'http://localhost:8080/search?q=test&format=json' | head -c 500"
        )

    if settings_path and all_engines is not None:
        disabled_web = [
            e
            for e in all_engines
            if e["engine"] in CANDIDATE_WEB_ENGINES and not e["enabled"]
        ]
        if disabled_web:
            names = ", ".join(e["name"] + f" ({e['engine']})" for e in disabled_web[:8])
            print()
            print(
                f"Disabled web engines in {settings_path} you could try enabling: {names}"
            )
            print(
                "  Edit settings.yml: remove 'disabled: true' for one engine, restart: ./searxng up  (or docker compose up -d)"
            )


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    ap = argparse.ArgumentParser(
        description="Probe SearXNG engines and report which ones return results (stdlib only).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="examples:\n"
        "  python3 probe.py\n"
        "  python3 probe.py --query 'open source search' --timeout 8\n"
        "  python3 probe.py --url http://localhost:8080 --engines google,bing,wikipedia --verbose\n"
        "  python3 probe.py --list-engines\n"
        "  python3 probe.py --all  # also probe currently-disabled web engines\n",
    )
    ap.add_argument(
        "--url",
        default=os.environ.get("SEARXNG_URL", "http://localhost:8080"),
        help="SearXNG base URL (default: %(default)s or $SEARXNG_URL)",
    )
    ap.add_argument(
        "--query",
        "-q",
        default=os.environ.get("SEARXNG_QUERY", "python programming"),
        help="Search query to probe with (default: %(default)s)",
    )
    ap.add_argument(
        "--timeout",
        type=float,
        default=8.0,
        help="Per-engine HTTP timeout in seconds (default: %(default)s)",
    )
    ap.add_argument(
        "--engines",
        default=None,
        help="Comma-separated engine names to probe (overrides settings.yml). "
        "Use engine short names, e.g. google,bing,wikipedia,startpage",
    )
    ap.add_argument(
        "--category",
        default=None,
        help="Optional category to probe (e.g. general, images, it). Default: probe engines individually.",
    )
    ap.add_argument(
        "--concurrency",
        type=int,
        default=4,
        help="Concurrent requests (default: %(default)s, 1=sequential)",
    )
    ap.add_argument(
        "--verbose", "-v", action="store_true", help="Verbose debug output to stderr"
    )
    ap.add_argument(
        "--show-urls", action="store_true", help="Show probed URL per engine"
    )
    ap.add_argument(
        "--list-engines",
        action="store_true",
        help="List enabled/disabled engines from settings.yml and exit",
    )
    ap.add_argument(
        "--all",
        action="store_true",
        help="Also probe disabled candidate web engines (google, bing, brave, …) to find one to enable",
    )
    ap.add_argument(
        "--json",
        action="store_true",
        dest="json_out",
        help="Output raw JSON instead of table",
    )
    ap.add_argument(
        "--settings", default=None, help="Path to settings.yml (default: auto-detect)"
    )

    args = ap.parse_args()

    settings_path = Path(args.settings) if args.settings else find_settings()
    parsed = parse_settings_yml(settings_path) if settings_path else None

    if args.list_engines:
        if not parsed:
            print(
                f"No settings.yml found (looked for {DEFAULT_SETTINGS} and {FALLBACK_SETTINGS})",
                file=sys.stderr,
            )
            # still try to fetch from live instance
            sys.exit(1)
        enabled = [e for e in parsed if e["enabled"]]
        disabled = [e for e in parsed if not e["enabled"]]
        print(f"Settings: {settings_path}  (total {len(parsed)} engines)")
        print(f"\nENABLED ({len(enabled)}):")
        for e in sorted(enabled, key=lambda x: x["name"].lower()):
            print(
                f"  {e['name']:30} engine={e['engine']:<20} cats={e['categories_raw']:<22} shortcut={e['shortcut']}"
            )
        print(f"\nDISABLED/INACTIVE ({len(disabled)}):")
        for e in sorted(disabled, key=lambda x: x["name"].lower()):
            flag = "disabled" if e["disabled"] else "inactive"
            print(f"  {e['name']:30} engine={e['engine']:<20} [{flag}]")
        sys.exit(0)

    # Determine engine list to probe
    if args.engines:
        probe_list = [e.strip() for e in args.engines.split(",") if e.strip()]
        probe_source = "cli --engines"
    elif parsed:
        probe_list = [e["engine"] for e in parsed if e["enabled"] and e["engine"]]
        # deduplicate engine ids (e.g. lemmy appears 4x under different names)
        seen = set()
        uniq = []
        for en in probe_list:
            if en not in seen:
                seen.add(en)
                uniq.append(en)
        probe_list = uniq
        probe_source = f"{settings_path} (enabled engines)"
        if args.all:
            # add disabled candidate web engines not already in list
            extra = [
                e["engine"]
                for e in parsed
                if not e["enabled"]
                and e["engine"] in CANDIDATE_WEB_ENGINES
                and e["engine"] not in seen
            ]
            if extra:
                probe_list.extend(extra)
                probe_source += " + disabled candidates (--all)"
    else:
        # no settings.yml — use a sensible default web probe
        probe_list = [
            "google",
            "bing",
            "brave",
            "mojeek",
            "qwant",
            "duckduckgo",
            "startpage",
            "wikipedia",
            "arxiv",
        ]
        probe_source = "built-in default (no settings.yml found)"

    base_url = args.url.rstrip("/")
    print(
        f"SearXNG probe  url={base_url}  query={args.query!r}  timeout={args.timeout}s"
    )
    print(f"Engines: {len(probe_list)} from {probe_source}")
    if args.category:
        print(f"Category filter: {args.category}")
    print()

    # Health check
    ok, msg = check_instance(
        base_url, timeout=min(args.timeout, 5), verbose=args.verbose
    )
    if not ok:
        print(color(f"✗ SearXNG not reachable at {base_url}", "31"), file=sys.stderr)
        print(f"  {msg}", file=sys.stderr)
        print(
            f"  Is it running? Try: ./searxng up  or  docker compose up -d",
            file=sys.stderr,
        )
        print(
            f"  Check: curl -i {base_url}/healthz  and  docker compose ps",
            file=sys.stderr,
        )
        sys.exit(2)
    else:
        print(f"Instance reachable: {msg}")

    # Also do a general probe (no engine filter) to see if *anything* works
    print(f"\nProbing general search (no engine filter) ...")
    gen_url = build_search_url(
        base_url, args.query, engine=None, category=args.category or "general"
    )
    g_status, g_data, g_elapsed = fetch_json(
        gen_url, timeout=args.timeout, verbose=args.verbose
    )
    g_label, g_count, g_note = classify_result(g_status, g_data, g_elapsed)
    g_color = STATUS_COLOR.get(g_label, "0")
    print(
        f"  general: {color(g_label, g_color)}  {g_count} results in {g_elapsed:.2f}s — {g_note[:120]}"
    )
    if isinstance(g_data, dict) and g_data.get("unresponsive_engines"):
        print(f"  unresponsive: {g_data['unresponsive_engines'][:5]}")

    print(
        f"\nProbing {len(probe_list)} engines individually (concurrency={args.concurrency}) ..."
    )
    if args.verbose:
        print(f"  query={args.query!r}", file=sys.stderr)

    rows: list[dict] = []
    if args.concurrency > 1 and len(probe_list) > 1:
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.concurrency) as ex:
            futs = {
                ex.submit(
                    probe_engine, base_url, args.query, eng, args.timeout, args.verbose
                ): eng
                for eng in probe_list
            }
            for fut in concurrent.futures.as_completed(futs):
                try:
                    r = fut.result()
                except Exception as e:
                    eng = futs[fut]
                    r = {
                        "engine": eng,
                        "status": "ERROR",
                        "count": 0,
                        "elapsed": 0,
                        "note": f"{type(e).__name__}: {e}",
                        "url": "",
                        "http": None,
                    }
                rows.append(r)
                # live progress
                icon = STATUS_ICON.get(r["status"], "?")
                print(
                    f"  {icon} {r['engine']:<22} {r['status']:<12} {r['count']:>4} results  {r['elapsed']:.2f}s  {r['note'][:70]}"
                )
    else:
        for eng in probe_list:
            r = probe_engine(
                base_url, args.query, eng, args.timeout, verbose=args.verbose
            )
            rows.append(r)
            icon = STATUS_ICON.get(r["status"], "?")
            print(
                f"  {icon} {r['engine']:<22} {r['status']:<12} {r['count']:>4} results  {r['elapsed']:.2f}s  {r['note'][:70]}"
            )

    print()
    if args.json_out:
        print(
            json.dumps(
                {
                    "query": args.query,
                    "base_url": base_url,
                    "general": {"status": g_label, "count": g_count, "note": g_note},
                    "engines": rows,
                },
                indent=2,
            )
        )
    else:
        print_table(rows, show_url=args.show_urls)
        print_recommendation(rows, settings_path, parsed)

    # exit code
    if any(r["status"] == "OK" for r in rows) or g_label == "OK":
        sys.exit(0)
    elif not ok:
        sys.exit(2)
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
