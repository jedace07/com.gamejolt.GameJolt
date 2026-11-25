# Game Jolt Flatpak

A Flatpak wrapper for the official Game Jolt desktop client on Linux x86-64.

Game Jolt only serves the client through download links that expire after about
a day, so the manifest can't pin it as a source or as `extra-data`. Instead, the
launcher downloads the latest official Linux build from Game Jolt on first
launch and unpacks it into the app's data directory
(`~/.var/app/com.gamejolt.GameJolt/data/game-jolt-client`). From then on, the
client's own loader keeps itself updated, as it does in a native install.

The Flatpak itself contains only the launcher script, desktop entry, metainfo,
icon and license. It has no binaries.

## Build

Install Flathub's Builder, the Freedesktop Platform and the SDK.

```sh
flatpak install --system flathub org.flatpak.Builder \
  org.freedesktop.Platform//26.08 org.freedesktop.Sdk//26.08
```

Build and export the package to `repo/`.

```sh
flatpak run --system org.flatpak.Builder --system --force-clean --repo=repo \
  builddir com.gamejolt.GameJolt.yaml
```

Install and run it.

```sh
flatpak install --system ./repo com.gamejolt.GameJolt
flatpak run --system com.gamejolt.GameJolt
```

To redownload the client, remove
`~/.var/app/com.gamejolt.GameJolt/data/game-jolt-client` and launch the app again.

## Permissions

- `--filesystem=host` lets the game installer and launched games write to a game
  library in your home directory or on a mounted drive.
- Read-only access to the host GTK 3 and GTK 4 settings lets the client detect
  your theme.

## Flathub submission notes

- Flathub reviewers may not accept an app that downloads its main program at
  runtime. `extra-data` would be preferred, but it needs a stable upstream URL.
- The `com.gamejolt.GameJolt` app ID requires control of gamejolt.com, so Game
  Jolt would need to submit or approve it.
- The client bundles NW.js 0.62.2 (Chromium 98), which is end-of-life.
- The metainfo needs a hosted screenshot.

[Flathub requirements](https://docs.flathub.org/docs/for-app-authors/requirements)
