#!/usr/bin/env bash
# Sets up a Mac to use the Ollama server at 192.168.0.249 (qwen3.5:9b).
# Safe to re-run.
set -euo pipefail

SERVER="${OLLAMA_SERVER:-http://192.168.0.249:11434}"
MODEL="qwen3.5:9b"
BIG_MODEL="qwen3.5-16k"   # same weights, 16k context by default
ZSHRC="$HOME/.zshrc"

echo "==> Checking the server at $SERVER"
if ! curl -fsS -m 5 "$SERVER/api/tags" > /dev/null; then
  echo "Cannot reach $SERVER. Check that you're on the same network and the server is up." >&2
  exit 1
fi

echo "==> Checking for the Ollama CLI"
if ! command -v ollama > /dev/null; then
  if command -v brew > /dev/null; then
    brew install ollama
  else
    echo "Ollama CLI not found and Homebrew isn't installed." >&2
    echo "Install the CLI from https://ollama.com/download and re-run this script." >&2
    exit 1
  fi
fi

echo "==> Pointing the CLI at the server (~/.zshrc)"
LINE="export OLLAMA_HOST=$SERVER"
if grep -qs '^export OLLAMA_HOST=' "$ZSHRC"; then
  # Replace an existing line (BSD sed syntax for macOS).
  sed -i '' "s|^export OLLAMA_HOST=.*|$LINE|" "$ZSHRC"
else
  printf '\n# Remote Ollama server\n%s\n' "$LINE" >> "$ZSHRC"
fi
export OLLAMA_HOST="$SERVER"

echo "==> Creating $BIG_MODEL (16k context) on the server"
if ! ollama list | grep -q "^$BIG_MODEL"; then
  tmp="$(mktemp)"
  printf 'FROM %s\nPARAMETER num_ctx 16384\n' "$MODEL" > "$tmp"
  ollama create "$BIG_MODEL" -f "$tmp"
  rm -f "$tmp"
fi

echo "==> Smoke test"
curl -fsS "$SERVER/api/generate" -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"Reply with the single word: ready\",
  \"stream\": false,
  \"think\": false
}" | python3 -c 'import sys,json; print(json.load(sys.stdin)["response"].strip())'

cat <<EOF

Done. Open a new terminal (or run: source ~/.zshrc), then:

  ollama run $BIG_MODEL        # chat with 16k context
  ollama run $MODEL            # default 4k context

For editors and other tools use:
  Base URL: $SERVER/v1   API key: ollama   Model: $MODEL
EOF
