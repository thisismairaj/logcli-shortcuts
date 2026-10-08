<h1 align="center">logcli-shortcuts</h1>

<p align="center">
  Query Grafana Loki from your terminal instead of the UI — a one-command installer for<br/>
  <code>logcli</code>, plus two small shell functions for tailing and grepping logs, and the two
  gotchas that actually take time to find.
</p>

---

## Why

Loki's web UI is fine for exploring, but once you know what you're looking for, round-tripping
through a browser for every query is slow. `logcli` gets you there from the terminal — this repo
is the install step plus two tiny ergonomic wrappers (`lt` for tailing, `lg` for grepping) so you
don't retype `logcli query '{...}' --since=... --follow` every time.

It's intentionally Loki-specific, not a generic observability abstraction — and intentionally
*not* tied to any particular label schema. `lt`/`lg` take a raw [LogQL selector](https://grafana.com/docs/loki/latest/query/log_queries/)
string, because label names (`namespace`, `service_name`, `app`, `job`, whatever) are entirely
deployment-specific. You wire up your own one-word shortcuts for your own labels on top — see
[Layering your own shortcuts](#layering-your-own-shortcuts) below.

---

## Quick install

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

## Gotchas

### Windows + VPN split-DNS

`logcli`'s Windows build uses Go's own DNS resolver, which doesn't see a VPN's split-DNS rule the
way Windows' own resolver does (via NRPT — `Get-DnsClientNrptPolicy` shows the rule). This isn't
Loki-specific: it affects most Go-built CLIs run over a split-DNS VPN on Windows.

If `logcli` fails with a DNS lookup error but `Resolve-DnsName <your-loki-host>` succeeds, pin the
hostname in your hosts file (needs admin):

```powershell
Add-Content "$env:windir\System32\drivers\etc\hosts" "`n<ip-from-Resolve-DnsName> <your-loki-host>"
```

If logs stop resolving later, that IP may have rotated — re-run `Resolve-DnsName` and update the
entry.

### PowerShell 5.1 strips embedded quotes

Windows PowerShell 5.1 (`powershell.exe`, the Windows default — check with `$PSVersionTable.PSVersion`)
strips embedded double quotes when invoking a native exe, so a selector like
`'{namespace="x"}'` silently loses its quotes before reaching `logcli`, which then fails to parse
the query. This isn't Loki-specific either — it bites any native exe called from PS 5.1 with
quoted arguments.

`install.ps1`'s `lt`/`lg` already detect PS 5.1 (`$PSVersionTable.PSVersion.Major -lt 7`) and
escape embedded quotes before calling `logcli.exe`, so this is handled for you if you installed
via the script. If you're calling `logcli` directly from PS 5.1 yourself, either switch to
PowerShell 7 (`winget install Microsoft.PowerShell` — plain quoting works there), or escape
manually:

```powershell
logcli query "{namespace=\`"backend-dev\`"}" --since=1h
```

---

## Uninstall

Remove the `# >>> logcli-shortcuts >>> ... # <<< logcli-shortcuts <<<` block from your shell
profile(s), and delete `~\bin\logcli.exe` (Windows) or `brew uninstall logcli` (macOS).

---

## License

MIT
