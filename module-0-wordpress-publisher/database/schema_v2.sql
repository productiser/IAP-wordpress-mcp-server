-- =====================================================
-- PREREQUISITES
-- =====================================================
-- CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================
-- 1. CUSTOMERS (Core  table)
-- =====================================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    api_key VARCHAR(64) UNIQUE NOT NULL,  -- For MCP authentication

    -- Customer identity
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) UNIQUE NOT NULL,

    -- Blog configuration
    blog_name VARCHAR(255) NOT NULL,     -- e.g., "mobiledeals", "fitnessfromhome"
    niche VARCHAR(255) NOT NULL,          -- e.g., "AI automation", "fitness supplements"
    wordpress_url VARCHAR(512) NOT NULL,  -- e.g., "https://mobiledelas.co.uk"
    wordpress_username VARCHAR(255) NOT NULL,  -- Encrypted in app
    wordpress_app_password TEXT NOT NULL,  -- Encrypted in app (WordPress app password)

    -- Localization (v2)
    target_location VARCHAR(50) DEFAULT 'United Kingdom',
    target_language VARCHAR(10) DEFAULT 'en',

    -- Subscription configuration
    subscription_status VARCHAR(50) DEFAULT 'active',  -- active/paused/cancelled
    posts_per_week INT DEFAULT 2,         -- Default 2 posts/week, max 30/month
    monthly_post_limit INT DEFAULT 30,    -- Hard cap enforced by MCP
    auto_publish BOOLEAN DEFAULT TRUE,    -- Publish automatically or draft-only

    -- Payment (Stripe integration)
    stripe_customer_id VARCHAR(255) UNIQUE,
    stripe_subscription_id VARCHAR(255),
    failed_payment_count INT DEFAULT 0,

    -- Legacy GDPR fields (migrated to customer_consents table)
    terms_accepted BOOLEAN DEFAULT FALSE,
    terms_accepted_at TIMESTAMP,
    privacy_policy_accepted BOOLEAN DEFAULT FALSE,
    privacy_policy_accepted_at TIMESTAMP,
    data_processing_consent BOOLEAN DEFAULT FALSE,
    data_processing_consent_at TIMESTAMP,

    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_customers_api_key ON customers(api_key);
CREATE INDEX idx_customers_email ON customers(customer_email);
CREATE INDEX idx_customers_status ON customers(subscription_status);
CREATE INDEX idx_customers_stripe ON customers(stripe_customer_id);

COMMENT ON TABLE customers IS 'Multi-tenant customer accounts (Path A students +   blog)';
COMMENT ON COLUMN customers.target_location IS 'Target country for keyword research (default: United Kingdom)';
COMMENT ON COLUMN customers.target_language IS 'Target language for content (default: en)';
COMMENT ON COLUMN customers.monthly_post_limit IS 'Hard cap: 30 posts/month (default 2/week = 8-10 posts)';

-- =====================================================
-- 5. ARTICLES (Published articles per customer)
-- =====================================================
CREATE TABLE articles (
    article_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    category_id INT REFERENCES content_categories(category_id) ON DELETE SET NULL,
    title VARCHAR(512) NOT NULL,
    content_hash VARCHAR(64) NOT NULL,  -- SHA256 hash to detect duplicates
    wordpress_post_id INT,  -- Post ID from WordPress REST API
    keyword_used VARCHAR(255),  -- Primary keyword for this article

    -- Multi-modal tracking (v2)
    has_images BOOLEAN DEFAULT FALSE,
    contrarian_count INT DEFAULT 0,

    published_at TIMESTAMP,
    performance_metrics JSONB DEFAULT '{}',  -- {views: 0, clicks: 0, conversions: 0} - synced from GA4/GSC
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_articles_customer ON articles(customer_id);
CREATE INDEX idx_articles_category ON articles(category_id);
CREATE INDEX idx_articles_published ON articles(customer_id, published_at DESC);
CREATE INDEX idx_articles_content_hash ON articles(content_hash);
CREATE INDEX idx_articles_keyword ON articles(keyword_used);

COMMENT ON TABLE articles IS 'Published blog articles per customer';
COMMENT ON COLUMN articles.has_images IS 'TRUE if article has AI-generated images (Stability AI)';
COMMENT ON COLUMN articles.contrarian_count IS 'Number of Reddit/Twitter contrarian quotes injected';

-- =====================================================
-- 12. ARTICLE_PUBLISH_LOG (Audit trail for publishing)
-- =====================================================
CREATE TABLE article_publish_log (
    log_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    article_id INT REFERENCES articles(article_id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,  -- publish, draft, update, delete
    status VARCHAR(50) NOT NULL,  -- success, failed, warning
    wordpress_post_id INT,
    error_message TEXT,
    metadata JSONB DEFAULT '{}',  -- {trigger: "scheduled", user: "system", duration_ms: 1234}
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_publish_log_customer ON article_publish_log(customer_id);
CREATE INDEX idx_publish_log_article ON article_publish_log(article_id);
CREATE INDEX idx_publish_log_status ON article_publish_log(customer_id, status, created_at DESC);

COMMENT ON TABLE article_publish_log IS 'Audit trail for all article publishing actions';

