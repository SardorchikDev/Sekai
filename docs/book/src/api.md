# API Reference

Full rustdoc for every public type in the workspace, auto-generated from the `///` comments on each type, function, and module. Use this when you need to know the exact shape of a struct, the methods on a trait, or what a function returns — anything the generated reference exposes better than prose can.

**[Open the rustdoc →](../api/sekai/index.html)**

## How to navigate it

- The sidebar on the left lists every crate in the workspace
- Click `sekai-api` first — that's where the public traits (`Provider`, `Channel`, `Tool`) live
- Use `cmd/ctrl+F` in the rustdoc page to search within a crate
- Click on any trait to see implementors across the workspace

## Crate index

| Crate | What it exposes |
|---|---|
| [`sekai`](../api/sekai/index.html) | Top-level umbrella with re-exports |
| [`sekai-api`](../api/sekai_api/index.html) | Public traits: `Provider`, `Channel`, `Tool`, `StreamEvent` |
| [`sekai-config`](../api/sekai_config/index.html) | Config schema, autonomy types, secrets |
| [`sekai-runtime`](../api/sekai_runtime/index.html) | Agent loop, security, SOP, onboarding |
| [`sekai-providers`](../api/sekai_providers/index.html) | Every LLM-provider implementation |
| [`sekai-channels`](../api/sekai_channels/index.html) | Messaging integrations |
| [`sekai-gateway`](../api/sekai_gateway/index.html) | HTTP/WebSocket gateway |
| [`sekai-tools`](../api/sekai_tools/index.html) | Agent-callable tools |
| [`sekai-memory`](../api/sekai_memory/index.html) | Conversation memory, embeddings |
| [`sekai-plugins`](../api/sekai_plugins/index.html) | WASM plugin host |
| [`sekai-hardware`](../api/sekai_hardware/index.html) | GPIO / I2C / SPI / USB |
| [`sekai-infra`](../api/sekai_infra/index.html) | Tracing, metrics |

See [Architecture → Crates](./architecture/crates.md) for a plain-English description of how the crates fit together.

## Regenerating the API reference

The rustdoc ships with every doc deploy. For local builds:

```bash
cargo mdbook refs     # generates CLI + config reference + rustdoc
cargo mdbook build    # rebuilds the full book including rustdoc bridge
```

See [Maintainers → Docs & Translations](./maintainers/docs-and-translations.md).
