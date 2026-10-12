FROM node:20-alpine

WORKDIR /app

# better-sqlite3 may need to compile native code
RUN apk add --no-cache python3 make g++

COPY backend/package*.json ./
RUN npm ci --omit=dev

COPY backend/ ./

ENV PORT=5000
EXPOSE 5000

CMD ["node", "src/app.js"]
