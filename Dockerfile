# ── Etapa 1: builder ──────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

# ── Etapa 2: runtime ──────────────────────────────────────────
FROM node:20-alpine AS runtime

WORKDIR /app

# Copiar solo las dependencias instaladas y el código fuente
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
COPY db/ ./db/
COPY package.json ./

# Ejecutar como usuario no root
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD wget -qO- http://127.0.0.1:3000/health || exit 1

CMD ["node", "src/server.js"]