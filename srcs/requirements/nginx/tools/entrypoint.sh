#!/bin/sh

# Create nginx user if it doesn't exist
adduser -D -s /bin/false nginx 2>/dev/null || true

# Ensure directories exist with correct permissions
mkdir -p /var/log/nginx /var/lib/nginx /run/nginx
chown -R nginx:nginx /var/log/nginx /var/lib/nginx /run/nginx

# Test nginx configuration
nginx -t

# Start nginx in foreground
exec nginx -g "daemon off;"