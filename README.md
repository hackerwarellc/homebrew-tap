# hackerwarellc/homebrew-tap

Homebrew tap for Continuity. One command installs **CLI + MCP** from the published npm packages:

```bash
brew tap hackerwarellc/tap
brew install continuity
```

Requires **Node.js** (`brew install node`). Proprietary license — [app.hackerware.com/pricing](https://app.hackerware.com/pricing).

---

## For users — install step by step

### Step 1: Install Homebrew (skip if you already have it)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions. Confirm:

```bash
brew --version
```

### Step 2: Install Node (if needed)

```bash
brew install node
node --version    # expect v18+
```

### Step 3: Add the Continuity tap (one-time)

```bash
brew tap hackerwarellc/tap
brew trust hackerwarellc/tap
```

**Expected:** no error. Homebrew clones `github.com/hackerwarellc/homebrew-tap`.

> **Note:** Homebrew 4.6+ requires trusting third-party taps before install. If you see  
> `Refusing to load formula ... from untrusted tap`, run `brew trust hackerwarellc/tap`.

### Step 4: Install Continuity

```bash
brew install continuity
```

If you previously installed via **npm global**, Homebrew may fail to link with “already exists”. Fix:

```bash
npm uninstall -g @continuity/cli @continuity/mcp   # optional — remove old npm bins
brew link --overwrite continuity
```

**Expected:** installs `@continuity/cli` + `@continuity/mcp` from npm tarballs; symlinks `continuity`, `continuity-mcp`, and `continuity-setup` into `/opt/homebrew/bin` (Apple Silicon) or `/usr/local/bin` (Intel).

### Step 5: Verify

```bash
$(brew --prefix)/bin/continuity --version
# → 3.9.0 (or current CLI_VERSION in the formula)

which -a continuity
which continuity-mcp

continuity --help
```

**PATH note:** If `~/.local/bin/continuity` or an old npm global install appears first in `which -a`, your shell may still run the wrong binary. Prefer the brew path:

```bash
export PATH="$(brew --prefix)/bin:$PATH"
# or: hash -r && rehash   # refresh shell command cache
```

### Step 6: Initialize in a project

```bash
cd your-project
continuity init
continuity mcp setup          # optional — writes MCP config for detected clients
continuity sync                 # first handoff
```

**MCP-only path:** point your client at the brew-installed server:

```json
{
  "mcpServers": {
    "continuity": {
      "command": "continuity-mcp",
      "env": { "WORKSPACE_ROOT": "/absolute/path/to/your-project" }
    }
  }
}
```

### Step 7: Upgrade later

```bash
brew update
brew upgrade continuity
```

### VS Code extension (separate from brew)

Sidebar UI, auto-capture, graphs → [Continuity Ultimate on the Marketplace](https://marketplace.visualstudio.com/items?itemName=hackerware.continuity-ultimate). Brew installs the **terminal/MCP path** only.

---

## For maintainers — first-time tap setup

The formula source lives in **`continuity-ultimate/homebrew-tap/`** and is mirrored to a standalone GitHub repo.

### Step 1: Publish npm packages (MCP first, then CLI)

Brew installs from the **npm registry**, not the monorepo. Both must be live:

```bash
# One command — MCP → CLI (recommended)
bash scripts/npm-publish-distribution.sh

# Optional: refresh formula after publish
bash scripts/npm-publish-distribution.sh --with-homebrew

# Dry-run both packages
bash scripts/npm-publish-distribution.sh --dry-run
```

Or run individually:

```bash
# MCP — marketplace build + publish (run first)
bash scripts/npm-publish-mcp.sh

# CLI — from continuity-ultimate repo
bash scripts/npm-publish-cli.sh
```

Confirm on registry:

```bash
npm view @continuity/cli version
npm view @continuity/mcp version
```

### Step 2: Refresh the formula from npm

From **`continuity-ultimate` repo root**:

```bash
node scripts/update-homebrew-formula.js
```

**Optional:** pin versions explicitly:

```bash
node scripts/update-homebrew-formula.js --cli 3.5.8 --mcp 3.0.120
```

**Expected:** prints sha256 for both tarballs and updates `homebrew-tap/Formula/continuity.rb`.

### Step 3: Create the GitHub tap repo (one-time)

1. Go to [github.com/new](https://github.com/new)
2. Owner: **hackerwarellc**
3. Repository name: **`homebrew-tap`** (must be exactly this — Homebrew expects `brew tap hackerwarellc/tap` → `github.com/hackerwarellc/homebrew-tap`)
4. Public, empty, no README

Or via CLI:

```bash
gh repo create hackerwarellc/homebrew-tap --public --description "Homebrew tap: brew install continuity"
```

### Step 4: Push the tap contents

```bash
# Clone the empty tap repo
git clone https://github.com/hackerwarellc/homebrew-tap.git /tmp/homebrew-tap
cd /tmp/homebrew-tap

# Copy formula + README from continuity-ultimate
cp -R /Users/mac-attack/DEV/continuity-ultimate/homebrew-tap/* .

git add Formula/continuity.rb README.md
git commit -m "continuity: initial formula (CLI 3.5.8 + MCP 3.0.120)"
git push origin main
```

### Step 5: Smoke-test the live tap

Use a **clean shell** (or temporary directory) so you are not relying on a dev checkout:

```bash
brew untap hackerwarellc/tap 2>/dev/null || true
brew tap hackerwarellc/tap
brew trust hackerwarellc/tap
brew install continuity
brew test continuity

continuity --version
continuity-mcp --help 2>&1 | head -5
```

**Pass criteria:**

| Check | Expected |
|-------|----------|
| `brew install continuity` | exit 0 |
| `brew test continuity` | exit 0 |
| `continuity --version` | matches `CLI_VERSION` in formula |
| `which continuity-mcp` | under Homebrew prefix |

### Step 6: Test locally before pushing (optional)

Install from the formula file without publishing the tap:

```bash
cd /Users/mac-attack/DEV/continuity-ultimate/homebrew-tap
brew install --formula Formula/continuity.rb
```

If Homebrew rejects path install, use the tap clone in Step 4 and `brew install continuity` from there.

---

## For maintainers — release a version bump

Run after every npm publish that should reach brew users.

### Step 1: Publish to npm

```bash
# Bump continuity-cli/package.json, then:
bash scripts/npm-publish-cli.sh

# Bump packages/mcp-server/package.json if MCP changed, then:
bash scripts/npm-publish-mcp.sh
```

### Step 2: Update formula metadata

```bash
cd /Users/mac-attack/DEV/continuity-ultimate
node scripts/update-homebrew-formula.js
# or: node scripts/update-homebrew-formula.js --cli X.Y.Z --mcp A.B.C
git diff homebrew-tap/Formula/continuity.rb
```

Commit the formula change in **continuity-ultimate** (keeps source of truth in monorepo):

```bash
git add homebrew-tap/Formula/continuity.rb scripts/update-homebrew-formula.js
git commit -m "chore(brew): bump continuity formula to CLI x.y.z + MCP a.b.c"
```

### Step 3: Mirror to the tap repo

```bash
cd /tmp/homebrew-tap   # your homebrew-tap clone
cp /Users/mac-attack/DEV/continuity-ultimate/homebrew-tap/Formula/continuity.rb Formula/
cp /Users/mac-attack/DEV/continuity-ultimate/homebrew-tap/README.md README.md

git add Formula/continuity.rb README.md
git commit -m "continuity: CLI x.y.z + MCP a.b.c"
git push
```

### Step 4: Verify upgrade path

```bash
brew update
brew upgrade continuity
continuity --version
```

---

## What gets installed

| Brew command | npm packages | Binaries |
|--------------|--------------|----------|
| `brew install continuity` | `@continuity/cli` + `@continuity/mcp` | `continuity`, `continuity-mcp`, `continuity-setup` |

Install layout:

```
$(brew --prefix)/opt/continuity/libexec/cli/   ← @continuity/cli
$(brew --prefix)/opt/continuity/libexec/mcp/   ← @continuity/mcp
$(brew --prefix)/bin/continuity                ← symlink
$(brew --prefix)/bin/continuity-mcp            ← symlink
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Refusing to load formula ... untrusted tap` | Run `brew trust hackerwarellc/tap`, then retry `brew install continuity`. |
| `Could not symlink bin/continuity` (already exists) | Old npm global install: `brew link --overwrite continuity` or `npm uninstall -g @continuity/cli @continuity/mcp` then reinstall. |
| Wrong version (`3.5.7` vs brew `3.5.8`) | `which -a continuity` — `~/.local/bin` or npm may win PATH. Use `$(brew --prefix)/bin/continuity` or put `$(brew --prefix)/bin` first in PATH. |
| `brew tap` 404 | Tap repo must be **`github.com/hackerwarellc/homebrew-tap`** — run `brew tap hackerwarellc/tap`. |
| `sha256 mismatch` | Re-run `node scripts/update-homebrew-formula.js` after npm publish; push tap repo. |
| `continuity: command not found` | `brew link continuity` or open a new shell; check `echo $PATH` includes `$(brew --prefix)/bin`. |
| MCP client can't find server | Use full path: `$(brew --prefix)/bin/continuity-mcp` in MCP config. |
| PostHog / telemetry missing | Brew uses the same npm tarball as `npm install -g`; key is baked at npm publish time. |
| 2FA on npm publish | Use browser/passkey flow (Touch ID), not TOTP — see `scripts/npm-publish-cli.sh`. |

---

## Alternative: npm (no Homebrew)

```bash
npm install -g @continuity/cli@^3.6.0
```

Same binaries as Homebrew (`continuity` + `continuity-mcp`); `@continuity/mcp` installs automatically.
