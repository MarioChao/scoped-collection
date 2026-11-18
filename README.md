# ScopedCollection

CollectionService wrapper for managing tagged instances under certain ancestor roots.

## About

`ScopedCollection` is the combination of [`CollectionService`](https://create.roblox.com/docs/reference/engine/classes/CollectionService) with ancestry checks.
- With `CollectionService`, the tag methods run for **all instances** under the [`DataModel`](https://create.roblox.com/docs/reference/engine/classes/DataModel).
- `ScopeCollection` allows these methods to run **only for instances under specific ancestors** (still under the `DataModel`).

Commonly, we want to track instances under [`Workspace`](https://create.roblox.com/docs/reference/engine/classes/Workspace) and nowhere else.
To achieve this, we can pass `{workspace}` when creating a `ScopedCollection`.
```luau
local collection = ScopedCollection.new("ExampleTag", {workspace})
```
With this collection, tagged instances are loaded within `workspace` and unloaded under other containers such as `ReplicatedStorage`.

## Usage

### Basic usage

Here's a quick overview of the functions in `ScopedCollection`:
- [`ScopedCollection.new`](#new) - constructs a new collection that tracks tagged instances under valid ancestors.
- [`ScopedCollection:getLoaded`](#getloaded) - gets all tracked instances in the collection.
- [`ScopedCollection:setFunction_onLoaded`](#setfunction_onloaded) - sets the callback function that fires when an instance joins the collection.
- [`ScopedCollection:setFunction_onUnloaded`](#setfunction_onunloaded) - sets the callback function that fires when an instance leaves the collection.
- [`ScopedCollection:start`](#start) - starts the tracking process. This also calls the function passed to `setFunction_onLoaded` on existing instances.
- [`ScopedCollection:terminate`](#terminate) - stops the tracking process, unloading all instances.

> [!IMPORTANT]
> Always remember to call [`ScopedCollection:start()`](#start) after calling `setFunction_onLoaded` and `setFunction_onUnloaded`.

### Examples

Damage brick: see [ScopedCollectionTest](src/TestPlace/ReplicatedStorage/Scripts/ScopedCollectionTest.server.luau).

`ScopedCollection` is also used in [ContainerMechanic](https://github.com/MarioChao/container-mechanic) since v0.2.0.

## What about Roblox's new [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection)?

This module functions similarly to the new [`Collection`](https://create.roblox.com/docs/reference/engine/datatypes/Collection) data type.

With Roblox's `Collection`, you can create more complex collections with query strings and a root.
However, there are some limitations:
- It only supports one root ancestor.
- Queried tag names can't have some special characters (this one is [considered for fixing](https://devforum.roblox.com/t/studio-beta-collections/4809228/69)).
- The performance cost can be high for complex query strings (see [this post](https://devforum.roblox.com/t/how-to-group-instances-with-query-patterns/4809143)).

Roblox's `Collection` also allows easy connection (and disconnection) to *any* instance signals.
However:
- The callback assignment syntax (similar to [remote callbacks](https://create.roblox.com/docs/en-us/scripting/events/remote#client-server-client)) is not often used in other classes.
- This relies a lot on type inference and autocomplete.

> IMO, the callback assignment syntax with autocomplete is very cool, but maybe I'm just not used to it yet.

Although `ScopedCollection` can only query tagged instances under the `DataModel`, it's a similar-performing class that addresses some of these limitations.

## API

### new

Constructs a `ScopedCollection` that tracks tagged instances under valid ancestors.

```luau
ScopedCollection.new(tagName: string, validAncestors: {Instance}): ScopedCollection
```

<b>Parameters</b>
| |
| --- |
| tagName: `string`<br>The name of the instance tag to track. |
| validAncestors: `{Instance}`<br>List of instances whose descendants will be tracked. |

This is similar to CollectionService's [`CreateCollection`](https://create.roblox.com/docs/reference/engine/classes/CollectionService#CreateCollection). Unlike `CreateCollection`, only instances under the [`DataModel`](https://create.roblox.com/docs/reference/engine/classes/DataModel) will be effective as a valid ancestor.

### getLoaded

Gets all tracked instances in the collection.

```luau
ScopedCollection:getLoaded(): {Instance}
```

This is similar to CollectionService's [`GetTagged`](https://create.roblox.com/docs/reference/engine/classes/CollectionService#GetTagged).

### setFunction_onLoaded

Sets the callback function that fires when an instance joins the collection.

```luau
ScopedCollection:setFunction_onLoaded(
    newFunction: (instance: Instance) -> ()
): ()
```

<b>Parameters</b>
| |
| --- |
| newFunction: `(instance: Instance) -> ()`<br>The new callback that fires when an instance joins the collection. |

This is similar to CollectionService's [`GetInstanceAddedSignal`](https://create.roblox.com/docs/reference/engine/classes/CollectionService#GetInstanceAddedSignal) and [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection)'s `OnAdded`.

### setFunction_onUnloaded

Sets the callback function that fires when an instance leaves the collection.

```luau
ScopedCollection:setFunction_onUnloaded(
    newFunction: (instance: Instance) -> ()
): ()
```

<b>Parameters</b>
| |
| --- |
| newFunction: `(instance: Instance) -> ()`<br>The new callback that fires when an instance leaves the collection. |

This is similar to CollectionService's [`GetInstanceRemovedSignal`](https://create.roblox.com/docs/reference/engine/classes/CollectionService#GetInstanceRemovedSignal) and [Collection](https://create.roblox.com/docs/reference/engine/datatypes/Collection)'s `OnRemoved`.

### start

Starts the tracking process.

```luau
ScopedCollection:start(): ()
```

This calls the function passed to [`setFunction_onLoaded`](#setfunction_onloaded) on current and future tracked instances.

### terminate

Stops the tracking process, unloading all instances.

```luau
ScopedCollection:terminate(): ()
```

This calls the function passed to [`setFunction_onUnloaded`](#setfunction_onunloaded) on currently tracked instances, similar to Collection's [`Destroy()`](https://create.roblox.com/docs/reference/engine/datatypes/Collection#Destroy).

## Credits

Inspirations & similar modules:
- Roblox's [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) and [Collections](https://devforum.roblox.com/t/studio-beta-collections/4809228).
