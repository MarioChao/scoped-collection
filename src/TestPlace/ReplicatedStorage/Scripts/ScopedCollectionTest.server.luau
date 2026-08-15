--!strict

-- Scoped Collection Test


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local ScopedCollection = require(_Modules:WaitForChild("ScopedCollection"))


---------- Globals ----------

local Globals = {}

Globals.part_touchedConnection = {} :: {[BasePart]: RBXScriptConnection?}


---------- Local functions ----------

local onLoaded
local onUnloaded


----- Collection -----

onLoaded = function(instance: Instance)
    print(`Loading '{instance}'.`)
    if instance:IsA("BasePart") then
        Globals.part_touchedConnection[instance] = instance.Touched:Connect(function(otherPart: BasePart)
            local character = otherPart.Parent
            local player = Players:GetPlayerFromCharacter(character)
            if character and player then
                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid:TakeDamage(15)
                end
            end
        end)
        print("New connection created.")
    end
end

onUnloaded = function(instance: Instance)
    print(`Unloading '{instance}'.`)
    if instance:IsA("BasePart") then
        if Globals.part_touchedConnection[instance] then
            (Globals.part_touchedConnection[instance] :: RBXScriptConnection):Disconnect()
            print("Connection disconnected.")
        end
        Globals.part_touchedConnection[instance] = nil
    end
end


----- Main -----

local function main()
    local tagName = "DamageBrick"

    -- Create scoped collection
    local collection = ScopedCollection.new(tagName, {workspace})
    collection:setFunction_onLoaded(onLoaded)
    collection:setFunction_onUnloaded(onUnloaded)
    collection:start()

    -- Reparent outside workspace test
    local part = Instance.new("Part")
    part:AddTag(tagName)
    print("[Main]: Creating part under workspace.")
    part.Parent = workspace
    task.wait(2)
    print("[Main]: Reparenting outside workspace.")
    part.Parent = ReplicatedStorage
    task.wait(2)
    print("[Main]: Reparenting back to workspace.")
    part.Parent = workspace
    task.wait(2)

    -- Retrieving objects
    print("[Main]: Retrieved objects:", collection:getLoaded())

    -- Reconnection test
    task.wait(10)
    print("[Main]: Reconnecting collection.")
    collection:terminate()
    task.wait(2)
    collection:start()
end


---------- Calling function ----------

main()
