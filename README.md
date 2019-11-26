# hubot-docker
This is a Dockerized version of [Hubot](https://github.com/hubotio/hubot).

## How to run it
If you use [docker-compose](https://docs.docker.com/compose/) or something similar, you can get everything going pretty quick using the provided [docker-compose.yml](docker-compose.yml). You might want to at least review the sections about [security](#security) and [chat adapters](#chat-adapters) first, though.

``` sh
docker-compose up
```

<a name="security"></a>
## About security

### Passwords and other environment configurations
Passwords, MFA tokens, session tokens, usernames, hostnames, and all that other good stuff about your chat environment are configured via [environment variables](#env).

### Unprivileged container user
The `hubot` container is set up to run as the user `hubot` with uid 100. This limits the container's access to the host, which is supposed to be more secure, but you'll also need to remember to give uid 100 access to any bind mounts if you add them.

<a name="chat-adapters"></a>
## About chat adapters

By default, it uses the [hubot-slack](https://github.com/slackapi/hubot-slack) adapter, which means you'll need to provide [a Slack API token](https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens).

``` sh
docker run -d -e "HUBOT_SLACK_TOKEN=YOUR_HUBOT_SLACK_TOKEN" --name hubot hubot
```

There's a gajillion [adapters](https://www.npmjs.com/search?q=hubot%20adapter), so if Slack isn't your thing, you can probably find one for whatever chat platform you're using, and [customize Hubot to use it](#customization).

<a name="persistence"></a>
## About persistence

By default, Hubot wants a Redis instance for persistent memory. If you don't have one, you can start one up in a container.

``` sh
docker run -d --name "redis" -v "data:/data" redis:alpine "redis-server --appendonly yes"
```

You'll also need to provide a `REDIS_URL` parameter to your Hubot.

``` sh
docker run -d -e "HUBOT_SLACK_TOKEN=YOUR_HUBOT_SLACK_TOKEN" -e "REDIS_URL=redis://localhost:6379/hubot" --name hubot hubot
```

The [docker-compose.yml](docker-compose.yml) will wire up all this for you. By default, memory is stored in the file [data/appendonly.aof](data/appendonly.aof) so just make sure that goes wherever the bot goes.

<a name="customization"></a>
## About customization

### Configuring environment variables
With Docker, there's two kinds of variables, _build_ and _runtime_.

#### Build environment variables
You'll probably only mess with build arguments if you need to change the [chat adapter](#chat-adapters).

``` sh
docker build -t hubot:mattermost --build-arg hubot_adapter="hubot-matteruser" .
```

For the curious, here's what the rest of those build variables in [`docker-compose.yml`](docker-compose.yml) do:
* `hubot_name`: The name the bot responds to.
* `hubot_owner`: I'm not sure how this gets used, but feel free to change it to your info if you want.
* `hubot_description`: Again, not sure where this gets used
* `hubot_adapter`: The name of the chat adapter you want to use, without the `hubot-` prefix.
* `hubot_packages`: A space-separated list of additional NPM packages to install. I use this when I'm developing scripts to install their dependencies.
* `hubot_port`: The port for Hubot's web server. Some scripts like [hubot-help](https://github.com/hubotio/hubot-help) also reference this. Keep in mind that since this is running in a container, you'll need to make sure `hubot_port` is directly mapped (e.g., `docker run -p $hubot_port:$hubot_port`)

<a name="env"></a>
#### Runtime environment variables
Runtime variables are used for authentication, configuring scripts, and pretty much any other configuration. Here's a few ways you can go about setting them.

#### Option 1 (recommended)
Add your environment variables to a [`.env`](https://docs.docker.com/compose/environment-variables/#the-env-file) file.

```
REDIS_URL=redis://redis:6379/hubot
HUBOT_SLACK_TOKEN=YOUR_HUBOT_SLACK_TOKEN
```

`docker-compose` will use the `.env` file implicitly.

#### Option 2

If you want multiple configurations (i.e., for multiple bots), you can create `config1.env`, `config2.env`, etc. and use the [`env_file`](https://docs.docker.com/compose/environment-variables/#the-env_file-configuration-option) configuration option in `docker-compose.yml`.

```
env_file:
    - config1.env
```

#### Option 3
Edit variables directly in the `environment` section of [`docker-compose.yml`](docker-compose.yml).

```
environment:
  - REDIS_URL=redis://redis:6379/hubot
  - HUBOT_SLACK_TOKEN=YOUR_HUBOT_SLACK_TOKEN
```

#### Option 4
Use [swarm service configs](https://docs.docker.com/engine/swarm/configs/), but I'm not gonna get into that.

To understand more about environment variables in Docker, read the [documentation](https://docs.docker.com/compose/environment-variables/).

#### About programmatically defining variables
A limitation of setting variables in `docker-compose.yml` is that you can't set variables programmatically. However, `docker-compose` will inherit undefined variables the host environment which you _can_ define programmatically. Here's a sweet example that lets you generate a MFA token before starting up the bot.

```
MY_MFA_TOKEN=$([ -n "$MY_MFA_SEED_FILE" ] && read -r MY_MFA_SEED < $MY_MFA_SEED_FILE && oathtool -b --totp $MY_MFA_SEED) docker-compose up
```

### Adding third-party scripts
There's a ton of [hubot-scripts](https://www.npmjs.com/search?q=hubot-scripts) available to extend Hubot's functionality. Just add them to [external-scripts.json](external-scripts.json) and rebuild the container.

``` sh
gsed -i '/\[/a \  "hubot-factoids",' external-scripts.json
docker build -t hubot .
```

Don't forget to also include any required [environment variables](#env) however you're doing that.

### Adding your own custom scripts
First, read [how to write your own script packages](https://hubot.github.com/docs/scripting/#creating-a-script-package).

#### Option 1 (recommended)
Once you've published them to NPM, just add them like any other third-party script.

``` sh
gsed -i '/\[/a \  "hubot-myscript",' external-scripts.json
```

#### Option 2 (development)
**DISCLAIMER: This is sort of hacky, and you should only use this method for developing scripts. Also, I'm thinking about removing this option.**

Add your custom scripts to the `scripts` directory, and any additional dependencies for your custom scripts to the `hubot_packages` build argument. Then, rebuild the image. The build will copy the `scripts` directory into the image, and install the additional dependencies.

``` sh
cp my_script.js my_other_script.js scripts/
docker build -t hubot:with_my_scripts --build-arg hubot_packages="some_other_modules" .
```

## Reserved for future use

I think this is all you need to know, but if something doesn't work right, [create an issue](issues). Or even better, fix it and submit a [pull request](pulls).

kthxbai
