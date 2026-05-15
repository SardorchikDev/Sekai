# syntax=docker/dockerfile:1.7-labs

# ── Stage 0: Frontend build ─────────────────────────────────────
FROM node:22-bookworm-slim@sha256:9f6d5975c7dca860947d3915877f85607946403fc55349f39b4bc3688448bb6e AS web-node

FROM rust:1.94-slim@sha256:da9dab7a6b8dd428e71718402e97207bb3e54167d37b5708616050b1e8f60ed6 AS web-builder
WORKDIR /app
COPY --from=web-node /usr/local/bin/node /usr/local/bin/node
COPY --from=web-node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
        pkg-config \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && rm -rf /var/lib/apt/lists/*
COPY web/package.json web/package-lock.json web/
RUN cd web && npm ci --ignore-scripts
COPY . .
RUN mkdir -p apps/tauri/src \
    && echo "fn main() {}" > apps/tauri/src/main.rs \
    && echo "fn main() {}" > apps/tauri/build.rs
RUN --mount=type=cache,id=sekai-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=sekai-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,id=sekai-web-target,target=/app/target,sharing=locked \
    cargo web build

# ── Stage 1: Build ────────────────────────────────────────────
FROM rust:1.94-slim@sha256:da9dab7a6b8dd428e71718402e97207bb3e54167d37b5708616050b1e8f60ed6 AS builder

WORKDIR /app
ARG SEKAI_CARGO_FEATURES="channel-lark,whatsapp-web"

# Install build dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 1. Copy manifests to cache dependencies
COPY Cargo.toml Cargo.lock ./
# Copy every workspace-member manifest in one glob — adding or removing a crate
# no longer requires editing this file.  --parents preserves the
# crates/<name>/Cargo.toml directory structure.
# aardvark-sys has an implicit build script (build.rs at its crate root) that
# Cargo must compile during the dependency pre-fetch step; copy it explicitly.
COPY --parents crates/*/Cargo.toml ./
COPY --parents crates/aardvark-sys/build.rs ./
# apps/tauri: .dockerignore whitelists only Cargo.toml; src and build.rs are stubbed below.
COPY apps/tauri/Cargo.toml apps/tauri/Cargo.toml
# tools/fill-translations and xtask are dev/build tools; copy manifests only so
# Cargo can resolve the workspace, then stub their entry points so the
# dependency pre-fetch step succeeds without building them into the image.
COPY tools/fill-translations/Cargo.toml tools/fill-translations/Cargo.toml
COPY xtask/Cargo.toml xtask/Cargo.toml
# Create dummy targets for all workspace members so manifest parsing succeeds.
# `src/bin/sekai-acp-bridge.rs` is required because the `acp-bridge` feature
# is in the root crate's default set; cargo selects the bin target during the
# pre-fetch build even with only the workspace lib stubbed.
RUN mkdir -p src src/bin benches apps/tauri/src tools/fill-translations/src xtask/src/bin \
    && echo "fn main() {}" > src/main.rs \
    && echo "" > src/lib.rs \
    && echo "fn main() {}" > src/bin/sekai-acp-bridge.rs \
    && echo "fn main() {}" > benches/agent_benchmarks.rs \
    && echo "fn main() {}" > apps/tauri/src/main.rs \
    && echo "fn main() {}" > apps/tauri/build.rs \
    && echo "fn main() {}" > tools/fill-translations/src/main.rs \
    && echo "" > xtask/src/lib.rs \
    && echo "fn main() {}" > xtask/src/bin/mdbook.rs \
    && echo "fn main() {}" > xtask/src/bin/fluent.rs \
    && echo "fn main() {}" > xtask/src/bin/web.rs \
    && for d in crates/*/; do mkdir -p "${d}src" && printf '' > "${d}src/lib.rs"; done
RUN --mount=type=cache,id=sekai-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=sekai-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,id=sekai-target,target=/app/target,sharing=locked \
    if [ -n "$SEKAI_CARGO_FEATURES" ]; then \
      cargo build --release --locked --features "$SEKAI_CARGO_FEATURES"; \
    else \
      cargo build --release --locked; \
    fi
RUN rm -rf src benches crates xtask tools/fill-translations

# 2. Copy only build-relevant source paths (avoid cache-busting on docs/tests/scripts)
COPY src/ src/
COPY benches/ benches/
COPY crates/ crates/
COPY xtask/ xtask/
COPY tools/fill-translations/ tools/fill-translations/
COPY *.rs .
RUN touch src/main.rs
RUN --mount=type=cache,id=sekai-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=sekai-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    --mount=type=cache,id=sekai-target,target=/app/target,sharing=locked \
    rm -rf target/release/.fingerprint/sekailabs-* \
           target/release/deps/sekailabs-* \
           target/release/incremental/sekailabs-* \
           target/release/.fingerprint/sekai-* \
           target/release/deps/sekai_* \
           target/release/incremental/sekai_* \
           target/release/.fingerprint/xtask-* \
           target/release/deps/xtask-* \
           target/release/.fingerprint/fill-translations-* \
           target/release/deps/fill_translations-* && \
    if [ -n "$SEKAI_CARGO_FEATURES" ]; then \
      cargo build --release --locked --features "$SEKAI_CARGO_FEATURES"; \
    else \
      cargo build --release --locked; \
    fi && \
    cp target/release/sekai /app/sekai && \
    strip /app/sekai
RUN size=$(stat -c%s /app/sekai) && \
    if [ "$size" -lt 1000000 ]; then echo "ERROR: binary too small (${size} bytes), likely dummy build artifact" && exit 1; fi

# Prepare runtime directory structure and default config inline (no extra stage).
# Dashboard assets live at /usr/share/sekailabs/web/dist (outside the documented
# /sekai-data mount point) so a bind mount on /sekai-data cannot shadow them.
RUN mkdir -p /sekai-data/.sekai /sekai-data/workspace && \
    printf '%s\n' \
        'workspace_dir = "/sekai-data/workspace"' \
        'config_path = "/sekai-data/.sekai/config.toml"' \
        'api_key = ""' \
        'default_provider = "openrouter"' \
        'default_model = "anthropic/claude-sonnet-4-20250514"' \
        'default_temperature = 0.7' \
        '' \
        '[gateway]' \
        'port = 42617' \
        'host = "[::]"' \
        'allow_public_bind = true' \
        'require_pairing = false' \
        'web_dist_dir = "/usr/share/sekailabs/web/dist"' \
        '' \
        '[autonomy]' \
        'level = "supervised"' \
        'auto_approve = ["file_read", "file_write", "file_edit", "memory_recall", "memory_store", "web_search_tool", "web_fetch", "calculator", "glob_search", "content_search", "image_info", "weather", "git_operations"]' \
        > /sekai-data/.sekai/config.toml && \
    chown -R 65534:65534 /sekai-data

# ── Stage 2: Development Runtime (Debian) ────────────────────
FROM debian:trixie-slim@sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba AS dev

# Install essential runtime dependencies only (use docker-compose.override.yml for dev tools)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /sekai-data /sekai-data
COPY --from=builder /app/sekai /usr/local/bin/sekai
# Install the dashboard at /usr/share/sekailabs/web/dist (outside the
# documented /sekai-data mount) so user volumes do not shadow it (#6400).
COPY --from=web-builder /app/web/dist /usr/share/sekailabs/web/dist

# Overwrite minimal config with DEV template (Ollama defaults)
COPY dev/config.template.toml /sekai-data/.sekai/config.toml
RUN chown 65534:65534 /sekai-data/.sekai/config.toml

# Environment setup
# Ensure UTF-8 locale so CJK / multibyte input is handled correctly
ENV LANG=C.UTF-8
# Use consistent workspace path
ENV SEKAI_WORKSPACE=/sekai-data/workspace
ENV HOME=/sekai-data
# Defaults for local dev (Ollama) - matches config.template.toml
ENV PROVIDER="ollama"
ENV SEKAI_MODEL="llama3.2"
ENV SEKAI_GATEWAY_PORT=42617

# Note: API_KEY is intentionally NOT set here to avoid confusion.
# It is set in config.toml as the Ollama URL.

WORKDIR /sekai-data
USER 65534:65534
EXPOSE 42617
HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=10s \
    CMD ["sekai", "status", "--format=exit-code"]
ENTRYPOINT ["sekai"]
CMD ["daemon"]

# ── Stage 3: Production Runtime (Distroless) ─────────────────
FROM gcr.io/distroless/cc-debian13:nonroot@sha256:84fcd3c223b144b0cb6edc5ecc75641819842a9679a3a58fd6294bec47532bf7 AS release

COPY --from=builder /app/sekai /usr/local/bin/sekai
COPY --from=builder /sekai-data /sekai-data
# Install the dashboard at /usr/share/sekailabs/web/dist (outside the
# documented /sekai-data mount) so user volumes do not shadow it (#6400).
COPY --from=web-builder /app/web/dist /usr/share/sekailabs/web/dist

# Environment setup
# Ensure UTF-8 locale so CJK / multibyte input is handled correctly
ENV LANG=C.UTF-8
ENV SEKAI_WORKSPACE=/sekai-data/workspace
ENV HOME=/sekai-data
# Default provider and model are set in config.toml, not here,
# so config file edits are not silently overridden
#ENV PROVIDER=
ENV SEKAI_GATEWAY_PORT=42617

# API_KEY must be provided at runtime!

WORKDIR /sekai-data
USER 65534:65534
EXPOSE 42617
HEALTHCHECK --interval=60s --timeout=10s --retries=3 --start-period=10s \
    CMD ["sekai", "status", "--format=exit-code"]
ENTRYPOINT ["sekai"]
CMD ["daemon"]
