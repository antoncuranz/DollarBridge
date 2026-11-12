# syntax=docker.io/docker/dockerfile:1

FROM node:26-alpine AS builder
WORKDIR /build

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Serves the static build and proxies /api to the backend (BACKEND_URL).
FROM nginxinc/nginx-unprivileged:1.31-alpine

ENV BACKEND_URL=http://money-tracking-backend

# rendered with envsubst to /etc/nginx/conf.d/default.conf at container start
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=builder /build/dist /var/www

EXPOSE 3000
