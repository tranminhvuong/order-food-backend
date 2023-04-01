###################
# BUILD FOR LOCAL DEVELOPMENT
###################
FROM node:16-alpine As development
# Create app directory
WORKDIR /usr/src/app
RUN chown -R node:node /usr/src/app
COPY --chown=node:node package*.json ./
COPY --chown=node:node yarn.lock ./
RUN yarn
# RUN npm ci
# Bundle app source
COPY --chown=node:node . .
# Use the node user from the image (instead of the root user)
USER node
EXPOSE 3000

###################
# BUILD FOR PRODUCTION
###################
FROM node:16-alpine As build
WORKDIR /usr/src/app
COPY --chown=node:node package*.json ./
COPY --chown=node:node yarn.lock ./
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .
# Run the build command which creates the production bundle
RUN yarn
RUN yarn run build

# Set NODE_ENV environment variable
ENV NODE_ENV dev
# Running `npm ci` removes the existing node_modules directory and passing in --only=production ensures that only the production dependencies are installed. This ensures that the node_modules directory is as optimized as possible
# RUN npm ci --only=production && npm cache clean --force

USER node

###################
# PRODUCTION
###################
FROM node:16-alpine As production
USER node
WORKDIR /usr/src/app
# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
# COPY --chown=node:node --from=build /usr/src/app/src/certs ./src/certs
COPY --chown=node:node --from=build /usr/src/app/package*.json ./
COPY --chown=node:node --from=build /usr/src/app/.env ./

WORKDIR /usr/src/app/
# Start the server using the production build
CMD [ "node", "dist/app/main.js" ]
