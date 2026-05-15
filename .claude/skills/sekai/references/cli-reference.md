# Sekai CLI Reference

Complete command reference for the `sekai` binary.

## Table of Contents

1. [Agent](#agent)
2. [Onboarding](#onboarding)
3. [Status & Diagnostics](#status--diagnostics)
4. [Memory](#memory)
5. [Cron](#cron)
6. [Providers & Models](#providers--models)
7. [Gateway & Daemon](#gateway--daemon)
8. [Service Management](#service-management)
9. [Channels](#channels)
10. [Security & Emergency Stop](#security--emergency-stop)
11. [Hardware Peripherals](#hardware-peripherals)
12. [Skills](#skills)
13. [Shell Completions](#shell-completions)

---

## Agent

Interactive chat or single-message mode.

```bash
sekai agent                                          # Interactive REPL
sekai agent -m "Summarize today's logs"              # Single message
sekai agent -p anthropic --model claude-sonnet-4-6   # Override provider/model
sekai agent -t 0.3                                   # Set temperature
sekai agent --peripheral nucleo-f401re:/dev/ttyACM0  # Attach hardware
```

**Key flags:**
- `-m <message>` — single message mode (no REPL)
- `-p <provider>` — override provider (openrouter, anthropic, openai, ollama)
- `--model <model>` — override model
- `-t <float>` — temperature (0.0–2.0)
- `--peripheral <name>:<port>` — attach hardware peripheral

The agent has access to 30+ tools gated by security policy: shell, file_read, file_write, file_edit, glob_search, content_search, memory_store, memory_recall, memory_forget, browser, http_request, web_fetch, web_search, cron, delegate, git, and more. Max tool iterations defaults to 10.

---

## Onboarding

First-time setup or reconfiguration.

```bash
sekai onboard                                 # Quick mode (default: openrouter)
sekai onboard --provider anthropic            # Quick mode with specific provider
sekai onboard                                 # Guided wizard (default)
sekai onboard --memory sqlite                 # Set memory backend
sekai onboard --force                         # Overwrite existing config
sekai onboard --channels-only                 # Repair channels only
```

**Key flags:**
- `--provider <name>` — openrouter (default), anthropic, openai, ollama
- `--model <model>` — default model
- `--memory <backend>` — sqlite, markdown, lucid, none
- `--force` — overwrite existing config.toml
- `--channels-only` — only repair channel configuration
- `--reinit` — start fresh (backs up existing config)

Creates `~/.sekai/config.toml` with `0600` permissions.

---

## Status & Diagnostics

```bash
sekai status                    # System overview
sekai doctor                    # Run all diagnostic checks
sekai doctor models             # Probe model connectivity
sekai doctor traces             # Query execution traces
```

---

## Memory

```bash
sekai memory list                              # List all entries
sekai memory list --category core --limit 10   # Filtered list
sekai memory get "some-key"                    # Get specific entry
sekai memory stats                             # Usage statistics
sekai memory clear --key "prefix" --yes        # Delete entries (requires --yes)
```

**Key flags:**
- `--category <name>` — filter by category (core, daily, conversation, custom)
- `--limit <n>` — limit results
- `--key <prefix>` — key prefix for clear operations
- `--yes` — skip confirmation (required for clear)

---

## Cron

```bash
sekai cron list                                                      # List all jobs
sekai cron add '0 9 * * 1-5' 'Good morning' --tz America/New_York   # Recurring (cron expr)
sekai cron add-at '2026-03-11T10:00:00Z' 'Remind me about meeting'  # One-time at specific time
sekai cron add-every 3600000 'Check server health'                   # Interval in milliseconds
sekai cron once 30m 'Follow up on that task'                         # Delay from now
sekai cron pause <id>                                                # Pause job
sekai cron resume <id>                                               # Resume job
sekai cron remove <id>                                               # Delete job
```

**Subcommands:**
- `add <cron-expr> <command>` — standard cron expression (5-field)
- `add-at <iso-datetime> <command>` — fire once at exact time
- `add-every <ms> <command>` — repeating interval
- `once <duration> <command>` — delay from now (e.g., `30m`, `2h`, `1d`)

---

## Providers & Models

```bash
sekai providers                                # List all 40+ supported providers
sekai models list                              # Show cached model catalog
sekai models refresh --all                     # Refresh catalogs from all providers
sekai models set anthropic/claude-sonnet-4-6   # Set default model
sekai models status                            # Current model info
```

Model routing in config.toml:
```toml
[[model_routes]]
hint = "reasoning"
provider = "openrouter"
model = "anthropic/claude-sonnet-4-6"
```

---

## Gateway & Daemon

```bash
sekai gateway                                 # Start HTTP gateway (foreground)
sekai gateway -p 8080 --host 127.0.0.1        # Custom port/host

sekai daemon                                  # Gateway + channels + scheduler + heartbeat
sekai daemon -p 8080 --host 0.0.0.0           # Custom bind
```

**Gateway defaults:**
- Port: 42617
- Host: 127.0.0.1
- Pairing required: true
- Public bind allowed: false

---

## Service Management

OS service lifecycle (systemd on Linux, launchd on macOS).

```bash
sekai service install     # Install as system service
sekai service start       # Start the service
sekai service status      # Check service status
sekai service stop        # Stop the service
sekai service restart     # Restart the service
sekai service uninstall   # Remove the service
```

**Logs:**
- macOS: `~/.sekai/logs/daemon.stdout.log`
- Linux: `journalctl -u sekai`

---

## Channels

Channels are configured in `config.toml` under `[channels]` and `[channels_config.*]`.

```bash
sekai channels list       # List configured channels
sekai channels doctor     # Check channel health
```

Supported channels (21 total): Telegram, Discord, Slack, WhatsApp (Meta), WATI, Linq (iMessage/RCS/SMS), Email (IMAP/SMTP), IRC, Matrix, Nostr, Signal, Nextcloud Talk, and more.

Channel config example (Telegram):
```toml
[channels]
telegram = true

[channels_config.telegram]
bot_token = "..."
allowed_users = [123456789]
```

---

## Security & Emergency Stop

```bash
sekai estop --level kill-all                              # Stop everything
sekai estop --level network-kill                          # Block all network access
sekai estop --level domain-block --domain "*.example.com" # Block specific domains
sekai estop --level tool-freeze --tool shell              # Freeze specific tool
sekai estop status                                        # Check estop state
sekai estop resume --network                              # Resume (may require OTP)
```

**Estop levels:**
- `kill-all` — nuclear option, stops all agent activity
- `network-kill` — blocks all outbound network
- `domain-block` — blocks specific domain patterns
- `tool-freeze` — freezes individual tools

Autonomy config in config.toml:
```toml
[autonomy]
level = "supervised"                           # read_only | supervised | full
workspace_only = true
allowed_commands = ["git", "cargo", "python"]
forbidden_paths = ["/etc", "/root", "~/.ssh"]
max_actions_per_hour = 20
max_cost_per_day_cents = 500
```

---

## Hardware Peripherals

```bash
sekai hardware discover                              # Find USB devices
sekai hardware introspect /dev/ttyACM0               # Probe device capabilities
sekai peripheral list                                # List configured peripherals
sekai peripheral add nucleo-f401re /dev/ttyACM0      # Add peripheral
sekai peripheral flash-nucleo                        # Flash STM32 firmware
sekai peripheral flash --port /dev/cu.usbmodem101    # Flash Arduino firmware
```

**Supported boards:** STM32 Nucleo-F401RE, Arduino Uno R4, Raspberry Pi GPIO, ESP32.

Attach to agent session: `sekai agent --peripheral nucleo-f401re:/dev/ttyACM0`

---

## Skills

```bash
sekai skills list         # List installed skills
sekai skills install <path-or-url>  # Install a skill
sekai skills audit        # Audit installed skills
sekai skills remove <name>  # Remove a skill
```

---

## Shell Completions

```bash
sekai completions zsh     # Generate Zsh completions
sekai completions bash    # Generate Bash completions
sekai completions fish    # Generate Fish completions
```

---

## Config File

Default location: `~/.sekai/config.toml`

Config resolution order (first match wins):
1. `SEKAI_CONFIG_DIR` environment variable
2. `SEKAI_WORKSPACE` environment variable
3. `~/.sekai/active_workspace.toml` marker file
4. `~/.sekai/config.toml` (default)
