# WordPress Automation Stack (Module 0 - Dev Version)

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

## What This Doesn't Automate

❌ Writing the articles (see Module 2)
❌ Finding keywords (see Module 1)
❌ Getting traffic (SEO, see Module 4)
❌ Making money (affiliate strategy, see Module 5)
❌ Not giving up after 3 months (you're on your own)

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

## Real Talk

The automation stack costs £8/mo for self-hosted. That's cheaper than hiring a VA (£300+/mo) but more expensive than doing it manually (£0/mo + your time).

Most affiliate blogs fail because the content is bad, not because publishing is manual. This automation won't fix bad content. It just removes one excuse for not publishing consistently.

If your blog earns £200/mo in affiliate commissions, £8/mo automation is nothing. If your blog earns £0/mo (most do), you're paying £8 to automate failure.

Build the blog strategy first. Automate second.

**This is only worth it if you enjoy troubleshooting PostgreSQL connection errors at 11pm.**

---

## For Non-Developers

This setup requires:
- Server management (SSH, terminal commands)
- PostgreSQL knowledge (schemas, queries)
- Debugging skills (reading error logs)

**Cloud version for non-developers is coming later** (Modules 10+):
- Visual setup, no terminal
- Hosted database, no PostgreSQL knowledge needed
- Estimated cost: £30-70/mo (n8n Cloud + MCP service)

If you're non-technical, bookmark this and wait for the cloud version.

---

**Module 0 tested and documented: March 2026**
**For passive income seekers who want to automate the boring parts.**
**Dev version working. Non-dev version: TBD.**
