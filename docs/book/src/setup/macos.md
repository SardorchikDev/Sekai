# macOS

Install, update, run as a LaunchAgent, and uninstall on macOS (Intel or Apple Silicon).

## Install

`install.sh` is the preferred path; Homebrew is a reasonable alternative if you want `brew services` integration.

### Option 1 — `install.sh` via curl (fastest)

```bash
curl -fsSL https://raw.githubusercontent.com/sekai-labs/sekai/master/install.sh | bash
```

### Option 2 — `install.sh` from a clone

```bash
git clone https://github.com/sekai-labs/sekai.git
cd sekai
./install.sh
```

### What the installer does

1. Asks whether you want a prebuilt binary or to build from source
2. Installs to `~/.cargo/bin/sekai`
3. Runs `sekai onboard` to complete first-time setup

Flags:

```bash
./install.sh --prebuilt                      # always prebuilt, skip the prompt
./install.sh --source                        # always build from source
./install.sh --minimal                       # kernel only (~6.6 MB)
./install.sh --source --features agent-runtime,channel-discord   # custom features
./install.sh --skip-onboard                  # install only; run `sekai onboard` later
./install.sh --list-features                 # print available features and exit
./install.sh --help                          # full flag reference
```

### Option 3 — Homebrew

```bash
brew install sekai
sekai onboard
```

Gets you `brew services` integration. Binary lives at `$HOMEBREW_PREFIX/bin/sekai`.

**Workspace location gotcha:** with Homebrew, the service user and the CLI user may be different, so the workspace lives at `$HOMEBREW_PREFIX/var/sekai/` rather than `~/.sekai/`. Point CLI invocations at the same workspace:

```bash
export SEKAI_WORKSPACE="$HOMEBREW_PREFIX/var/sekai"
```

Add that to your shell profile if you want it permanent.

## System dependencies

Most features work with a stock macOS install. Optional extras:

| Feature | Install |
|---|---|
| Docs translation | `brew install gettext` |
| Browser tool | Playwright pulls Chromium automatically on first use |
| Hardware | No native GPIO on macOS; use a USB peripheral like Aardvark. See [Hardware → Aardvark](../hardware/aardvark.md) |
| iMessage channel | Requires macOS 11+. See [Channels → Other chat platforms](../channels/chat-others.md) |

## Running as a service

```bash
sekai service install   # writes ~/Library/LaunchAgents/com.sekai.daemon.plist
sekai service start
sekai service status
```

Logs go to `~/Library/Logs/Sekai/`:

```bash
tail -f ~/Library/Logs/Sekai/sekai.log
```

For Homebrew installs, prefer:

```bash
brew services start sekai
brew services info sekai
```

Both methods produce the same end state — a loaded LaunchAgent that starts on login. Pick one and stick with it.

Full details: [Service management](./service.md).

## Update

Re-run the installer — it detects the existing install and upgrades in place:

```bash
curl -fsSL https://raw.githubusercontent.com/sekai-labs/sekai/master/install.sh | bash -s -- --skip-onboard
sekai service restart
```

Or from a clone:

```bash
cd /path/to/sekai
git pull
./install.sh --skip-onboard
sekai service restart
```

If installed via Homebrew instead:

```bash
brew update && brew upgrade sekai
brew services restart sekai
```

## Uninstall

```bash
# stop and unregister the service
sekai service stop
sekai service uninstall

# Homebrew
brew uninstall sekai

# bootstrap / cargo
rm ~/.cargo/bin/sekai
```

Remove config and workspace (optional — this deletes conversation history):

```bash
# Homebrew workspace
rm -rf "$HOMEBREW_PREFIX/var/sekai"

# Default workspace
rm -rf ~/.sekai ~/.config/sekai

# Logs
rm -rf ~/Library/Logs/Sekai
```

## Gotchas

- **Homebrew config path mismatch.** The wizard warns if it detects Homebrew — the `brew services` daemon reads `$HOMEBREW_PREFIX/var/sekai/config.toml`, not `~/.sekai/config.toml`. If your service is reading stale config, check which one the daemon sees.
- **First launch of the browser tool** downloads Chromium (~150 MB) via Playwright.
- **Apple Silicon** and **Intel** builds are both released. The bootstrap script auto-detects. Homebrew auto-selects.

## Next

- [Service management](./service.md)
- [Quick start](../getting-started/quick-start.md)
- [Operations → Overview](../ops/overview.md)
