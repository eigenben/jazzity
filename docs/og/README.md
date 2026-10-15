# Link preview card

`index.html` renders `public/og.png`, the 1200×630 Open Graph image that
iMessage, Slack, social sites and the like show when a Jazzity link is shared.
The layout points every page's `og:image` at it.

The template takes the logo from `docs/logo` and the ii-V-I from
`docs/screenshots/home.png`, so it must be served with `docs/` as the web root.

## Regenerate

From the repository root:

```bash
python3 -m http.server 8799 --bind 127.0.0.1 --directory docs &
npx --yes playwright screenshot --channel=chrome --viewport-size=1200,630 --wait-for-timeout=1500 http://127.0.0.1:8799/og/index.html public/og.png
kill %1
```

`--channel=chrome` uses the installed Google Chrome, so no Playwright browser
download is needed. Keep the result exactly 1200×630 and under about 300 KB.
