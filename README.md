# docker-hubot
This is a Dockerized version of [Hubot](https://github.com/hubotio/hubot).

## How to run it
If you use [docker-compose](https://docs.docker.com/compose/) or something similar, you can get everything going pretty quick using the provided [docker-compose.yml](docker-compose.yml). You might want to at least review the [About chat adapters](#chat-adapters) section first, though.

``` sh
docker-compose up
```

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

### Add third-party scripts
There's a ton of [hubot-scripts](https://www.npmjs.com/search?q=hubot-scripts) available to extend Hubot's functionality. Just add them to [external-scripts.json](external-scripts.json) and rebuild the container.

``` sh
gsed -i '/\[/a \  "hubot-factoids",' external-scripts.json
docker build -t hubot .
```

Don't forget to also include any build or runtime environment variables they may require.

### Add your own custom scripts

#### Option 1 (recommended)
[Write your own script packages](https://hubot.github.com/docs/scripting/#creating-a-script-package) and add them just like a third-party script.

#### Option 2 (development)
**DISCLAIMER: This is sort of hacky, and you should only use this method for developing scripts.**

Add your scripts to the `scripts` directory, and the dependencies for them to the `hubot_packages` build argument.

### Reserved for future use

I think this is all you need to know, but if something doesn't work right, [create an issue](issues). Or even better, fix it and submit a [pull request](pulls).

kthxbai