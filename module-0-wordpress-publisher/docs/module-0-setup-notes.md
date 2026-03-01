# WordPress Automation Setup

**What this does:** Automates WordPress article publishing on a schedule. No manual clicking.

**Tested:** March 2026
**Result:** Self-hosted version works (£8/mo). Cloud version for non-devs: coming later.

---

## What You Need

1. WordPress blog (self-hosted)
2. Hetzner VPS (CPX32 recommended, £8/mo)
3. Basic command line knowledge
4. Comfort with PostgreSQL

**Setup time:** 3 hours
**Monthly cost:** £8/mo
**Ongoing maintenance:** ~1 hour/month when something breaks

---

## Setup Steps

### 1. Set up server (Hetzner CPX32, £8/mo)
- Install n8n Community Edition (self-hosted)
- Install PostgreSQL 17.7 + pgvector
- Install Redis (optional, for rate limiting)

### 2. Build MCP server
- Clone MCP server code (Python + FastMCP)
- Install dependencies:
  ```bash
  pip install fastmcp psycopg2 requests python-dotenv
  ```
- Configure .env:
  ```
  DATABASE_URL=postgresql://user@localhost:5432/yourdb
  WORDPRESS_URL=https://yourblog.com
  WORDPRESS_USERNAME=admin
  WORDPRESS_APP_PASSWORD=your_app_password
  ```
- Run server:
  ```bash
  python3 server_sse.py
  ```
- Uses streamable-http transport on port 8000

### 3. Set up database
- Create PostgreSQL database
- Run schema (customers, articles, article_publish_log tables)
- Insert customer record with API key (generate: `openssl rand -hex 32`)
- Store WordPress credentials in database

### 4. Configure n8n workflow
- Add Schedule Trigger (cron: twice per week)
- Add HTTP Request node → MCP endpoint (http://localhost:8000/mcp)
- Call `publish_wordpress_post` tool
- Pass: api_key, title, content, status="draft"
- Test manually first

### 5. What breaks (and how to fix it)
- **"Connection refused":** MCP server not running or wrong port
- **"Invalid API key":** Check customers table, verify api_key matches
- **"WordPress auth failed":** Regenerate App Password, update database
- **"SSE deprecated":** Use streamable-http transport, not SSE

---

## What Was Tested in Module 0

✅ **n8n Community Edition supports MCP** - No enterprise license needed
✅ **MCP streamable-http transport works** - SSE is deprecated
✅ **Database-backed authentication** - API key validation via PostgreSQL
✅ **WordPress REST API publishing** - Drafts or live posts
✅ **Multi-tenant architecture** - Customer ID isolation from day 1

---

## Real Talk

**This won't make your blog successful.** It removes one tedious task (manual publishing). You still need:
- Content that people want to read
- SEO that actually works
- Affiliate links that convert
- Traffic (the hard part)
- Patience (6-12 months minimum)

Automating a bad blog just means you publish bad content faster.

**This is only worth it if you enjoy troubleshooting connection errors at 11pm.**



---

**Built for passive income seekers who want to automate the boring parts.**
