//! Mobile entry point for Sekai Desktop (iOS/Android).

#[tauri::mobile_entry_point]
fn main() {
    sekai_desktop::run();
}
