if [ -z ${MATTERMOST_MFA_TOKEN+x} ]; then
  echo "MATTERMOST_MFA_TOKEN undefined. Attempting to generate a token..."
  if [ -z ${MATTERMOST_MFA_SEED+x} ]; then
    echo "MATTERMOST_MFA_SEED undefined. Please define MATTERMOST_MFA_SEED (the static seed you use to generate codes from your authenticator) or MATTERMOST_MFA_TOKEN (the TOTP code generated from your authenticator) in the 'docker run' command line."
    echo "  Ex: docker run -e MATTERMOST_MFA_SEED=YOUR_STATIC_MFA_SEED -e MATTERMOST_MFA_TOKEN=YOUR_GENERATED_TOTP_CODE 3ch01c/hubot"
    exit 1;
  fi
  export MATTERMOST_MFA_TOKEN=$(oathtool -b --totp $MATTERMOST_MFA_SEED)
fi
bin/hubot -a $HUBOT_ADAPTER
