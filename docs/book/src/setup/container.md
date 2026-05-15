# Docker & Containers

Run Sekai in Docker, Podman, Kubernetes, or any OCI runtime.

## Official images

Pushed to GitHub Container Registry (`ghcr.io`) on every stable release:

- `ghcr.io/sekai-labs/sekai:latest` — latest stable
- `ghcr.io/sekai-labs/sekai:v0.7.5` — pinned
- `ghcr.io/sekai-labs/sekai:debian` — Debian-based image (larger, broader glibc support)

Multi-arch: `linux/amd64`, `linux/arm64`.

> **Note on shell access:** The default `latest` image is intentionally distroless and does not include `sh`, `ash`, or `bash`. Use the `debian` tag if you need a shell inside the container (for example, to run `docker exec` for debugging).

## Minimum run

```bash
docker run -d \
  --name sekai \
  -v sekai-data:/sekai-data \
  -p 42617:42617 \
  ghcr.io/sekai-labs/sekai:latest
```

The image expects persistent state at `/sekai-data`. On first run, it bootstraps a default config — you still need to onboard before it's useful:

```bash
docker exec -it sekai sekai onboard
```

## Compose

A minimal `docker-compose.yml`:

```yaml
services:
  sekai:
    image: ghcr.io/sekai-labs/sekai:latest
    restart: unless-stopped
    ports:
      - "42617:42617"      # gateway
    volumes:
      - ./data:/sekai-data
    environment:
      SEKAI_ALLOW_PUBLIC_BIND: "1"   # only if the gateway must be reachable on the LAN
```

After the container starts, run onboarding:

```bash
docker compose exec sekai sekai onboard
```

Drop `SEKAI_ALLOW_PUBLIC_BIND` if you only need local access.

## Config inside containers

The image expects config at `/sekai-data/.sekai/config.toml`. Mount your local config in:

```bash
docker run -d --name sekai \
  -v $(pwd)/my-config.toml:/sekai-data/.sekai/config.toml:ro \
  -v sekai-state:/sekai-data/workspace \
  -p 42617:42617 \
  ghcr.io/sekai-labs/sekai:latest
```

For container workloads, the onboarding wizard detects Docker/Podman/Kubernetes and rewrites `localhost` references in the config to `host.docker.internal` (Docker) or other container-appropriate aliases.

## Channels that poll (Telegram, email) — just work

Outbound-initiated channels don't need any special container configuration. Telegram polling, IMAP, MQTT, Nostr relays — all pull; the container only needs egress.

## Channels that receive webhooks — need ingress

Discord, Slack, GitHub, and most webhook channels need inbound HTTP. Two options:

1. **Expose the gateway** — `-p 42617:42617` + reverse proxy with TLS in front, point the webhook URL at the public address
2. **Use a tunnel** — ngrok, Cloudflare Tunnel, or Tailscale Funnel; set the tunnel URL as the webhook target

The onboarding wizard's tunnel step handles ngrok and Cloudflare directly.

## Kubernetes

Helm chart and marketplace templates are published to the [sekai-templates](https://github.com/sekai-labs/sekai-templates) repo. Typical manifest fragment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sekai
spec:
  replicas: 1
  strategy:
    type: Recreate         # Sekai is single-instance per workspace
  template:
    spec:
      containers:
        - name: sekai
          image: ghcr.io/sekai-labs/sekai:v0.7.5
          ports:
            - containerPort: 42617
          volumeMounts:
            - name: data
              mountPath: /sekai-data
          env:
            - name: SEKAI_ALLOW_PUBLIC_BIND
              value: "1"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: sekai-data
```

**Scaling:** Sekai is single-writer per workspace. Don't scale horizontally — run one instance per agent.

## Re-authenticating after logout

If you log out of the web UI while running in a container, the existing paircode becomes invalid. Generate a new one to log back in:

```bash
docker exec -it sekai sekai gateway get-paircode --new
```

For Compose deployments, use `docker compose exec` instead:

```bash
docker compose exec sekai sekai gateway get-paircode --new
```

## Gotchas

- **macOS hostname quirks (Docker Desktop, colima, Rancher Desktop).** `host.docker.internal` works out of the box on **Docker Desktop** for macOS. On **colima**, it is only reachable if you installed with `colima start --network-address` (otherwise the container can't see the host at all — connect via the VM's gateway IP, usually `192.168.5.2`, or tunnel through a shared network). **Rancher Desktop** behaves like Docker Desktop for recent versions but has had `host.docker.internal` resolve-failures on older releases. If provider calls fail with `connection refused` to `host.docker.internal`, verify with `docker run --rm alpine getent hosts host.docker.internal` — empty output means the hostname isn't resolvable and you need an explicit IP.
- **Host-side services.** If a provider is Ollama on the host, `base_url = "http://host.docker.internal:11434"` works on Docker Desktop. On Linux Docker you may need `--add-host=host.docker.internal:host-gateway`.
- **Memory persistence.** The SQLite memory file sits inside `/sekai-data/workspace/`. If you don't mount that volume, every restart loses conversation history.
- **Bind-mounting `/sekai-data`.** A host bind mount on `/sekai-data` replaces the entire image directory, including the default `config.toml` and (previously) the dashboard bundle. The dashboard is now installed at `/usr/share/sekailabs/web/dist` — outside the mount — so a bind mount no longer hides it. On first run, mount an empty host directory and the container bootstraps a fresh config; the gateway auto-detects the dashboard from its image path.
- **No hardware passthrough by default.** GPIO / USB need explicit `--device` flags (`--device /dev/ttyUSB0`), and the container user needs matching GID for `dialout`/`gpio` groups.

## Next

- [Service management](./service.md)
- [Operations → Network deployment](../ops/network-deployment.md) — tunnels, reverse proxies
