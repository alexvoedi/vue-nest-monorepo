FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV HUSKY=0

RUN corepack enable pnpm

# ---

FROM base AS build

ENV NODE_ENV=build

WORKDIR /app

COPY . .

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm fetch --frozen-lockfile
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --filter=common

RUN pnpm --filter=common build

# ---

FROM build AS build-frontend

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=frontend install --frozen-lockfile --offline
RUN pnpm --filter=frontend build
RUN pnpm deploy --filter=frontend --prod /prod/frontend

# ---

FROM build AS build-backend

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=backend install --frozen-lockfile --offline
RUN pnpm --filter=backend build
RUN pnpm deploy --filter=backend --prod /prod/backend

# ---

FROM nginx:stable-alpine AS frontend

WORKDIR /usr/share/nginx/html

COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/dist .
COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1


CMD ["nginx", "-g", "daemon off;"]

# ---

FROM base AS backend

WORKDIR /prod/backend

COPY --from=build-backend /prod/backend .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost:3000/health || exit 1


CMD ["node", "dist/main.js"]
