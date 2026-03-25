# SEC Filing Sentinel

An automated SEC filing monitor powered by OpenClaw and [Contextual AI](https://contextual.ai).

**OpenClaw** runs in a Docker container on a daily schedule, scraping recent SEC filings via [EDGAR RSS feeds](https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&type=&dateb=&owner=include&count=40&search_text=&action=getcompany) (with optional [Brave Search](https://brave.com/search/api/) supplement), converting them to PDFs, and uploading them to a Contextual AI datastore. You query the agent from a Jupyter notebook whenever you want insights — and optionally get briefings sent to your phone via Telegram.

## Architecture

```
+--------------------+          +-------------------------+
| Scraper (Docker)   |-- PDF -->| Contextual AI (Cloud)   |
| - EDGAR RSS feeds  |  upload  | - Datastore (indexed)   |
| - Brave Search     |          | - RAG Agent             |
| - PDF conversion   |          +------------+------------+
| - Daily schedule   |                       |
+--------------------+                       | query
                                             |
                   +-------------------------+-------------------------+
                   |                         |                         |
                   v                         v                         v
     +------------------+     +------------------+     +------------------+
     | Notebook         |     | Custom Claw      |     | OpenClaw         |
     |                  |     |                  |     |                  |
     | - On-demand      |     | - ~230 lines     |     | - Framework      |
     |   analysis       |     | - ChatGPT +      |     | - 50+ skills     |
     | - RAG vs LLM     |     |   function call  |     | - Memory         |
     |   comparison     |     | - Telegram bot   |     | - Dashboard      |
     +------------------+     +------------------+     +------------------+
                                   Part 4                   Part 5
                              "Build it yourself"      "Use a framework"
```

---

## Prerequisites

You'll need accounts and API keys from the following services before getting started.

### Required

| Service | What it's for | Sign up | Free tier? |
|---------|--------------|---------|------------|
| **Contextual AI** | Document storage + RAG agent | [contextual.ai](https://contextual.ai) | Yes (auto-provisioned with event registration) |
| **Docker Desktop** | Runs OpenClaw in an isolated container | [docker.com](https://www.docker.com/products/docker-desktop/) | Yes |
| **OpenAI** | ChatGPT-powered OpenClaw agent reasoning | [platform.openai.com](https://platform.openai.com) | Credit required |
| **Brave Search** | Web search tool for the OpenClaw agent | [brave.com/search/api](https://brave.com/search/api/) | Yes (1 query/sec, 2000/month) |

> **Note:** EDGAR RSS scraping is free and requires no API key. This is the primary data source for SEC filings.

### Optional

| Service | What it's for | Sign up | Free tier? |
|---------|--------------|---------|------------|
| **Telegram** | Chat with the agent from your phone | [telegram.org](https://telegram.org) | Yes |

---

## Quick Start

### 1. Clone the repo

```bash
git clone https://github.com/ContextualAI/openclaw_hackday.git
cd openclaw_hackday
```

### 2. Activate your Contextual AI workspace

After registration, you'll receive an email inviting you to the Contextual AI workspace. **You must click the link in that email to activate your workspace** before you can log in. Once activated:

1. Log in to your workspace at [contextual.ai](https://contextual.ai) using the same email you registered for the event
2. On the main workspace page, click **API Keys** in the left-hand tray at the bottom
3. Click the **Create** button (top right)
4. Give your API key a name and click **Create**
5. **Copy your API key immediately** — you won't be able to retrieve it after closing the window. If you lose it, you'll need to create a new one.

### 3. Set up API keys

```bash
cp example.env .env
```

Open `.env` and fill in the three keys you need for the workshop:

```env
# BRING THESE KEYS — required before we start
CONTEXTUAL_API_KEY=your-contextual-api-key
OPENAI_API_KEY=your-openai-api-key
BRAVE_API_KEY=your-brave-api-key

# AUTO-POPULATED — the notebook sets these, leave blank
DATASTORE_ID=
AGENT_ID=

# OPTIONAL — we'll set up Telegram during Part 4 if time permits
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
```

See [Telegram Setup](#telegram-setup) below for how to get the bot token and chat ID.

### 4. Set up the Python environment

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 5. Make sure Docker is running

**On Docker Desktop (Mac/Windows):** Open Docker Desktop or confirm with `docker info`.

**On the workshop IDE (Hacker Squad):** Docker Desktop isn't available — start the daemon manually:
```bash
sudo service docker start
```
The notebook uses `sudo docker-compose` for all Docker commands since the `coder` user doesn't have access to `/var/run/docker.sock` by default. The IDE has Docker Compose v1 (`docker-compose` with a hyphen), not the v2 plugin (`docker compose`).

### 6. Run the notebook

Open `openclaw_hackday.ipynb` in VS Code (or Jupyter) and run through the parts in order:

| Part | What it does | Run when |
|------|-------------|----------|
| **Part 1** | Creates the Contextual AI datastore and agent | Once (first time setup) |
| **Part 2** | Builds and launches the Custom Claw Docker container (scraper) | Each session |
| **Part 3** | Agent queries + ChatGPT comparison (Fair Fight / Unfair Fight) | Demo showcase |
| **Part 4** | Telegram integration with Custom Claw (one-shot → SEC bot → full agent) | Optional |
| **Part 5** | Switch to OpenClaw framework (one-click switcher → configure → test) | Optional |

---

## Docker Commands

OpenClaw runs in Docker to keep scraping isolated from your machine. It starts scraping immediately on launch and repeats every 24 hours.

```bash
# Build (required after changing scrape.py)
sudo docker-compose build --no-cache openclaw

# Start the container
sudo docker-compose up -d --build

# Watch the logs
sudo docker-compose logs -f openclaw

# Trigger a manual scrape
sudo docker-compose exec openclaw python scrape.py --once

# Stop everything
sudo docker-compose down
```

> **Note:** If you change `scrape.py`, you must rebuild with `--no-cache` or Docker will use the cached image with the old code.
>
> **Note:** The workshop IDE uses Docker Compose v1 (`docker-compose` with a hyphen) and requires `sudo`. If you're on Docker Desktop with Compose v2, you can use `docker compose` (no hyphen) without `sudo`. The notebook auto-detects your environment and sets the correct command automatically — no manual changes needed.

---

## Telegram Setup

Telegram notifications are optional but recommended — they let OpenClaw send SEC briefings directly to your phone.

### Step 1: Create a bot

1. Open Telegram and search for **@BotFather**
2. Send `/newbot`
3. Choose a display name (e.g. "OpenClaw SEC Alerts")
4. Choose a username (must end in `bot`, e.g. `openclaw_sec_bot`)
5. BotFather replies with your **HTTP API token** — copy it

### Step 2: Get your chat ID

1. Open a chat with your new bot and send it any message (e.g. "hello")
2. Open this URL in your browser (replace `<TOKEN>` with your token):
   ```
   https://api.telegram.org/bot<TOKEN>/getUpdates
   ```
3. In the JSON response, find `"chat":{"id":123456789}` — that number is your chat ID

### Step 3: Add to .env

```env
TELEGRAM_BOT_TOKEN=7123456789:AAF1234abcd...
TELEGRAM_CHAT_ID=123456789
```

### Step 4: Run Part 4 in the notebook

The cell queries the agent for a summary and sends it to your phone.

---

## Two Agent Versions

This project includes two ways to build the same SEC filing agent — showing the progression from "build it yourself" to "use a framework."

### Custom Claw — Build It Yourself
~230 lines of Python. ChatGPT + function calling + a Telegram polling loop. You can read every line and understand exactly what it does. No memory, no dashboard, no multi-channel — but it proves the concept.

### OpenClaw — Use a Framework
The [OpenClaw](https://github.com/openclaw/openclaw) agent framework running in Docker. Same Contextual AI backend, but with persistent memory, 50+ built-in skills, a web dashboard, multi-channel support (Telegram, Discord, Slack, WhatsApp), cron scheduling, and more. Custom skills are defined as Markdown files — no Python needed.

Both versions use the same Contextual AI datastore and agent. Part 5 of the notebook handles the switch automatically.

---

## Project Structure

```
sec_demo/
├── openclaw_hackday.ipynb                  # Main notebook — Parts 1-5 (everything)
├── docker-compose.yml         # Container orchestration for Custom Claw
├── requirements.txt           # Python deps for the notebook
├── example.env                # Template for API keys (safe to commit)
├── .env                       # Your actual keys (git-ignored)
├── .gitignore
├── README.md
│
├── custom-claw/               # "Build it yourself" agent
│   ├── src/
│   │   ├── scrape.py          # EDGAR + Brave → PDF → Contextual AI upload
│   │   ├── telegram_bot.py    # Full agent (ChatGPT + tools + Telegram)
│   │   └── telegram_sec_bot.py # SEC-only Telegram bot
│   ├── Dockerfile
│   └── requirements.txt
│
├── openclaw-agent/            # "Use a framework" agent
│   ├── skills/
│   │   ├── brave-search/SKILL.md
│   │   └── query-sec-filings/SKILL.md
│   ├── docker-compose.yml
│   ├── setup.sh
│   └── example.env
│
└── scripts/                   # Admin utilities
    ├── invite_users.py        # Bulk invite users to Contextual AI tenant
    └── remove_users.py        # Remove users from tenant
```

---

## Participant Resources

### Contextual AI

| Resource | Link |
|----------|------|
| Getting Started | https://docs.contextual.ai/quickstarts/getting-started |
| Examples & Demos | https://docs.contextual.ai/examples/overview-demos |
| Documentation | https://docs.contextual.ai/ |
| Python SDK | https://github.com/ContextualAI/contextual-client-python |
| Node SDK | https://github.com/ContextualAI/contextual-client-node |
| Agent Composer | https://contextual.ai/blog/introducing-agent-composer |
| Oryx (Agent UI) | https://github.com/ContextualAI/oryx |
| Datastore Sync | https://github.com/ContextualAI/datastore-sync |
| Demo Site | https://demo.contextual.ai/ |
| GitHub Org | https://github.com/ContextualAI |

> **Tip:** The search bar at the top of the [docs page](https://docs.contextual.ai/) is itself a Contextual AI agent — it understands the documentation better than keyword search. Use it to get precise answers about the SDK, APIs, and platform features.

### Tools & Frameworks

| Resource | Link |
|----------|------|
| Docker Desktop | https://www.docker.com/products/docker-desktop/ |
| Brave Search API | https://brave.com/search/api/ |
| OpenAI Codex CLI | https://github.com/openai/codex |
| EDGAR Full-Text Search | https://efts.sec.gov/LATEST/search-index |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Docker: `permission denied` on `/var/run/docker.sock` | Your user doesn't have access to the Docker socket. Either prefix commands with `sudo` (e.g. `sudo docker ps`) or add your user to the docker group and start a new shell: `sudo usermod -aG docker $USER && newgrp docker` |
| `429 Too Many Requests` from Brave | You're hitting the rate limit (1 req/sec on free tier). Wait a minute and retry. The scraper has built-in delays. |
| Docker build uses cached `scrape.py` | Run `docker compose build --no-cache openclaw` to force a fresh copy. |
| `QueryResource object is not callable` | Make sure you're using `client.agents.query.create(...)`, not `client.agents.query(...)`. |
| Telegram message not received | Confirm you sent a message to the bot first, and that your chat ID is correct. |
| Container logs show nothing | Python output may be buffered. The `PYTHONUNBUFFERED=1` env var in docker-compose.yml fixes this. |

---

## Codex Setup

[OpenAI Codex](https://github.com/openai/codex) is available natively in the coding platform used for this demo. This project includes an `AGENTS.md` and `.codex/config.toml` so Codex understands the codebase out of the box.

### Quick start

```bash
# Install Codex CLI (if not already available in your IDE)
npm install -g @openai/codex

# Trust this project (required for project-level MCP servers)
cd sec_demo
codex trust

# Start coding with Codex
codex
```

### What's preconfigured

| File | What it does |
|------|-------------|
| `AGENTS.md` | Gives Codex full project context: architecture, APIs, SDK patterns, env vars, and common gotchas |
| `.codex/config.toml` | Configures MCP servers — includes [Context7](https://github.com/upstash/context7) for live SDK doc lookups |

### Example prompts to try with Codex

```
# Ask about the Contextual AI SDK
"How do I create a new datastore and upload documents using the contextual-client Python SDK?"

# Ask it to build on the project
"Add a new tool to telegram_bot.py that lets the agent look up a company's latest filing by ticker symbol"

# Use Context7 for live docs
"Use context7 to look up the contextual-client Python SDK, then show me how to list all documents in a datastore"

# Debug help
"Why might the agent return empty results even though documents are uploaded?"
```

### Connecting Codex to Contextual AI docs

The `.codex/config.toml` includes a Context7 MCP server that can fetch library documentation on demand. To look up Contextual AI SDK docs, just ask Codex to "use context7 to look up contextual-client" in your prompt.

For deeper integration, you can also point Codex at the [Contextual AI docs](https://docs.contextual.ai/) directly by adding a custom MCP server or using [datastore-sync](https://github.com/ContextualAI/datastore-sync).

---

## Roadmap

- [ ] Telegram daily briefings on a schedule
- [ ] Track specific companies or filing types
- [ ] Alert on material events (executive changes, M&A, restatements)
