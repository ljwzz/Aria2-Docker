# Aria2c Docker

## Build

```
sh make.sh
```

## Usage

### Docker CLI

```
docker run -d \
    --name aria2 \
    --restart unless-stopped \
    --log-opt max-size=1m \
    -e PUID=$UID \
    -e PGID=$GID \
    -e RPC_SECRET=<TOKEN> \
    -v $PWD/aria2-config:/config \
    -v $PWD/aria2-downloads:/downloads \
    ljwzz/aria2
```

## Credits

* [aria2](https://github.com/aria2/aria2)
