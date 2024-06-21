# 同步docker hub上的镜像到本地registry

## Usage:

1. config Actions secrets on your sync-images repo `Settings > Secrets`, set this Repository secrets:

- `REGISTRY_USER`: registry user which have the push privilege to library repo/project.
- `REGISTRY_PASSWORD`: registry user password.
