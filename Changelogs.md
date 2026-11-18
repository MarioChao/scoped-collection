# Changelogs

## [v1.0.1] Optimizations | 2026/11/17

Optimized the module:
- Newly tagged instances are now loaded faster.
    - No longer uses `task.defer` for initial loading.
- Some additional optimizations to other functions.
- Under equivalent conditions, `ScopedCollection` now has a similar performance to `Collection`.
    - Previously, `ScopedCollection` was 50-75% slower.

Updated [README](README.md) with clarity and API docs.

## [v1.0.0] Scoped collection class | 2026/08/14

Created the `ScopedCollection` class module.
- Origin:
    - Refactored from [ContainerMechanic](https://github.com/MarioChao/container-mechanic) v0.1.0.
    - Inspired by Roblox's [Collections](https://devforum.roblox.com/t/studio-beta-collections/4809228).
- Methods: `new()`, `getLoaded()`, `setFunction_onLoaded()`, `setFunction_onUnloaded()`, `start()`, `terminate()`.

Created test place script with an example damage brick collection.
