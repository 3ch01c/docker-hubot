FROM node:alpine
LABEL maintainer="5547581+3ch01c@users.noreply.github.com"

ARG hubot_owner="Bot Wrangler <bw@example.com>"
ARG hubot_name="Hubot"
ENV HUBOT_NAME=${hubot_name}
ARG hubot_description="Delightfully aware robutt"
ARG hubot_adapter=""
ENV HUBOT_ADAPTER="${hubot_adapter}"
ARG hubot_packages=""
ENV HUBOT_PACKAGES="${hubot_packages}"
ARG hubot_port=8080
ARG hubot_uid=100
ARG hubot_uname="hubot"
ARG hubot_home="/hubot"
ENV HUBOT_PATH="${hubot_home}"

# Update, upgrade, and install stuff
RUN npm i -g coffeescript yo generator-hubot

# Create hubot user & switch over to our hubot build environment
RUN adduser --uid=${hubot_uid} -h "${hubot_home}" -s /bin/sh -S "${hubot_uname}"
USER ${hubot_uname}
WORKDIR ${hubot_home}

# Set us up the environment
EXPOSE ${hubot_port}

# Build hubot
RUN yo hubot --owner="${hubot_owner}" \
             --name="${hubot_name}" \
             --description="${hubot_description}" \
             --adapter="${hubot_adapter}" \
             --defaults

# Add custom scripts
COPY --chown=100 external-scripts.json .
COPY --chown=100 scripts .

# Install the things
RUN npm i
# Install external scripts packages
RUN npm i -S $(tr -d '\n' < external-scripts.json | sed -E 's/("|,|\[|\]|\n)/ /g')
# Install other packages
RUN npm i -S $HUBOT_PACKAGES
# Run hubot
ENTRYPOINT bin/hubot