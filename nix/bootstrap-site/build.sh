#!/usr/bin/env bash
# Cloudflare Pages build command, run from the repository root.
set -euo pipefail

site_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
repo_dir=$(git -C "$site_dir" rev-parse --show-toplevel)

# Pages provides Python/pip, but does not guarantee ShellCheck or uv.
# Keep the pinned lint dependency isolated; install nothing in the checkout.
tools_dir=$(mktemp -d)
trap 'rm -rf -- "$tools_dir"' EXIT
python3 -m venv "$tools_dir/venv"
"$tools_dir/venv/bin/python" -m pip install --disable-pip-version-check \
  --only-binary=:all: 'shellcheck-py==0.11.0.1'

bash -n "$repo_dir/nix/bootstrap-dev-vm.sh"
bash -n "$site_dir/build.sh"
"$tools_dir/venv/bin/shellcheck" "$repo_dir/nix/bootstrap-dev-vm.sh" "$site_dir/build.sh"
python3 -B -m unittest discover -s "$site_dir" -p 'test_*.py'
python3 -B "$site_dir/publish.py"
