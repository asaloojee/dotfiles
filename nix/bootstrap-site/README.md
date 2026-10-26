# bootstrap.omnx.sh deployment

Cloudflare Pages publishes the bootstrap script from this public repository.
Native Git integration is the CI/CD pipeline: a qualifying push runs validation
and packaging, and only a successful build becomes a deployment. No GitHub
Actions workflow, deployment token, Worker, or server is needed.

## One-time Cloudflare setup (user-run)

1. Sign in to the Cloudflare account managing `omnx.sh`. Confirm the domain is
   listed and active. Public DNS already pointed at Cloudflare during setup;
   do not change nameservers or recreate the zone just for this subdomain. If
   it is missing from your account, resolve account access before proceeding.
2. After reviewing and publishing these files, go to **Workers & Pages**, create
   a **Pages** application, and choose Git integration (not Direct Upload).
3. Connect GitHub and grant access only to `asaloojee/dotfiles`. Use:

   | Setting | Value |
   | --- | --- |
   | Project name | `omnx-bootstrap` (or another available name) |
   | Production branch | `main` |
   | Framework preset | None |
   | Root directory | Repository root (leave blank) |
   | Build command | `bash nix/bootstrap-site/build.sh` |
   | Build output directory | `nix/bootstrap-site/dist` |
   | Environment variable | `PYTHON_VERSION=3.13` |
   | Environment variable | `SKIP_DEPENDENCY_INSTALL=1` |

   The build creates a temporary Python virtual environment and installs pinned
   `shellcheck-py==0.11.0.1` from PyPI. Pages supplies Python/pip but does not
   guarantee uv or ShellCheck; pip is used only inside that temporary environment.
   No application dependencies, Nix builds, VM installs, or credentials are needed.
4. Let the initial deployment complete and inspect its build log. Test the
   assigned `https://<project>.pages.dev/` URL before attaching the domain.
5. In the Pages project's **Custom domains**, choose **Set up a domain** and
   enter `bootstrap.omnx.sh`. Follow Cloudflare's DNS record confirmation and
   wait for the domain/certificate to become active. This should create a CNAME
   for `bootstrap` pointing to the project's assigned `.pages.dev` hostname.
   Do not change apex, mail, or other DNS records. Add the domain through Pages,
   not by creating a standalone CNAME first.
6. Under the project's build settings, optionally set **Build watch paths** to
   include only:

   ```text
   nix/bootstrap-dev-vm.sh
   nix/bootstrap-site/**
   ```

   Leave exclude patterns empty. If preview builds are unnecessary, disable
   preview branch deployments. Only `main` should publish to the production domain.
   Do not set a cache rule that overrides this site's revalidation headers, or
   enable a browser challenge/Access login on the script endpoint: curl needs
   the actual file, not an HTML login/challenge page.

## What gets published

Only five explicitly generated files go into the deployment directory:

- `/dev-vm.sh`: exact bytes of `nix/bootstrap-dev-vm.sh`.
- `/version.json`: full source commit SHA, script SHA-256, and immutable GitHub link.
- `/`: a minimal download/instructions page; no automatic execution command.
- `/404.html`: disables Pages' SPA fallback; unknown script paths must return 404.
- `/_headers`: Pages configuration for revalidation, content types, and browser
  security headers (consumed by Pages rather than a public download).

The repository root, Nix configuration, generated hardware file, `.git`, and
credentials are never copied into the deployment directory. The bootstrap itself
is public and contains no credentials. Metadata is traceability, not a cryptographic
signature: a checksum served by the same compromised site is not independent proof.

The build fails on Bash syntax errors, ShellCheck findings, failing unit tests,
a source/deployment SHA mismatch, or tracked modifications to deployment sources.
Tests only exercise public-artifact generation and harmless CLI paths. They never
run `install` or `configure` and do not replace a clean-VM end-to-end test.

## Verify the live deployment

After domain activation, run on your Mac:

```sh
curl --fail --show-error https://bootstrap.omnx.sh/version.json
curl --fail --show-error --head https://bootstrap.omnx.sh/dev-vm.sh
curl --silent --output /dev/null --write-out '%{http_code}\n' \
  https://bootstrap.omnx.sh/does-not-exist.sh
```

Expect the deployed commit and checksum, `text/plain` with revalidation headers,
and a **404** for the nonexistent file. Download and inspect before executing:

```sh
curl --fail --show-error --location https://bootstrap.omnx.sh/dev-vm.sh \
  --output /tmp/bootstrap-dev-vm.sh
bash -n /tmp/bootstrap-dev-vm.sh
less /tmp/bootstrap-dev-vm.sh
```

For independent verification, compare the downloaded file against the raw GitHub
file at the commit in `version.json`. A local SHA-256 can also be compared with the
metadata (`shasum -a 256 /tmp/bootstrap-dev-vm.sh` on macOS).

## Updating and rollback

Review, commit, and push the relevant files to `main`. Pages automatically runs
checks and atomically publishes the successful output. Failed builds leave the
previous production deployment active. The domain tracks the latest successfully
deployed script, not necessarily the newest repository commit: unrelated changes
can be excluded by build watch paths. No existing VM updates itself.

To roll back, select a previous successful production deployment in the Pages
project and use its rollback action. Revert the bad source change too, so the next
push does not reintroduce it. Protect the production branch and both accounts;
anyone who can change production code or deployment settings can replace this
privileged installer. No Cloudflare API key belongs in the repository.

For exact reproduction instead of the mutable domain URL, download from GitHub
at a reviewed commit SHA and check out the same SHA for the configure stage.

## Local checks (no deployment)

From the repository root:

```sh
bash -n nix/bootstrap-dev-vm.sh nix/bootstrap-site/build.sh
shellcheck nix/bootstrap-dev-vm.sh nix/bootstrap-site/build.sh
python3 -B -m unittest discover -s nix/bootstrap-site -p 'test_*.py'
```

ShellCheck must be installed for that check. Do not run `build.sh` unless you want
it to install its isolated lint dependency and prepare deployment artifacts. It
never runs the installer. Existing `dist/` output must be removed deliberately
before packaging again; packaging refuses to overwrite a potentially stale tree.

References: [Git integration](https://developers.cloudflare.com/pages/get-started/git-integration/),
[custom domains](https://developers.cloudflare.com/pages/configuration/custom-domains/),
[build image](https://developers.cloudflare.com/pages/configuration/build-image/),
[build watch paths](https://developers.cloudflare.com/pages/configuration/build-watch-paths/),
and [headers](https://developers.cloudflare.com/pages/configuration/headers/).
