FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV HUSKY=0

RUN corepack enable pnpm

# ---

FROM base AS build

ENV NODE_ENV=build

WORKDIR /app

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY apps/frontend/package.json apps/frontend/
COPY apps/backend/package.json apps/backend/
COPY packages/common/package.json packages/common/
COPY packages/tsconfig/package.json packages/tsconfig/

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm fetch --frozen-lockfile

# ---

FROM build AS build-common

COPY packages /app/packages

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --filter=common \
  && pnpm --filter=common build

# ---

FROM build-common AS build-frontend

COPY apps/frontend /app/apps/frontend

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --filter=frontend \
  && pnpm --filter=frontend build \
  && pnpm deploy --filter=frontend --prod --no-optional /prod/frontend

# ---

FROM build-common AS build-backend

COPY apps/backend /app/apps/backend

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --filter=backend \
  && pnpm --filter=backend build \
  && pnpm deploy --filter=backend --prod --no-optional /prod/backend

# ---

FROM nginx:stable-alpine AS frontend

WORKDIR /usr/share/nginx/html

COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/dist .
COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1


CMD ["nginx", "-g", "daemon off;"]

# ---

FROM base AS backend

WORKDIR /prod/backend

COPY --from=build-backend /prod/backend .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1


CMD ["node", "dist/main.js"]
