
INSERT INTO customers (
    api_key,
    customer_name,
    customer_email,
    blog_name,
    niche,
    wordpress_url,
    wordpress_username,
    wordpress_app_password,
    target_location,
    target_language,
    subscription_status,
    posts_per_week,
    monthly_post_limit,
    auto_publish,
    stripe_customer_id,
    stripe_subscription_id,
    terms_accepted,
    terms_accepted_at,
    privacy_policy_accepted,
    privacy_policy_accepted_at,
    data_processing_consent,
    data_processing_consent_at,
    created_at
)
VALUES (
    'REPLACE_WITH_API_KEY',  -- Generate: openssl rand -hex 32
    'NAME',
    'EMAIL ID',
    'BLOGNAME',
    'NICHE',
    'URL',
    'REPLACE_WITH_WP_USERNAME',
    'REPLACE_WITH_WP_APP_PASSWORD',  -- WordPress Application Password (not regular password)
    'United Kingdom',  -- Target location for keyword research
    'en',  -- Target language
    'active',
    3,  -- 3 posts per week (Tue/Thu/Sat)
    30,  -- 30 posts max per month
    TRUE,  -- Auto-publish enabled
    NULL,  -- Stripe customer ID (will be set when Stripe integration is active)
    NULL,  -- Stripe subscription ID (will be set when Stripe integration is active)
    TRUE,  -- Terms accepted
    NOW(),
    TRUE,  -- Privacy policy accepted
    NOW(),
    TRUE,  -- GDPR data processing consent
    NOW(),
    NOW()
);

