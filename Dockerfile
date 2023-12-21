FROM alpine:3.18 AS build


WORKDIR /root	WORKDIR /root


RUN apk add --update --no-cache nodejs npm	RUN apk add --update --no-cache nodejs npm


COPY package*.json ./	COPY package*.json tsconfig.json ./
COPY tsconfig.json ./	
COPY src ./src	COPY src ./src


RUN npm install	RUN npm install && \
RUN npm run build	    npm run build && \
RUN npm prune --production	    npm prune --production


FROM alpine:3.14	FROM alpine:3.18


WORKDIR /root	WORKDIR /root


COPY --from=build /root/node_modules ./node_modules	COPY --from=build /root/node_modules ./node_modules
COPY --from=build /root/dist ./dist	COPY --from=build /root/dist ./dist


RUN apk add --update --no-cache postgresql-client nodejs npm	ARG PG_VERSION='16'


ENTRYPOINT ["node", "dist/index.js"]	RUN apk add --update --no-cache postgresql${PG_VERSION}-client --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main && \
    apk add --update --no-cache nodejs npm

CMD pg_isready --dbname=$BACKUP_DATABASE_URL && \
    pg_dump --version && \
    node dist/index.js
