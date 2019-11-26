FROM node:alpine
LABEL maintainer="5547581+3ch01c@users.noreply.github.com"

ARG hubot_name="Hubot"
ARG hubot_owner="Bot Wrangler <bw@example.com>"
ARG hubot_description="Delightfully aware robutt"
ARG hubot_adapter="campfire"
ARG hubot_packages=""
ARG hubot_port=8080
ARG hubot_user="hubot"
ARG hubot_home="hubot"

# Update, upgrade, and install stuff
RUN apk add oath-toolkit-oathtool -U --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing
RUN npm i -g coffeescript yo generator-hubot

# Create hubot user & switch over to our hubot build environment
RUN adduser -h hubot -s /bin/sh -S hubot
USER hubot
WORKDIR hubot

# Set us up the environment
ENV HUBOT_ADAPTER="${hubot_adapter}"
EXPOSE ${hubot_port}

# Build hubot
RUN yo hubot --adapter="${hubot_adapter}" --name="${hubot_name}" --owner="${hubot_owner}" --description="${hubot_description}" --defaults

# Add custom scripts
COPY --chown=100 external-scripts.json .
COPY --chown=100 scripts .

# Install the things
RUN npm i
# Install external scripts packages
RUN npm i -S $(tr -d '\n' < external-scripts.json | sed -E 's/("|,|\[|\]|\n)/ /g')
# Install other packages
RUN npm i -S ${hubot_packages}

# Patch vulnerabilities
RUN npm audit fix

COPY --chown=100 entrypoint.sh .

# Run hubot
ENTRYPOINT ["sh", "-c", "./entrypoint.sh"]
