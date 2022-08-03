FROM node:lts-alpine AS production-base
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app
COPY . .
RUN yarn install --frozen-lockfile

FROM node:lts-alpine AS app
WORKDIR /usr/src/app
RUN apk add --no-cache libc6-compat

COPY --from=production-base /usr/src/app .

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}
ENV APP_PORT 8000
EXPOSE ${APP_PORT}

CMD yarn start:prod
