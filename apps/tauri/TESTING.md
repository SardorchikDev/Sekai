# Desktop app — testing notes

## macOS (current target)

### Reset to fresh-install state
```sh
pkill -f 'target/debug/sekai-desktop'
rm "$HOME/Library/Application Support/ai.sekailabs.desktop/settings.json"
tccutil reset All ai.sekailabs.desktop      # for installed .app only — see notes
killall Dock                                   # if dock icon looks stale
bash dev/run-tauri-dev.sh
```

`tccutil reset` only matches by bundle id, which is set on the `.app`, not the dev binary. For real fresh-permission tests, build the `.app` first:
```sh
cd apps/tauri && cargo tauri build
cp -R target/release/bundle/macos/Sekai.app /Applications/
xattr -dr com.apple.quarantine /Applications/Sekai.app
tccutil reset All ai.sekailabs.desktop
open /Applications/Sekai.app
```

### What to verify in the wizard
- 8 steps render with progress dots
- Each Grant button either opens the right System Settings pane (deep-link via `x-apple.systempreferences:`) or fires the native macOS prompt (Screen Recording, Microphone, Camera, Input Monitoring)
- Status pills flip to Granted within 2s of toggling in System Settings (driven by the 2s polling loop in `onboarding/index.html`)
- "Start Sekai" closes onboarding, opens the main dashboard window pointed at the gateway, and fires `POST /api/devices/me/capabilities` (best-effort)
- Quit + relaunch → wizard does not reappear; only the tray icon

### Known macOS-only pieces
- `apps/tauri/src/macos/permissions.rs` is `#[cfg(target_os = "macos")]`
- IOKit (`IOHIDCheckAccess`) for Input Monitoring
- `ApplicationServices.framework` (`AXIsProcessTrusted`) for Accessibility
- `CoreGraphics.framework` (`CGRequestScreenCaptureAccess`) for Screen Recording
- Swift CLI bridges (`swift -e`) for AVFoundation, UNUserNotificationCenter, SFSpeechRecognizer
- `osascript` bridge for Automation
- `open x-apple.systempreferences:...?Privacy_*` for deep-linking

## Linux (NOT YET IMPLEMENTED — tracked in #6501)

### What works today
- App builds (cfg gates skip macOS-only code)
- Tauri shell, windows, tray, app icon (`icon.png`), bundle as `.deb`/`.AppImage`
- Onboarding wizard renders

### What does NOT work today
- Every permission reports a stub "granted" status — wizard becomes 8 click-throughs of no-ops
- No real permission gates exist on most Linux setups; some are gated by:
  - **xdg-desktop-portal** (Wayland) — for screen capture, file picker, etc.
  - **PipeWire/PulseAudio** — for mic/camera (just device access, no prompt)
  - **D-Bus + libnotify** — for notifications (no permission gate)
  - **AT-SPI** for accessibility — open, no permission concept

### What to test once #6501 lands
- Fresh `.deb` install on Ubuntu 22.04+ → onboarding shows simplified flow → tray works
- Fresh `.AppImage` on Fedora/Arch → same
- xdg-desktop-portal screen capture prompt fires once on Wayland
- Notification appears via D-Bus

### How to attempt a build today (will compile, won't be useful)
```sh
cd apps/tauri
cargo build --release --target x86_64-unknown-linux-gnu   # needs cross toolchain
# Or build natively on a Linux box:
cargo tauri build
```

## Windows (NOT YET IMPLEMENTED — tracked in #6501)

### What works today
- App builds (cfg gates skip macOS-only code)
- Tauri shell, windows, system tray, app icon (`icon.ico`), bundle as `.exe`/`.msi`
- Onboarding wizard renders

### What does NOT work today
- Same stub "granted" problem as Linux
- Windows permissions live in:
  - **App manifest** (UWP capability declarations) — required at build time for mic/camera
  - **Settings → Privacy** (system-wide app permissions)
  - **Action Center** for notifications (no permission gate)
  - **Admin elevation** for low-level keyboard hooks (Input Monitoring equivalent)

### What to test once #6501 lands
- Fresh `.msi` install on Windows 11 → onboarding shows simplified flow → system tray works
- Mic/camera consent dialog fires from Privacy panel
- Notifications appear in Action Center
- Admin-elevation prompt for global keyboard hook

### How to attempt a build today (will compile, won't be useful)
```sh
cd apps/tauri
cargo build --release --target x86_64-pc-windows-msvc     # needs cross toolchain
# Or build natively on Windows:
cargo tauri build
```

## CI matrix to add (separate issue)

```yaml
# Suggested when #6501 lands — run all three at minimum on cargo check
matrix:
  os: [macos-14, ubuntu-22.04, windows-2022]
```

## Capability sync end-to-end test (gateway-side)

Today the gateway's `POST /api/devices/me/capabilities` is implemented in this branch but the running gateway behind the SSH tunnel is an older build. To verify capabilities actually land in the DB:

```sh
# Run a local gateway from this branch
cargo run -p sekai -- gateway

# In another terminal, walk the wizard, click "Start Sekai"
# Then query the local devices.db (path depends on workspace config):
sqlite3 <workspace>/devices.db "SELECT id, capabilities FROM devices;"
# Expected: one row with a JSON array of granted permission names.
```

When the production gateway is rebuilt from this branch, the same query against the VPS DB will show the production Mac's capabilities.
