# Shopware CLI

[![Hosted By: Cloudsmith](https://img.shields.io/badge/OSS%20hosting%20by-cloudsmith-blue?logo=cloudsmith&style=flat-square)](https://cloudsmith.com)

A cli which contains handy helpful commands for daily Shopware tasks

## Features

- Manage your Shopware account extensions in the CLI
- Build and validate Shopware extensions

For docs see [here](https://developer.shopware.com/docs/products/cli/)

## Exension development

### Raw docker

#### Build image
```bash
docker build -f Dockerfile.dev -t shopware-cli-dev .
```

#### Run Latest shopware version
```bash
docker run -v shopware-data:/app -v /path/to/MyPlugin:/app/custom/plugins/MyPlugin shopware-cli-dev
```

#### Run Specific shopware version
```bash
docker run -e SHOPWARE_VERSION=6.6.10.0 -v shopware-data:/app -v /path/to/MyPlugin:/app/custom/plugins/MyPlugin shopware-cli-dev
```

Mounting custom plugins
```bash
docker run -it --rm \
  -p 8000:8000 \
  -v shopware-data:/app \
  -e SHOPWARE_VERSION=6.6.10.0 \ // optional, defaults to latest
  -v ./my-plugin:/app/custom/plugins/my-plugin \
  shopware-cli-dev
```

You don't. For a dev environment, detached mode is usually better:
```bash
docker run -d --name shopware -p 8000:8000 -v shopware-data:/app shopware-cli-dev
```

Then exec in when you need to:
```bash
docker exec -it shopware sh
```


## Contributing

Contributions are always welcome!
