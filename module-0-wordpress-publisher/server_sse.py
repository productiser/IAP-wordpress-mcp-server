#!/usr/bin/env python3
"""MCP server with SSE transport for WordPress publishing"""

import os
import sys
import requests
import psycopg2
from pathlib import Path
from typing import Any, Optional
from fastmcp import FastMCP
from dotenv import load_dotenv
from psycopg2.extras import RealDictCursor

# Load environment variables from parent directory (mcp-servers/.env)
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

# Create MCP server with FastMCP
mcp = FastMCP("wordpress-mcp")


# Database helper functions
def get_customer_by_api_key(api_key: str) -> Optional[dict]:
    """
    Validate API key and fetch customer WordPress credentials from database.

    Args:
        api_key: Customer API key from customers table

    Returns:
        Dictionary with customer_id, wordpress_url, wordpress_username, wordpress_app_password
        or None if API key is invalid or subscription is not active
    """
    try:
        conn = psycopg2.connect(os.getenv("DATABASE_URL"))
        cur = conn.cursor(cursor_factory=RealDictCursor)

        cur.execute(
            """SELECT customer_id, wordpress_url, wordpress_username,
                      wordpress_app_password, customer_name
               FROM customers
               WHERE api_key = %s AND subscription_status = 'active'""",
            (api_key,)
        )

        customer = cur.fetchone()
        cur.close()
        conn.close()

        return dict(customer) if customer else None

    except Exception as e:
        print(f"❌ Database error: {str(e)}", file=sys.stderr)
        return None


def log_publish_attempt(customer_id: int, article_id: Optional[int], action: str,
                       status: str, wordpress_post_id: Optional[int] = None,
                       error_message: Optional[str] = None) -> None:
    """
    Log article publishing attempt to article_publish_log table.

    Args:
        customer_id: Customer ID
        article_id: Article ID (if available)
        action: Action performed (publish, draft, update, delete)
        status: Status of action (success, failed, warning)
        wordpress_post_id: WordPress post ID if successful
        error_message: Error message if failed
    """
    try:
        conn = psycopg2.connect(os.getenv("DATABASE_URL"))
        cur = conn.cursor()

        cur.execute(
            """INSERT INTO article_publish_log
               (customer_id, article_id, action, status, wordpress_post_id, error_message, metadata)
               VALUES (%s, %s, %s, %s, %s, %s, %s)""",
            (customer_id, article_id, action, status, wordpress_post_id, error_message,
             '{"trigger": "mcp_tool", "source": "wordpress_publisher"}')
        )

        conn.commit()
        cur.close()
        conn.close()

    except Exception as e:
        print(f"⚠️  Failed to log publish attempt: {str(e)}", file=sys.stderr)


# Tool: Publish WordPress Post
@mcp.tool()
async def publish_wordpress_post(
    api_key: str,
    title: str,
    content: str,
    status: str = "draft"
) -> dict[str, Any]:
    """
    Publish a post to WordPress via REST API (requires API key authentication).

    Args:
        api_key: Customer API key from customers table (required for authentication)
        title: Post title
        content: Post content (HTML or plain text)
        status: Post status - 'publish', 'draft', or 'pending' (default: draft)

    Returns:
        Dictionary with success status, post_id, post_url, and post_title
    """
    print(f"📝 Publishing post: {title}", file=sys.stderr)

    # Authenticate and get customer credentials from database
    customer = get_customer_by_api_key(api_key)

    if not customer:
        error_msg = "Invalid API key or inactive subscription"
        print(f"❌ {error_msg}", file=sys.stderr)
        log_publish_attempt(0, None, "publish", "failed", error_message=error_msg)
        return {
            "success": False,
            "error": error_msg
        }

    # Extract WordPress credentials from customer record
    customer_id = customer['customer_id']
    wp_url = customer['wordpress_url']
    wp_username = customer['wordpress_username']
    wp_password = customer['wordpress_app_password']

    print(f"✅ Authenticated: {customer['customer_name']} (customer_id: {customer_id})", file=sys.stderr)

    # Prepare WordPress REST API request
    api_url = f"{wp_url}/wp-json/wp/v2/posts"
    headers = {
        "Content-Type": "application/json",
    }

    post_data = {
        "title": title,
        "content": content,
        "status": status,
    }

    try:
        # Make request to WordPress REST API
        response = requests.post(
            api_url,
            json=post_data,
            headers=headers,
            auth=(wp_username, wp_password),
            timeout=30
        )

        response.raise_for_status()
        result = response.json()

        wordpress_post_id = result.get("id")
        post_url = result.get("link")

        print(f"✅ Post published: {post_url}", file=sys.stderr)

        # Log successful publish
        log_publish_attempt(
            customer_id=customer_id,
            article_id=None,  # Will be set when article record is created
            action=status,
            status="success",
            wordpress_post_id=wordpress_post_id
        )

        return {
            "success": True,
            "customer_id": customer_id,
            "post_id": wordpress_post_id,
            "post_url": post_url,
            "post_title": result.get("title", {}).get("rendered"),
            "status": result.get("status"),
        }

    except requests.exceptions.HTTPError as e:
        error_msg = f"WordPress API error: {e.response.status_code}"
        if e.response.status_code == 401:
            error_msg += " - Authentication failed (check credentials)"
        elif e.response.status_code == 403:
            error_msg += " - Permission denied"

        print(f"❌ {error_msg}", file=sys.stderr)

        # Log failed publish attempt
        log_publish_attempt(
            customer_id=customer_id,
            article_id=None,
            action=status,
            status="failed",
            error_message=error_msg
        )

        return {
            "success": False,
            "error": error_msg,
            "status_code": e.response.status_code
        }

    except requests.exceptions.RequestException as e:
        error_msg = f"Request failed: {str(e)}"
        print(f"❌ {error_msg}", file=sys.stderr)

        # Log failed publish attempt
        log_publish_attempt(
            customer_id=customer_id,
            article_id=None,
            action=status,
            status="failed",
            error_message=error_msg
        )

        return {
            "success": False,
            "error": error_msg
        }


if __name__ == "__main__":
    print("🚀 WordPress MCP server starting...", file=sys.stderr)
    print(f"   WordPress URL: {os.getenv('WORDPRESS_URL', 'https://earnwithai.co.uk')}", file=sys.stderr)

    # Run with Streamable HTTP transport on port 8000 (recommended for production)
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8000)
