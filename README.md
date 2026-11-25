# Game Jolt Flatpak

This manifest packages the official Game Jolt 1.39.4 Linux x86-64 download. It
launches the bundled client directly and disables client self-updates. The game
installer and updater still use the bundled Linux game runner.

## Build with the system Flatpak SDK

Copy the original `gamejoltclient.tar.gz` into this directory beside the manifest.

You can get the archive under **Download for Linux** on the Game Jolt app page.
Its SHA-256 is `43c34c7f26b2c6d69236415349d135539624b4cadf230bf46a0a62b16527e564`.
[Game Jolt download page](https://gamejolt.com/app)

The build uses the system installations of Flathub's Builder, the Freedesktop
Platform, and the SDK. If any are missing, install them from the system Flathub
remote.

```sh
flatpak install --system flathub org.flatpak.Builder \
  org.freedesktop.Platform//26.08 org.freedesktop.Sdk//26.08
```

Build and export the package to `repo/`.

```sh
flatpak run --system org.flatpak.Builder --system --force-clean --repo=repo \
  builddir com.gamejolt.GameJolt.yaml
```

To run the package, install it system-wide from the local repository.

```sh
flatpak install --system ./repo com.gamejolt.GameJolt
flatpak run --system com.gamejolt.GameJolt
```

## Filesystem access

Game Jolt uses host filesystem access so the game installer and launched games
can write to a library in your home directory or on a mounted drive. The
manifest also makes host GTK 3 and GTK 4 settings available for theme detection.

## Flathub submission

This is a local binary build. Game Jolt's download API issues expiring URLs, so
Flathub CI would need a stable, redistributable source URL or an offline build
from source. Flathub generally requires source builds for source-available apps.
The supplied release also bundles NW.js 0.62.2, which needs a supported update
for a public submission. AppStream metadata needs a hosted screenshot of the
client. [Flathub submission requirements](https://docs.flathub.org/docs/for-app-authors/requirements)
and [MetaInfo guidelines](https://docs.flathub.org/docs/for-app-authors/metainfo-guidelines).
