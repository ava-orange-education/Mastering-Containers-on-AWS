# ============================================================================
# Production Dockerfile for Node.js Application
# Book: Mastering Container Architectures on AWS - Chapter 2
#
# Best practices for Node.js containers:
#   1. Use specific Alpine-based Node.js image
#   2. Copy package.json first for dependency layer caching
#   3. Use npm ci (clean install) for reproducible builds
#   4. Run as non-root user (node user built into official image)
#   5. Set NODE_ENV=production to skip devDependencies
# ============================================================================

FROM node:20-alpine

# Set production environment
ENV NODE_ENV=production \
    PORT=3000

WORKDIR /app

# Copy dependency manifests first (layer caching)
COPY package.json package-lock.json* ./

# Install production dependencies only (npm ci is faster and deterministic)
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY app.js .

# Use the built-in 'node' user (UID 1000) from the official Node.js image
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

CMD ["node", "app.js"]
