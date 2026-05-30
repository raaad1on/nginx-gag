FROM openquantumsafe/nginx:latest

RUN apk add --no-cache curl

COPY index.html /var/www/html/index.html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 444 9000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]