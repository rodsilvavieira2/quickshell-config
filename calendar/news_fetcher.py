#!/usr/bin/env python3
"""
Hacker News top stories fetcher for the Quickshell calendar module.
Uses only Python stdlib — no third-party dependencies required.
Fetches stories in parallel using ThreadPoolExecutor.
"""

import json
import os
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urlparse
from urllib.request import urlopen
from urllib.error import URLError

N_ARTICLES = 20
TIMEOUT = 6  # seconds per request
CACHE_FILE = os.path.expanduser("~/.cache/quickshell/news/news.json")
HN_BASE = "https://hacker-news.firebaseio.com/v0"


def fetch_json(url):
    try:
        with urlopen(url, timeout=TIMEOUT) as r:
            return json.loads(r.read().decode("utf-8"))
    except Exception:
        return None


def get_domain(url):
    if not url:
        return "news.ycombinator.com"
    try:
        host = urlparse(url).hostname or ""
        return host.removeprefix("www.")
    except Exception:
        return ""


def fetch_story(story_id):
    item = fetch_json(f"{HN_BASE}/item/{story_id}.json")
    if not item or item.get("type") != "story":
        return None
    url = item.get("url") or f"https://news.ycombinator.com/item?id={story_id}"
    return {
        "id": story_id,
        "title": item.get("title", ""),
        "url": url,
        "score": item.get("score", 0),
        "comments": item.get("descendants", 0),
        "by": item.get("by", ""),
        "time": item.get("time", 0),
        "domain": get_domain(url),
        "hn_url": f"https://news.ycombinator.com/item?id={story_id}",
    }


def main():
    ids = fetch_json(f"{HN_BASE}/topstories.json")
    if not ids:
        sys.exit(1)

    ids = ids[:N_ARTICLES]

    articles = []
    with ThreadPoolExecutor(max_workers=10) as pool:
        futures = {pool.submit(fetch_story, sid): sid for sid in ids}
        for future in as_completed(futures):
            result = future.result()
            if result:
                articles.append(result)

    # Restore original ranking order from HN
    id_order = {sid: i for i, sid in enumerate(ids)}
    articles.sort(key=lambda a: id_order.get(a["id"], 999))

    output = {
        "articles": articles,
        "fetched_at": int(time.time()),
    }

    os.makedirs(os.path.dirname(CACHE_FILE), exist_ok=True)
    with open(CACHE_FILE, "w") as f:
        json.dump(output, f)


if __name__ == "__main__":
    main()
