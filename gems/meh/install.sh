#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust/Cargo not found, skipping meh build"
    exit 0
fi

echo "Building meh..."
cargo build --release

DOTFILES_ROOT="$(cd ../.. && pwd)"
ln -sf "$DOTFILES_ROOT/gems/meh/target/release/meh" "$DOTFILES_ROOT/bin/meh"
echo "meh installed to bin/meh"
