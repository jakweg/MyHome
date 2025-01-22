FROM node:23
WORKDIR /app
COPY package*.json ./
RUN npm i --registry=https://registry.npmjs.org/
COPY src src/
CMD node src/main.js