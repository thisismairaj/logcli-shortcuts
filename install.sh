#!/usr/bin/env bash
set -euo pipefail

if ! command -v logcli >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install logcli
  else
    echo "Install logcli manually: https://github.com/grafana/loki/releases (grab the logcli binary for your OS/arch)" >&2
    exit 1
  fi
else
  echo "logcli already installed"
fi

read -rp "Loki address (e.g. https://loki.example.com), or leave blank to set LOKI_ADDR yourself later: " LOKI_ADDR_INPUT

MARKER="# >>> logcli-shortcuts >>>"
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  if ! grep -qF "$MARKER" "$rc" 2>/dev/null; then
    {
      echo ""
      echo "$MARKER"
      if [ -n "$LOKI_ADDR_INPUT" ]; then
        echo "export LOKI_ADDR=\"$LOKI_ADDR_INPUT\""
      fi
      cat <<'EOF'
lt() {
  local selector="$1"; local since="${2:-5m}"
  logcli query "$selector" --since="$since" --follow
}
lg() {
  local term="$1"; local selector="$2"; local since="${3:-1h}"
  logcli query "${selector} |= \"${term}\"" --since="$since"
}
EOF
      echo "# <<< logcli-shortcuts <<<"
    } >> "$rc"
    echo "Added logcli shortcuts to $rc"
  else
    echo "$rc already has logcli shortcuts"
  fi
done

echo
echo "Done. Open a new terminal, then test with: logcli labels --since=24h"
