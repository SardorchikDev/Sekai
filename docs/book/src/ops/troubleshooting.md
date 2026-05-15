# Troubleshooting

Common failure modes, in the order you're likely to encounter them.

First stop for any issue:

```bash
sekai doctor
```

Runs a series of checks and prints a summary. Most of what follows is the detailed version of what `doctor` flags.

---

## Install-time

### `cargo` not found

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Or pass `--prebuilt` to `install.sh` / `setup.bat` to skip Rust entirely.

### Missing build dependencies (Linux)

Install the baseline toolchain for your distro, then re-run `./install.sh`:

```bash
# Debian / Ubuntu
sudo apt install build-essential pkg-config

# Fedora / RHEL
sudo dnf group install development-tools && sudo dnf install pkg-config

# Arch
sudo pacman -S base-devel
```

Full per-distro list: [Setup → Linux](../setup/linux.md).

### Build OOMs on low-RAM hosts

Compiling Sekai from source needs ~2 GB RAM at peak. On a 512 MB Raspberry Pi, you will OOM.

Options:

1. **Use a prebuilt** — `./install.sh --prebuilt` skips the toolchain and downloads from GitHub Releases
2. **Cross-compile on a bigger machine and copy the binary**
3. **Serialise the build** — `CARGO_BUILD_JOBS=1 cargo build --release --locked`
4. **Add swap** (works for RAM, costs disk — check you have both)

### Build is very slow

The Matrix E2EE stack (`matrix-sdk`, `ruma`, `vodozemac`) and TLS/crypto native deps (`aws-lc-sys`, `ring`) are the main cost. Opt out if you don't need them:

```bash
cargo build --release --locked --no-default-features --features "default-lean"
```

Or check what's happening:

```bash
cargo check --timings
# report at target/cargo-timings/cargo-timing.html
```

### `sekai: command not found` after install

`cargo install` puts binaries in `~/.cargo/bin/`. Add to PATH:

