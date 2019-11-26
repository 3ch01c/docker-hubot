if [ -z ${MATTERMOST_ACCESS_TOKEN+x} ]; then
  if [ -z ${MATTERMOST_USER+x} ]; then
    echo "In order to log in, MATTERMOST_USER or MATTERMOST_ACCESS_TOKEN must be defined."
    echo "  Ex: docker run -e MATTERMOST_USER=YOUR_BOT_NAME 3ch01c/hubot"
    exit 1
  fi
  if [ -z ${MATTERMOST_PASSWORD+x} ]; then
    echo "In order to log in, MATTERMOST_PASSWORD or MATTERMOST_ACCESS_TOKEN must be defined."
    echo "  Ex: docker run -e MATTERMOST_PASSWORD=YOUR_BOT_PASSWORD 3ch01c/hubot"
    echo "      docker run -e MATTERMOST_ACCESS_TOKEN=YOUR_BOT_TOKEN 3ch01c/hubot"
    exit 1
  fi
  if [ -z ${MATTERMOST_MFA_TOKEN+x} ]; then
    if [ -z ${MATTERMOST_MFA_SEED+x} ]; then
      echo "In order to use MFA, MATTERMOST_MFA_SEED (the static seed you use to generate codes from your authenticator) or MATTERMOST_MFA_TOKEN (the TOTP code generated from your authenticator) must be defined."
      echo "  Ex: docker run -e MATTERMOST_MFA_SEED=YOUR_STATIC_MFA_SEED 3ch01c/hubot"
      echo "      docker run -e MATTERMOST_MFA_TOKEN=YOUR_GENERATED_TOTP_CODE 3ch01c/hubot"
    else
      echo "Attempting to generate MATTERMOST_MFA_TOKEN..."
      export MATTERMOST_MFA_TOKEN=$(oathtool -b --totp $MATTERMOST_MFA_SEED)
      echo "Attempting to log in with MATTERMOST_MFA_TOKEN..."
    fi
  else
    echo "Attempting to log in with MATTERMOST_MFA_TOKEN..."
  fi
else
  echo "Attempting to log in with MATTERMOST_ACCESS_TOKEN $MATTERMOST_ACCESS_TOKEN..."
fi
bin/hubot -a $HUBOT_ADAPTER
