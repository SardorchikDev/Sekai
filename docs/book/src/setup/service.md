# Service Management

Sekai ships with first-class service integration for systemd (Linux), launchctl (macOS), and Task Scheduler / Windows Service (Windows). All three are driven by one CLI surface:

```bash
sekai service install     # register the service
sekai service start       # start it
sekai service stop        # stop it
sekai service restart     # stop + start
sekai service status      # running / stopped, last exit code
sekai service uninstall   # remove it
```

The platform-specific backends are implemented in `crates/sekai-runtime/src/service/`. You don't have to think about them — but knowing what they produce helps when debugging.

## Linux — systemd

`sekai service install` writes a user-scoped unit at `~/.config/systemd/user/sekai.service`.

The unit:

- `Type=simple` with the agent process staying in the foreground
- `User=` set to the invoking user
- `SupplementaryGroups=gpio spi i2c` (enabled if hardware feature is compiled in)
- `Restart=on-failure` with a 10-second backoff
- `ExecStart=/home/$USER/.cargo/bin/sekai daemon`

### Manual control

```bash
systemctl --user start sekai
systemctl --user stop sekai
systemctl --user status sekai
systemctl --user enable sekai     # start on login
```

### Logs

```bash
journalctl --user -u sekai -f        # follow
journalctl --user -u sekai --since "1h ago"
```

### System-scope (root) service

If you need Sekai to start before user login (headless SBCs, VPSes), run the install command as root:

```bash
sudo sekai service install
sudo systemctl enable --now sekai
```

When invoked with sudo/root, `sekai service install` creates a system-scope unit at `/etc/systemd/system/sekai.service` and provisions a dedicated `sekai` service user.

## Linux — OpenRC

Detected automatically when `/run/openrc` exists (Alpine, some Gentoo configs).

```bash
sekai service install   # writes /etc/init.d/sekai
rc-service sekai start
rc-update add sekai default    # start on boot
```

## macOS — LaunchAgent

`sekai service install` writes `~/Library/LaunchAgents/com.sekai.daemon.plist` and loads it.

```bash
launchctl list | grep sekai
launchctl unload ~/Library/LaunchAgents/com.sekai.daemon.plist
launchctl load ~/Library/LaunchAgents/com.sekai.daemon.plist
```

Logs go to `~/Library/Logs/Sekai/sekai.log` (stdout) and `sekai.err` (stderr).

### Homebrew-managed

If installed via Homebrew, `brew services` is the preferred interface:

```bash
brew services start sekai
brew services restart sekai
brew services info sekai
```

Don't mix `sekai service` CLI commands with `brew services` — pick one. Both end up writing a plist; having both around confuses `launchctl`.

## Windows — Task Scheduler

`sekai service install` creates a scheduled task in the current user's session:

- Trigger: at logon
- Condition: battery, idle, and power-save conditions are **all disabled** (otherwise the task would stop unexpectedly)
- Action: run `sekai daemon` hidden

Verify in Task Scheduler GUI (`taskschd.msc`) under Task Scheduler Library → Sekai.

Logs go to `%LOCALAPPDATA%\Sekai\logs\`:

```cmd
type %LOCALAPPDATA%\Sekai\logs\sekai.log
```

### Windows Service (system-scope)

For servers or multi-user Windows installs, run `sekai service install` from an Administrator prompt:

```cmd
:: Administrator cmd.exe
sekai service install
```

Running elevated causes the installer to register a real Windows Service under `LocalSystem` instead of a user-scoped scheduled task. Control via `services.msc` or:

```cmd
sc query Sekai
sc start Sekai
sc stop Sekai
```

## Config path resolution

The service reads config from whichever workspace it was installed against. Order:

1. `$SEKAI_CONFIG_DIR/config.toml` if set
2. `$SEKAI_WORKSPACE/.sekai/config.toml` if set
3. `$HOMEBREW_PREFIX/var/sekai/.sekai/config.toml` if installed via Homebrew
4. `~/.sekai/config.toml` (Linux/macOS) or `%USERPROFILE%\.sekai\config.toml` (Windows)

If your service seems to ignore config changes, check which path the daemon is reading:

```bash
sekai config list
```

The first few lines of its output show the config file path it resolved against.

## Auto-update

The service does **not** auto-update. That's deliberate — you pick when to take new code. Subscribe to the GitHub release feed or the Discord `#releases` channel (see [Contributing → Communication](../contributing/communication.md)).

## See also

- [Linux setup](./linux.md), [macOS setup](./macos.md), [Windows setup](./windows.md)
- [Operations → Logs & observability](../ops/observability.md)
- [Operations → Troubleshooting](../ops/troubleshooting.md)
