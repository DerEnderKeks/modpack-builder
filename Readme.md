# Modpack Builder

This is a docker container to build Minecraft modpacks based on `manifest.json` files. It produces ZIP files for both the client and the server. The server file contains all mods while the client file only contains the manifest and overrides.

## Usage

Run the container with you pack sources (containing a `manifest.json` and an `overrides` directory) mounted to `/builder`. The artifacts will be put into `/builder/artifacts` (named `<slug>_<version>_<client|server>.zip`).

```sh
docker run --rm -v /your/pack/location:/builder derenderkeks/modpack-builder
```

## License 

[Licensed under the EUPL-1.2-or-later](LICENSE)