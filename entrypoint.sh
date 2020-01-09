# Install the things
npm i
# Install external scripts packages
npm i -S $(tr -d '\n' < external-scripts.json | sed -E 's/("|,|\[|\]|\n)/ /g')
# Install other packages
npm i -S $HUBOT_PACKAGES hubot-$HUBOT_ADAPTER
bin/hubot -a $HUBOT_ADAPTER
