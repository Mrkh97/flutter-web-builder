# flutter-web-builder

[![build-and-push](https://github.com/mrkh97/flutter-web-builder/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/mrkh97/flutter-web-builder/actions/workflows/build-and-push.yml)

Pre-baked Flutter SDK Docker images for building Flutter **web** apps in CI/CD (Coolify, GitHub Actions, etc.) without re-cloning the Flutter SDK on every build.

Image: [`mrkh97/flutter-web-builder`](https://hub.docker.com/r/mrkh97/flutter-web-builder)

## Supported tags

| Tag       | Flutter version | Base         | Arch          |
| --------- | --------------- | ------------ | ------------- |
| `3.44.2`  | 3.44.2          | ubuntu:24.04 | linux/amd64   |
| `3.41.9`  | 3.41.9          | ubuntu:24.04 | linux/amd64   |
| `3.38.10` | 3.38.10         | ubuntu:24.04 | linux/amd64   |

> No `latest` tag on purpose — pin to an explicit version so future additions never break your existing builds.

## What's already done in the image

- Flutter SDK cloned at `/flutter`, on `PATH`
- `flutter precache --web` ran during build (web engine artifacts cached)
- Analytics disabled (`flutter config --no-analytics`)
- Runs as `root` to match typical CI / Coolify expectations — your downstream Dockerfile only needs to swap the `FROM` line

## Usage

In your app's Dockerfile, replace the SDK install with:

```dockerfile
# --- Stage 1: build ---
FROM mrkh97/flutter-web-builder:3.41.9 AS build

WORKDIR /app
COPY . .

# (cd into the right app dir if you have a monorepo)
RUN flutter pub get
RUN flutter build web --release

# --- Stage 2: serve ---
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

What you can drop from the build stage: `apt-get install`, `git clone .../flutter`, `ENV PATH=/flutter/bin:...`, and `flutter clean` (image starts clean already).

## Local sanity check

```bash
docker pull mrkh97/flutter-web-builder:3.41.9
docker run --rm mrkh97/flutter-web-builder:3.41.9 flutter --version
```

## Adding a new Flutter version

1. Edit [`.github/workflows/build-and-push.yml`](.github/workflows/build-and-push.yml). In the `set-matrix` job, append the new version to the JSON array (e.g. `'versions=["3.41.9","3.50.0"]'`).
2. (Optional) Add the row to the **Supported tags** table above.
3. Commit + push to `main`. The new tag is built; existing tags are rebuilt from cache (the embedded Flutter version is pinned by `--branch`, so consumers see no functional change).

## Building a single version on demand

GitHub → **Actions** → **build-and-push** → **Run workflow** → enter version (e.g. `3.50.0`).
Leave the input blank to build everything in the matrix.

## Required GitHub secrets

| Name                | Value                                                     |
| ------------------- | --------------------------------------------------------- |
| `DOCKERHUB_USERNAME`| `mrkh97`                                                  |
| `DOCKERHUB_TOKEN`   | Docker Hub Personal Access Token with Read/Write scope    |

Set them under **Settings → Secrets and variables → Actions**.

## License

MIT
