FROM node:22-alpine AS base

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
ENV HUSKY=0

RUN corepack enable pnpm

# ---

FROM base AS build

ENV NODE_ENV=build

COPY . /app

WORKDIR /app

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

RUN pnpm --filter=common build

# ---

FROM build AS build-frontend

RUN pnpm --filter=frontend build
RUN pnpm deploy --filter=frontend --prod /prod/frontend

# ---

FROM build AS build-backend

RUN pnpm --filter=backend build
RUN pnpm deploy --filter=backend --prod /prod/backend

# ---

FROM nginx:stable-alpine AS frontend

WORKDIR /usr/share/nginx/html

COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/dist .
COPY --chown=nginx:nginx --from=build-frontend /prod/frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# ---

FROM base AS backend

WORKDIR /prod/backend

COPY --from=build-backend /prod/backend .

EXPOSE 3000

CMD ["node", "dist/main.js"]
