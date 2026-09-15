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


## Current Requirements

The current development version requires:

- Pelican Panel and Wings
- An external MySQL 8.0 server
- Three databases for AzerothCore (`auth`, `characters`, and `world`)
- A MySQL user with access to those three databases
- At least 10 GB of server storage recommended

MariaDB is not currently supported by this integration. The current AzerothCore
build has been tested successfully with MySQL 8.0.


## Features

- Pelican egg for Azeroth
- Precompiled AzerothCore runtime
- `authserver` and `worldserver` management
- External MySQL 8.0 database support
- AzerothCore database initialization and migrations
- Persistent server configuration
- Persistent Lua/Eluna scripts
- AzerothCore client-data management
- Controlled update/reinstall workflow

## Planned Features

- Configurable realm name and public/private realm address
- AzerothCore version pinning and controlled upgrades
- Automated upstream container rebuilds
- Improved Eluna/ALE configuration support
- Backup and upgrade documentation
- Additional runtime and update testing

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
     `----> External MySQL
              |-- auth
              |-- characters
              `-- world
