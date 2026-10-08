<h1 align="center">logcli-shortcuts</h1>

<p align="center">
  Query Grafana Loki from your terminal instead of the UI — and hand it to a coding agent for<br/>
  natural-language log search while troubleshooting. A one-command installer for
  <code>logcli</code>, plus two small shell functions for tailing and grepping logs.
</p>

---

## Why

Loki's web UI is fine for exploring, but once you know what you're looking for, round-tripping
through a browser for every query is slow. `logcli` gets you there from the terminal — this repo
is the install step plus two tiny ergonomic wrappers (`lt` for tailing, `lg` for grepping) so you
don't retype `logcli query '{...}' --since=... --follow` every time.

It's intentionally *not* tied to any particular label schema. `lt`/`lg` take a raw
[LogQL selector](https://grafana.com/docs/loki/latest/query/log_queries/) string, because label
names (`namespace`, `service_name`, `app`, `job`, whatever) are entirely deployment-specific. You
wire up your own one-word shortcuts for your own labels on top — see
[Layering your own shortcuts](#layering-your-own-shortcuts) below.

## Use it with a coding agent

This is the real reason to have `logcli`/`lt`/`lg` on your `PATH` rather than only using the
Grafana UI: a coding agent with shell access (Claude Code, etc.) can query your logs directly as
part of troubleshooting. Ask it something like "check the api service's logs for the last hour
for anything related to this timeout" and it runs `lg`/`logcli` itself, reads the actual log
lines, and reasons about them alongside your code — instead of you tabbing over to Grafana,
copying log lines, and pasting them back in. Natural language in, real log context out, no
context-switch.

---

## Quick install

The only thing you need from your devops/infra team is your **Loki server's URL** (to set as
`LOKI_ADDR`) — everything else below is self-serve.

**Windows (PowerShell):** paste this in a PowerShell window:

```powershell
irm https://raw.githubusercontent.com/thisismairaj/logcli-shortcuts/master/install.ps1 | iex
```

It installs `logcli` to `~\bin`, adds that to your `PATH`, optionally sets `LOKI_ADDR`, and adds
the `lt`/`lg` functions to whichever PowerShell profile(s) you have (5.1 and/or 7). Safe to re-run
— it skips anything already done. **Open a new terminal afterward** — PATH/env var changes don't
apply to the one you ran it in.

**macOS/Linux (bash/zsh):**

```bash
curl -fsSL https://raw.githubusercontent.com/thisismairaj/logcli-shortcuts/master/install.sh | bash
```

Installs `logcli` via Homebrew (or tells you where to grab the binary if you don't have `brew`),
optionally sets `LOKI_ADDR`, and appends the `lt`/`lg` functions to `~/.bashrc` and `~/.zshrc`.

Test with: `logcli labels --since=24h`

---

## Usage

```bash
lt '<selector>' [since]           # tail: live-follow a selector, default since=5m
lg '<term>' '<selector>' [since]  # grep: search a selector for a term, default since=1h
```

```bash
lt '{namespace="backend-dev", service_name="api"}'
lt '{namespace="backend-dev", service_name="api"}' 15m

lg "error" '{namespace="backend-dev"}'
lg "timeout" '{namespace="backend-dev", service_name="worker"}' 6h
```

Both are thin wrappers around `logcli query` — anything `logcli` itself supports (`--limit`,
`--output`, etc.) works by passing it straight to `logcli query` yourself when `lt`/`lg` aren't
enough.

---

## Layering your own shortcuts

`lt`/`lg` are deliberately generic. If you query the same two or three services constantly, wrap
them in your own one-word functions, in your own shell config:

```powershell
# PowerShell profile
function adt { lt '{namespace="myorg-backend-dev", service_name="myorg-api"}' }
function ast { lt '{namespace="myorg-backend-stag", service_name="myorg-api"}' }
```

```bash
# ~/.zshrc / ~/.bashrc
adt() { lt '{namespace="myorg-backend-dev", service_name="myorg-api"}'; }
ast() { lt '{namespace="myorg-backend-stag", service_name="myorg-api"}'; }
```

---

## Uninstall

Remove the `# >>> logcli-shortcuts >>> ... # <<< logcli-shortcuts <<<` block from your shell
profile(s), and delete `~\bin\logcli.exe` (Windows) or `brew uninstall logcli` (macOS).

---

## License

MIT
