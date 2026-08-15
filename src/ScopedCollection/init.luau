--!strict

-- Scoped Collection


---------- Services ----------

local CollectionService = game:GetService("CollectionService")


---------- Class ----------

--- CollectionService wrapper for managing tagged instances under certain ancestor roots.
local Class = {}
Class.__index = Class


----- Class types -----

type CFieldData = {
    _tagName: string,
    _validAncestors: {Instance},

    _objectLoadedFn: ((instance: Instance) -> ())?,
    _objectUnloadedFn: ((instance: Instance) -> ())?,

    _isRunning: boolean,
    _object_isLoaded: {[Instance]: true?},
    _tagged_ancestryChangedConnection: {[Instance]: RBXScriptConnection?},
    _instanceAddedConnection: RBXScriptConnection?,
    _instanceRemovedConnection: RBXScriptConnection?,
}

export type CObjectType = typeof(setmetatable({} :: CFieldData, Class))


----- Class fields -----

--[[
Constructs a `ScopedCollection` that tracks tagged instances under valid ancestors.
@param tagName The name of the instance tag to track.
@param validAncestors List of instances whose descendants will be tracked.
]]
function Class.new(tagName: string, validAncestors: {Instance}): CObjectType
    local self = setmetatable({}, Class) :: CObjectType
    self._tagName = tagName
    self._validAncestors = validAncestors

    self._objectLoadedFn = nil
    self._objectUnloadedFn = nil

    self._isRunning = false
    self._object_isLoaded = {}
    self._tagged_ancestryChangedConnection = {}
    self._instanceAddedConnection = nil
    self._instanceRemovedConnection = nil
    return self
end


--- Getters ---

--[[
Gets all tracked instances in the collection.
]]
function Class.getLoaded(self: CObjectType)
    local loadedObjects = {}
    for object, isLoaded in self._object_isLoaded do
        if isLoaded then
            table.insert(loadedObjects, object)
        end
    end
    return loadedObjects
end


--- Setters ---

--[[
Sets the callback function that fires when an instance joins the collection.
@param newFunction The new callback that fires when an instance joins the collection.
]]
function Class.setFunction_onLoaded(self: CObjectType, newFunction: (instance: Instance) -> ())
    self._objectLoadedFn = newFunction
end

--[[
Sets the callback function that fires when an instance leaves the collection.
@param newFunction The new callback that fires when an instance leaves the collection.
]]
function Class.setFunction_onUnloaded(self: CObjectType, newFunction: (instance: Instance) -> ())
    self._objectUnloadedFn = newFunction
end


--- Object loading (valid ancestor) ---

function Class._onObjectLoaded(self: CObjectType, object: Instance)
    self._object_isLoaded[object] = true
    if self._objectLoadedFn then
        self._objectLoadedFn(object)
    end 
end

function Class._onObjectUnloaded(self: CObjectType, object: Instance)
    self._object_isLoaded[object] = nil
    if self._objectUnloadedFn then
        self._objectUnloadedFn(object)
    end
end


--- Object loading (collection service) ---

function Class._getIsUnderValidAncestor(self: CObjectType, object: Instance)
    local isValidAncestor = false
    for _, ancestor in self._validAncestors do
        if object:IsDescendantOf(ancestor) then
            isValidAncestor = true
            break
        end
    end
    return isValidAncestor
end

function Class._onObjectTagged(self: CObjectType, object: Instance)
    -- Validate running
    if not self._isRunning then
        return
    end

    -- Initial load
    local isLoaded = false
    task.defer(function()
        if self:_getIsUnderValidAncestor(object) then
            isLoaded = true
            self:_onObjectLoaded(object)
        end
    end)

    -- Ancestry changed
    if self._tagged_ancestryChangedConnection[object] then
        (self._tagged_ancestryChangedConnection[object] :: RBXScriptConnection):Disconnect()
    end
    self._tagged_ancestryChangedConnection[object] = (
        object.AncestryChanged:Connect(function()
            -- Check different loaded state
            local isValidAncestor = self:_getIsUnderValidAncestor(object)
            if isValidAncestor == isLoaded then
                return
            end

            -- Load or unload
            isLoaded = isValidAncestor
            if isLoaded then
                self:_onObjectLoaded(object)
            else
                self:_onObjectUnloaded(object)
            end
        end)
    )
end

function Class._onObjectUntagged(self: CObjectType, object: Instance)
    -- Disconnect ancestry changed
    if self._tagged_ancestryChangedConnection[object] then
        (self._tagged_ancestryChangedConnection[object] :: RBXScriptConnection):Disconnect()
    end
    self._tagged_ancestryChangedConnection[object] = nil

    -- Unload
    self:_onObjectUnloaded(object)
end


--- Run ---

--[[
Starts the tracking process.
]]
function Class.start(self: CObjectType)
    -- Set running
    if self._isRunning then
        return
    end
    self._isRunning = true

    -- Disconnect existing events
    if self._instanceAddedConnection then
        self._instanceAddedConnection:Disconnect()
    end
    if self._instanceRemovedConnection then
        self._instanceRemovedConnection:Disconnect()
    end

    -- Connect events
    local initialTagged = CollectionService:GetTagged(self._tagName)
    task.defer(function()
        for _, object in initialTagged do
            task.defer(self._onObjectTagged, self, object)
        end
    end)
    self._instanceAddedConnection = CollectionService:GetInstanceAddedSignal(self._tagName):Connect(function(object: Instance)
        self:_onObjectTagged(object)
    end)
    self._instanceRemovedConnection = CollectionService:GetInstanceRemovedSignal(self._tagName):Connect(function(object: Instance)
        self:_onObjectUntagged(object)
    end)
end


--- Clean up ---

--[[
Stops the tracking process, unloading all instances.
]]
function Class.terminate(self: CObjectType)
    -- Set running to false
    if not self._isRunning then
        return
    end
    self._isRunning = false

    -- Disconnect events
    if self._instanceAddedConnection then
        self._instanceAddedConnection:Disconnect()
    end
    if self._instanceRemovedConnection then
        self._instanceRemovedConnection:Disconnect()
    end

    -- Remove all objects
    for tagged, _ in self._tagged_ancestryChangedConnection do
        self:_onObjectUntagged(tagged)
    end

    -- Disconnect leftover ancestry changed connections
    for _, connection in self._tagged_ancestryChangedConnection do
        if connection then
            connection:Disconnect()
        end
    end

    -- Clear running data
    self._object_isLoaded = {}
    self._tagged_ancestryChangedConnection = {}
    self._instanceAddedConnection = nil
    self._instanceRemovedConnection = nil
end


---------- Return class ----------

table.freeze(Class)
return Class
