# pelican-azerothcore

Unofficial community integration for deploying and hosting
[AzerothCore](https://www.azerothcore.org/) servers with
[Pelican](https://pelican.dev/).

> [!WARNING]
> This project is currently under development and is not ready for production
> use.

## About

pelican-azerothcore aims to provide a straightforward way to deploy and manage
AzerothCore through Pelican while remaining as close as practical to
AzerothCore's supported deployment and update mechanisms.

## Planned Features

- Pelican egg for AzerothCore
- Precompiled AzerothCore runtime
- `authserver` and `worldserver` management
- External MySQL/MariaDB support
- AzerothCore database initialization and migrations
- Persistent server configuration
- Persistent Lua/Eluna scripts
- AzerothCore client-data management
- Controlled update/reinstall workflow
- Version pinning where supported

## Architecture

The intended deployment model is:

```text
Pelican Panel
     |
     v
Pelican Wings
     |
     +-- AzerothCore
     |     |-- authserver
     |     `-- worldserver
     |
     `----> External MySQL/MariaDB
              |-- auth
              |-- characters
              `-- world
