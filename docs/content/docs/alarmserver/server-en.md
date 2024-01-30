---
title: "Server En"
description: ""
summary: ""
date: 2024-01-30T15:47:08+08:00
lastmod: 2024-01-30T15:47:08+08:00
draft: false
menu:
  docs:
    parent: ""
    identifier: "server-en-63cdab9f9f99e45b841e15a59f7e3088"
weight: 999
toc: true
seo:
  title: "" # custom title (optional)
  description: "" # custom description (recommended)
  canonical: "" # custom canonical URL (optional)
  noindex: false # false (default) or true
---


# AlarmPawServer

> [!IMPORTANT]
> ✨  The program's concept and some of the code are derived from [BARK](https://github.com/Finb/bark-server).
>
> ✨  A push service backend based on Golang, primarily used for sending messages to clients.
>
> ✨  It re-implements the interface of [BARK](https://github.com/Finb/bark-server) using the Gin framework, making it easier to extend in the future.

### Configuration

```yaml
system:
  name: "AlarmPawServer"
  user: ""         # Username (optional)
  password: ""    # Password (optional)
  host: "0.0.0.0"  # Service listening address
  port: "8080"     # Service listening port (must match the port mapping in Docker Compose)
  mode: "release"  # debug, release, test
  dbType: "default" # default, mysql
  dbPath: "/data"   # Database file storage path

mysql: # Only valid when dbType: "mysql"
  host: "localhost"
  port: "3306"
  user: "root"
  password: "root"

apple: # Copy the project's configuration; no need to modify it unless compiling your app
  keyId:
  teamId:
  topic:
  apnsPrivateKey:
```

## Compilation
* The configuration file must be saved as /data/config.yaml, or the service won't start.
* Place the compiled binary and the configuration file in the same directory.
```shell
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o  main  main.go || echo "Failed to compile the Linux version"

```
* Upload the files to the server, then execute the following command to start the service.

```shell
  ./main
```
## Docker Deployment
```shell
  docker run -d --name alarm-paw-server -p 8080:8080 -v ./data:/data  --restart=always  thurmantsao/alarm-paw-server:latest
```
#### Docker Compose Deployment
* Copy the /deploy folder from the project to your server, then execute the following command.
* You must have a /data/config.yaml configuration file; otherwise, the service won't start.
* You can modify the configuration options in the file according to your needs.
* Document tree:
  - ./main 
  - ./data/config.yaml



#### Start
```shell
  docker compose up -d
```