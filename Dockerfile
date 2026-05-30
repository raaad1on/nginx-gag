FROM openquantumsafe/nginx:latest

# Install curl for HEALTHCHECK
RUN apk add --no-cache curl

# Copy HTML files
COPY index.html /var/www/html/index.html

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy geo-base update script
COPY geo-base/update-geo-base.sh /geo-base/update-geo-base.sh
RUN chmod +x /geo-base/update-geo-base.sh

# Set proper permissions
RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html

# Expose ports
EXPOSE 444 9000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

# Start nginx via entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]