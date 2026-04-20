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
docker run --name shopware-dev_app -p 8000:8000 -p 9998:9998 -p 5173:5173 -v shopware-dev_db:/app -v <cwd>:/app/custom/plugins/<PluginName> shopware-cli-dev
```

#### Run Specific shopware version
```bash
docker run --name shopware-dev_app -p 8000:8000 -p 9998:9998 -p 5173:5173 -e SHOPWARE_VERSION=6.6.10.0 -v shopware-dev_db:/app -v /path/to/MyPlugin:/app/custom/plugins/MyPlugin shopware-cli-dev
```

Mounting custom plugins
```bash
docker run -it --rm --name shopware-dev_app -p 8000:8000 -p 9998:9998 -p 5173:5173 -v shopware-dev_db:/app -e SHOPWARE_VERSION=6.6.10.0 -v ./my-plugin:/app/custom/plugins/my-plugin shopware-cli-dev
```

You don't. For a dev environment, detached mode is usually better:
```bash
docker run -d --name shopware-dev_app -p 8000:8000 -p 9998:9998 -p 5173:5173 -v shopware-dev_db:/app shopware-cli-dev
```

Then exec in when you need to:
```bash
docker exec -it shopware-dev_app bash
```


## Contributing

Contributions are always welcome!
