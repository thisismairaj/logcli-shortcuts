# Contributing to logcli-shortcuts

Thanks for considering a contribution — this is a small project, so keep changes focused.

## Before you start

For anything beyond a typo fix, please open an issue first to discuss the change.

## What's here

There's no build step — `install.ps1` and `install.sh` are the whole project. Edit them directly.

## Testing a change

Neither script can be fully tested without a real Loki endpoint, but you can verify the parts
that matter without one:

- **Idempotency**: run the installer twice and confirm the second run reports "already
  installed"/"already has logcli shortcuts" rather than duplicating anything.
- **Quoting logic**: if you touch the `lt`/`lg` functions, verify the query string they build is
  correct for both PowerShell 7 and PowerShell 5.1 (the `-replace '"', '\"'` branch) — this
  repo's entire reason to exist is getting that escaping right, so a change here needs to be
  checked carefully, e.g. by swapping the final `& logcli.exe query ...` line for a `Write-Output`
  of the same string and inspecting it.
- Where possible, actually run the installer against a real Loki endpoint end to end.

## Submitting

1. Fork the repo and create a branch named `your-username/short-description`.
2. Commit with a clear message explaining *why*, not just what changed.
3. Open a pull request against `master` describing the change and linking any related issue.

## Scope

This project is deliberately narrow: `logcli` install + two schema-agnostic shell functions. It's
not meant to grow into a config-file-driven system or support backends other than Loki — see the
README's "Why" section. If you want something broader, it's probably a different project.
