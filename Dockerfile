FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV HUSKY=0

RUN corepack enable pnpm

# ---

FROM base AS build

ENV NODE_ENV=build

WORKDIR /app

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./ && \
 apps/frontend/package.json ./apps/frontend/ && \
 apps/backend/package.json ./apps/backend/ && \
  packages/common/package.json ./packages/common/ && \
  packages/tsconfig/package.json ./packages/tsconfig/

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm fetch --frozen-lockfile
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY . .

RUN pnpm --filter=common build

# ---

FROM build AS build-frontend

RUN pnpm --filter=frontend build
RUN pnpm deploy --filter=frontend --prod --no-optional /prod/frontend

# ---

FROM build AS build-backend

RUN pnpm --filter=backend build
RUN pnpm deploy --filter=backend --prod --no-optional /prod/backend

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
