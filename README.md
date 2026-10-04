# MCP Inspector

A shared, always-on [MCP Inspector](https://github.com/modelcontextprotocol/inspector) for every
local MCP server, served through [nginx-proxy](https://github.com/ionghitun/nginx-proxy) at
https://mcp-inspector.local. **Local development only** — the Inspector spawns processes and holds
a token for every server you add, so there is no production overlay.

## Installation

1. Create the env file and fill in `MCP_INSPECTOR_UI_PASSWORD` and `MCP_INSPECTOR_API_TOKEN`
   (`openssl rand -hex 32`):
   ```bash
   cp scripts/.env.example scripts/.env
   ```
2. Add the hostname to the hosts file (Windows: `C:\Windows\System32\drivers\etc\hosts`):
   ```
   127.0.0.1 mcp-inspector.local
   ```
3. Start it:
   ```bash
   sh scripts/start.sh
   ```
4. Open `https://mcp-inspector.local/?MCP_INSPECTOR_API_TOKEN=<MCP_INSPECTOR_API_TOKEN>`, log in
   with `MCP_INSPECTOR_UI_USERNAME` / `MCP_INSPECTOR_UI_PASSWORD`, and bookmark the URL.

## Available scripts

```bash
./scripts/start.sh    # Generate .secret-key, .htpasswd and the hosts overlay, start the containers
./scripts/down.sh     # Stop the containers
./scripts/restart.sh  # Regenerate .htpasswd from .env, restart the containers
```

## How it is put together

- `mcp-inspector-nginx` is the only container on the `nginx-proxy` network. It adds Basic Auth and
  disables response buffering, which the Inspector's event streams need.
- `mcp-inspector-app` publishes no port and sits only on the stack's own network.
- **Why Basic Auth rather than an IP allow-list:** nginx-proxy publishes 443 on every interface, so
  other devices on the same network reach it too, and under Docker Desktop local clients arrive from
  the Docker gateway IP rather than their own — an allow-list has nothing reliable to match on.
- `data/` holds the server catalog (`mcp.json`) and the secret store (`secrets.json`), encrypted
  with `scripts/.secret-key`. Do not regenerate that key: the stored secrets would become unreadable.
- **Header values are not secrets to the Inspector:** only OAuth client secrets and stdio `env`
  values go to the encrypted store. A bearer token added as an `Authorization` header stays in
  plain text in `data/mcp.json` (mode 0600, gitignored).

## Adding an MCP server

1. If its hostname is a local one (`*.local`), add it to `MCP_SERVER_HOSTS` in `scripts/.env`
   (comma separated) and run `sh scripts/start.sh`. Inside a container a `.local` name resolves to
   the container's own loopback; this maps it to the host gateway, so it reaches nginx-proxy.
   `start.sh` regenerates `scripts/docker-compose.hosts.yml` (gitignored) from that variable;
   `restart.sh` is not enough, because extra_hosts are applied when the container is created.
2. In the UI, add the server: Streamable HTTP, its URL, and an `Authorization: Bearer ...` header
   with a token issued by that application. The Inspector writes it to `data/mcp.json` — there is
   nothing to edit by hand.

Servers using **stdio** (a local command such as `php artisan mcp:start ...`) cannot run here — the image has
only Node. Use the Inspector on the host for those. This stack publishes no port, so the default
6274 is free and the two run side by side, each with its own catalog (`~/.mcp-inspector` on the
host, `data/` here):

```bash
NODE_EXTRA_CA_CERTS=~/services/nginx-proxy/certs/nginx-proxy-ca.crt npx @modelcontextprotocol/inspector
```

## Refreshing tools

A server that declares `tools.listChanged: false` never tells the Inspector its tools changed —
press "List Tools" again. Servers that re-read their code per request show the change at once;
no reconnect is needed.
