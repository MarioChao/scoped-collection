# scoped-collection

CollectionService wrapper for managing tagged instances under certain ancestor roots.

## Usage

Each `ScopedCollection` tracks instances of a single [tag](https://create.roblox.com/docs/studio/properties#instance-tags).
- With regular [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService),
the tag methods (e.g. [GetInstanceAddedSignal](https://create.roblox.com/docs/reference/engine/classes/CollectionService#GetInstanceAddedSignal))
run for all instances under the [DataModel](https://create.roblox.com/docs/reference/engine/classes/DataModel).
- `ScopeCollection` allows these methods to run only for instances under specific ancestors
(the ancestors still being under the [DataModel](https://create.roblox.com/docs/reference/engine/classes/DataModel)).

Commonly, we want to track instances under [Workspace](https://create.roblox.com/docs/reference/engine/classes/Workspace) and nowhere else.
To achieve this, we can create a `ScopedCollection` with `validAncestors` set to `{workspace}`.
```luau
local tagName = "ExampleTagName"
local collection = ScopedCollection.new(tagName, {workspace})
```

Each `ScopedCollection` contains setters for defining callbacks for when an instance is loaded and unloaded.
These callbacks receive the instance as parameter.
```luau
function onLoaded(instance: Instance) end
function onUnloaded(instance: Instance) end

collection:setFunction_onLoaded(onLoaded)
collection:setFunction_onUnloaded(onUnloaded)
```

After defining the callbacks, call `collection:start()` to start tracking tagged instances.
This also fires the `onLoaded()` callback for current instances.

Example:
- See [ScopedCollectionTest](src/TestPlace/ReplicatedStorage/Scripts/ScopedCollectionTest.server.luau) for an example damage brick.
- This module is also used in [ContainerMechanic](https://github.com/MarioChao/container-mechanic) since v0.2.0.

## What about Roblox's new [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection)?

This module functions similarly to the new [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection) currently in beta.
For example, you can achieve something like the above using the following.
```luau
local collection = CollectionService:CreateCollection(".TagName", workspace)
collection.OnAdded = onLoaded
collection.OnRemoved = onUnloaded
```

With Roblox's [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection), you can create more complex collections with query strings and a root.
However, there are some limitations:
- It only supports one root ancestor.
- Queried tag names can't have some special characters (this one is [considered for fixing](https://devforum.roblox.com/t/studio-beta-collections/4809228/69)).
- The performance cost can be high for complex query strings (see [this post](https://devforum.roblox.com/t/how-to-group-instances-with-query-patterns/4809143)).

Roblox's [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection) also allows easy connection (and disconnection) to any instance signals.
However:
- The callback assignment syntax (similar to [remote callbacks](https://create.roblox.com/docs/en-us/scripting/events/remote#client-server-client)) is not often used in other classes.
- This relies a lot on type inference and autocomplete, which may be complicated to work with.

> IMO, the callback assignment syntax with autocomplete is very cool, but maybe I'm just not used to it yet.

Although `ScopedCollection` can only query tagged instances, it's a simpler class that addresses the above limitations.

## Credits

Similar modules:
- Roblox's [Collections](https://devforum.roblox.com/t/studio-beta-collections/4809228).
