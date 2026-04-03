# Build Stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/ .
# Optional: add build step if needed
# RUN npm install && npm run build

# Final Stage - Security hardened nginx
FROM nginx:1.25-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Remove default static files
RUN rm -rf /usr/share/nginx/html/* && \
    chown -R nginx:nginx /usr/share/nginx/html /var/log/nginx /var/run/nginx

# Add custom nginx config for security and performance
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static app from builder
COPY --from=builder --chown=nginx:nginx /app /usr/share/nginx/html

# Create cache directory
RUN mkdir -p /var/cache/nginx && chown -R nginx:nginx /var/cache/nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/index.html || exit 1

# Expose port
EXPOSE 80

# Run as non-root user
USER nginx

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]