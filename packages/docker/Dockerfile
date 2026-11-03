FROM node:22-alpine
LABEL org.opencontainers.image.title="uae-gold-calculator" \
      org.opencontainers.image.description="Gold value API (karat prices per gram/tola/ounce, making charge, 5% VAT, zakat) with an Arabic/English calculator page" \
      org.opencontainers.image.source="https://github.com/nbkdevs/uae-gold-prices" \
      org.opencontainers.image.url="https://uaegoldprices.ae/" \
      org.opencontainers.image.documentation="https://uaegoldprices.ae/" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.vendor="UAE Gold Prices"
WORKDIR /app
# Build context: packages/ (so the npm library is copied in, not downloaded)
COPY npm/package.json npm/README.md npm/LICENSE ./node_modules/uae-gold-calculator/
COPY npm/lib ./node_modules/uae-gold-calculator/lib
COPY docker/server.js ./
COPY docker/public ./public
ENV NODE_ENV=production PORT=8080
USER node
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://127.0.0.1:8080/healthz || exit 1
CMD ["node", "server.js"]
