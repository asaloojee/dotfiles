"""Package an explicit public-file allowlist for Cloudflare Pages; no dependencies."""

import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

SITE = Path(__file__).resolve().parent
REPOSITORY = SITE.parent.parent
OUTPUT = SITE / "dist"

INDEX = b"""<!doctype html>
<html lang="en">
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>omnx development VM bootstrap</title>
<h1>Encrypted NixOS development VM bootstrap</h1>
<p>For an ARM64 NixOS 26.05 UTM guest, not your Mac or an existing installation.</p>
<p><strong>The install stage erases the selected disk.</strong>
Download and inspect the script before running it. Do not pipe it into a shell.</p>
<pre>curl --fail --show-error --location https://bootstrap.omnx.sh/dev-vm.sh --output /tmp/bootstrap-dev-vm.sh
less /tmp/bootstrap-dev-vm.sh</pre>
<p>Follow the <a href="https://github.com/asaloojee/dotfiles/blob/main/nix/README.md">installation guide</a>
for disk verification, installation, configuration, and recovery.</p>
<ul>
<li><a href="/dev-vm.sh">Bootstrap script</a></li>
<li><a href="/version.json">Deployed source revision and script SHA-256</a></li>
</ul>
</html>
"""

HEADERS = b"""/*
  Cache-Control: public, max-age=0, must-revalidate
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
  Content-Security-Policy: default-src 'none'; base-uri 'none'; frame-ancestors 'none'; form-action 'none'

/dev-vm.sh
  Content-Type: text/plain; charset=utf-8

/version.json
  Content-Type: application/json; charset=utf-8
"""


def artifacts(script: bytes, revision: str) -> dict[str, bytes]:
    """Produce only public artifacts, never a recursive copy of the checkout."""
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Expected a full Git commit SHA")
    metadata = {
        "commit": revision,
        "sha256": hashlib.sha256(script).hexdigest(),
        "source": f"https://github.com/asaloojee/dotfiles/blob/{revision}/nix/bootstrap-dev-vm.sh",
    }
    return {
        "dev-vm.sh": script,
        "version.json": (json.dumps(metadata, indent=2) + "\n").encode(),
        "index.html": INDEX,
        # A real 404 avoids Pages' default SPA fallback for missing script URLs.
        "404.html": b"<!doctype html><html lang=\"en\"><title>Not found</title><h1>Not found</h1></html>\n",
        "_headers": HEADERS,
    }


def main() -> None:
    revision = subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=REPOSITORY, text=True
    ).strip()
    deployed_revision = os.environ.get("CF_PAGES_COMMIT_SHA")
    if deployed_revision and deployed_revision != revision:
        raise RuntimeError("Cloudflare revision does not match the checked-out commit")
    # Do not label locally modified source as the clean deployed commit.
    subprocess.run(
        ["git", "diff", "--exit-code", "HEAD", "--", "nix/bootstrap-dev-vm.sh", "nix/bootstrap-site"],
        cwd=REPOSITORY,
        check=True,
    )
    files = artifacts((REPOSITORY / "nix/bootstrap-dev-vm.sh").read_bytes(), revision)
    # Fail rather than publish stale files or clear an unexpected directory.
    OUTPUT.mkdir(exist_ok=False)
    for name, content in files.items():
        (OUTPUT / name).write_bytes(content)
    print(f"Prepared {len(files)} public files from {revision} in {OUTPUT}")


if __name__ == "__main__":
    main()
