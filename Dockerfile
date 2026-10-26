# ── OpenFlashcards – single-container Docker image ──────────────────────────
# Build:  docker build -t openflashcards .
# Run:    docker compose up --build -d
# Or:     docker run -d -p 8000:8000 \
#           -v ./data:/app/data -v ./config:/app/config \
#           -e JWT_SECRET=... --name openflashcards openflashcards

FROM node:20-alpine

LABEL org.opencontainers.image.title="OpenFlashcards"
LABEL org.opencontainers.image.description="A lightweight, responsive web application for language learning with flashcards, progress and TTS"
LABEL org.opencontainers.image.version="2026.10.2"

WORKDIR /app

# Install dependencies first (layer cache). Lockfile = reproducible builds.
# --ignore-scripts: postinstall builds phosphor into public/vendor (already in image).
COPY package.json package-lock.json ./
RUN npm install --omit=dev --ignore-scripts && npm cache clean --force

COPY src/     ./src/
COPY public/  ./public/

# Overridden by volume mounts on real deployments
RUN mkdir -p /app/data /app/config

ENV NODE_ENV=production \
  PORT=8000 \
  DATA_DIR=/app/data \
  CONFIG_DIR=/app/config

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8000/').then((r)=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "src/server.js"]
