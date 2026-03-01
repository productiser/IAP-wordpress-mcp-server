# WordPress Automation Stack

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│              AUTOMATED BLOG PUBLISHING (DEV VERSION)             │
└─────────────────────────────────────────────────────────────────┘

                         ┌──────────────┐
                         │   Schedule   │
                         │  (Tue/Thu)   │
                         └──────┬───────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │        n8n            │
                    │  Community Edition    │
                    │  (Self-hosted)        │
                    │                       │
                    │  Triggers on schedule │
                    │  Calls MCP tools      │
                    └───────────┬───────────┘
                                │
                                │ HTTP Request
                                ▼
                    ┌───────────────────────┐
                    │     MCP Server        │
                    │  (Python/FastMCP)     │
                    │                       │
                    │  - Validates API key  │
                    │  - Fetches WP creds   │
                    │  - Publishes article  │
                    └───────────┬───────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
                    ▼                       ▼
        ┌───────────────────┐   ┌──────────────────┐
        │   PostgreSQL      │   │   WordPress      │
        │   + pgvector      │   │   REST API       │
        │                   │   │                  │
        │  - Customers      │   │  Publishes post  │
        │  - API keys       │   │  Returns post ID │
        │  - WP credentials │   │                  │
        │  - Publish logs   │   │                  │
        └───────────────────┘   └──────────────────┘
```

---

## Full Stack (Self-Hosted on Hetzner CPX32)

```
┌─────────────────────────────────────────┐
│    Hetzner CPX32 VPS (£8/mo)           │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  n8n Community Edition (Free)    │  │
│  │  - Self-hosted                   │  │
│  │  - Visual workflows              │  │
│  └────────────┬─────────────────────┘  │
│               │                         │
│  ┌────────────▼─────────────────────┐  │
│  │  MCP Server (Python/FastMCP)     │  │
│  │  - Custom built                  │  │
│  │  - Streamable-http transport     │  │
│  │  - Port 8000                     │  │
│  └────────────┬─────────────────────┘  │
│               │                         │
│  ┌────────────▼─────────────────────┐  │
│  │  PostgreSQL 17.7 + pgvector      │  │
│  │  - Customer data                 │  │
│  │  - API keys                      │  │
│  │  - WordPress credentials         │  │
│  │  - Multi-tenant ready            │  │
│  └──────────────────────────────────┘  │
│                                         │
└──────────────┬──────────────────────────┘
               │
               │ WordPress REST API
               ▼
┌─────────────────────────────────────────┐
│      Your WordPress Blog                │
│  (Self-hosted or managed)               │
└─────────────────────────────────────────┘

MONTHLY COST: £8
SETUP TIME: 3 hours
MAINTENANCE: ~1 hour/month
```

---

## What This Automates

✅ WordPress article publishing on schedule
✅ Draft or live publishing (your choice)
✅ Multi-blog support (if you have multiple blogs)
✅ API key authentication (secure, multi-tenant)
✅ Publish logging (audit trail in database)



---

## Technology Choices

**Why n8n?**
- Visual workflow builder (non-devs can eventually use cloud version)
- Community Edition supports MCP (no enterprise license needed)
- Self-hostable (£8/mo vs Zapier's £50+/mo)
- Active community, good docs

**Why MCP?**
- Tool-based architecture (easier to teach later)
- Works with Claude AI (useful for Module 2)
- Streamable-http transport (production-ready, Feb 2026)
- Multi-tenant ready from day 1

**Why PostgreSQL?**
- Multi-tenant architecture (when you sell MCP service to students)
- pgvector support (for Module 3: brand voice embeddings)
- Free, battle-tested, well-documented

**Why Hetzner?**
- Cheapest EU hosting (£8/mo for CPX32)
- Good uptime, fast network
- No vendor lock-in

---