```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

Persist in your shell profile.

---

## Onboarding

### Wizard insists on a config that doesn't exist

If an earlier install left `~/.sekai/config.toml`, re-run with `--force`:

```bash
sekai onboard --force
```

Or just delete the directory and start over:

```bash
rm -rf ~/.sekai
sekai onboard
```

### Homebrew-installed but wizard writes to the wrong path

Homebrew installs prefer `$HOMEBREW_PREFIX/var/sekai/` (so `brew services` works). The wizard warns if it detects this — set `SEKAI_WORKSPACE` to the Homebrew path before onboarding:

```bash
export SEKAI_WORKSPACE="$HOMEBREW_PREFIX/var/sekai"
sekai onboard
```

Or manually symlink once:

```bash
ln -s "$HOMEBREW_PREFIX/var/sekai" ~/.sekai
```

---

## Runtime

### OpenAI Codex subscription auth warns about config or streaming

Symptoms:

- `default_provider = "openai-codex"` is set, but runs still feel misconfigured
- Config loading warns about unknown top-level `api_key` / `api_url`
- Agent logs `provider streaming failed, falling back to non-streaming chat`

Checks:

```bash
sekai auth status
sekai auth login --provider openai-codex --device-code
sekai agent --provider openai-codex -m "hello"
```

Use this minimal `config.toml` shape for normal subscription auth:

```toml
default_provider = "openai-codex"
default_model = "gpt-5-codex"
```

Notes:

- Standard OpenAI Codex subscription auth uses stored auth profiles, so top-level `api_key` / `api_url` should usually stay unset.
- `api_key` / `api_url` are only needed for custom OpenAI-compatible gateways or other explicit endpoint overrides.
- The streaming fallback warning by itself is not an auth failure; Sekai retries the request in non-streaming mode.

### Daemon starts, then immediately exits

Check journald / the platform log (see [Logs & observability](./observability.md)) for the actual error. Common causes:

- **Invalid config** — `sekai config list` to print resolved values, `sekai config schema` to see the expected shape
- **Port conflict** — another process on `42617`; change `[gateway] port` or free the port
- **Missing secrets** — encrypted secrets store can't decrypt because the key file is gone; restore from backup or re-run onboarding

### Daemon keeps restarting

`systemctl --user status sekai` shows the last exit. If it's a config error, it stopped restarting (exit 2) and you need to fix the config. If it's a panic, the unit retries every 10 s.

Enable debug logging and catch the next failure:

```bash
sekai service stop
RUST_LOG=sekai=debug sekai daemon
```

### Gateway unreachable

```bash
curl -sv http://localhost:42617/health
```

If connection refused: daemon isn't running, or it's bound to a different interface. Check `[gateway] host` / `port` in config.

If 403 / 401: pairing not completed or token expired. Run the pairing flow again.

---

## Channels

### Telegram: `terminated by other getUpdates request`

Two processes are polling the same bot token. Telegram only allows one poller at a time.

Fix: stop all but one `sekai daemon` / `sekai channel start` using that token.

### Discord / Slack auth failures

Discord tokens expire if you regenerate them in the Developer Portal. Slack bot tokens don't expire but can be revoked. Check the bot is still installed in the target workspace/guild.

For either:

```bash
sekai channel doctor discord
sekai channel doctor slack
```

### Matrix: "unknown device"

If you re-onboarded without keeping device keys, the homeserver sees a new device that hasn't been verified. Re-verify from another logged-in client, or reset the key store:

```bash
rm -rf ~/.sekai/workspace/matrix-crypto
# re-run pairing flow on next channel start
```

### IMAP polling stopped

Most often an auth failure — provider rotated the password or the app-password expired. Check:

```bash
journalctl --user -u sekai -n 200 | grep -i imap
```

---

## Providers

### "Connection timed out" to Ollama

- Ollama daemon not running: `systemctl status ollama` (Linux), `brew services list` (macOS)
- Wrong URL in config — from inside a container, `localhost:11434` doesn't reach the host; use `host.docker.internal` or the host's LAN IP
- Firewall blocking port 11434 — rare locally, common on shared LANs

### Anthropic / OpenAI 401

API key invalid or expired. Regenerate at the provider's dashboard, update in `[providers.models.<name>] api_key`, restart the service.

If using OAuth (`sk-ant-oat*`), the OAuth token may have expired — OAuth-issued tokens are longer-lived but not infinite. Re-authenticate.

### Fallback chain always uses the fallback, never the primary

Check latency and error logs — the primary may be consistently timing out. If so, lower the retry count on the primary so it fails through faster, or fix whatever's making the primary flaky.

---

## Tools

### Shell commands "blocked by policy"

Expected behaviour at `Supervised` autonomy for unknown commands. Either:

- Approve inline when prompted
- Add the command to `[autonomy] allowed_commands`
- Raise autonomy to `Full` if you trust the context

See [Security → Autonomy levels](../security/autonomy.md).

### Tool invocations fail inside Docker sandbox

- Container image isn't pulled — run `docker pull <image>` for whatever you have configured under `[security.sandbox].image` (default: `alpine:latest`)
- Docker daemon not reachable from the Sekai user — check `docker info`
- Tool needs a device that's not passed through — extend `allow_devices`

### Browser tool hangs on first use

Playwright downloads Chromium (~150 MB) on first launch. Let it finish. If it keeps hanging, check disk space and proxy config.

---

## Service mode

### Service installed but shows inactive

```bash
sekai service start
sekai service status
```

Use `sekai service logs` to tail the installed service logs. Add `--follow` to stream new entries or `--lines <count>` to change how much history is shown. If the wrapper is unavailable or you need to inspect the platform directly, use:

- Linux: `journalctl --user -u sekai.service -f`
- macOS: `log stream --predicate 'process == "sekai"'`
- If you are running `sekai daemon` directly in a terminal, use that foreground output instead of service log commands.

If that succeeds interactively but the service dies in the background, it's almost always config or permissions — read the journal:

```bash
journalctl --user -u sekai --since "5 minutes ago"
```

### Service can't find config

The service and CLI may resolve config differently if they run as different users or with different env vars. Force-print the path the daemon sees:

```bash
sekai config list
```

If the paths differ between `sekai config list` (as you) and the service (as its user), either:

- Set `SEKAI_CONFIG_DIR` in the service unit's `Environment=`
- Run the service as you (lingering-enabled user service)
- Copy/symlink the config to the path the service expects

---

## Still stuck?

Gather diagnostics and file an issue:

```bash
sekai --version
sekai doctor
sekai channel doctor
journalctl --user -u sekai --since "1 hour ago" > sekai-log.txt
```

Sanitise `sekai-log.txt` (redact channel tokens if any slipped through — they shouldn't) and attach it to the issue. See [Contributing → Communication](../contributing/communication.md) for where.

## See also

- [Logs & observability](./observability.md)
- [Service & daemon](./service.md)
- [Setup → Service management](../setup/service.md)
- [Reference → Config](../reference/config.md)
