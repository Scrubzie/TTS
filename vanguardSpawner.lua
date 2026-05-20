local shortburn = 0
local barrage = 0
local T = "C"
local SP = "25cm"
local TN = "90°"
local SH = 1
local ARM = "6+"
local DF = 3
local torpedoButtonState = 0
local Torpedo = "Boarding Torpedoes: 30cm"

function toggleShield()
    if SH == 1 then
        self.editButton({
            index = 1,
            color = Color(0,1,0)
        })
        SH = 2
    else
        self.editButton({
            index = 1,
            color = Color(1,0,0)
        })
        SH = 1
    end
end

function toggleTorpedo()
    if torpedoButtonState == 0 then
        self.editButton({
            index = 2,
            label = "Shortburn"
        })
        torpedoButtonState = 1
        Torpedo = "Shortburn Torpedoes: 40cm"
    elseif torpedoButtonState == 1 then
        self.editButton({
            index = 2,
            label = "Barrage"
        })
        torpedoButtonState = 2
        Torpedo = "Barrage Bombs: 30cm"
    elseif torpedoButtonState == 2 then
        self.editButton({
            index = 2,
            label = "Boarding"
        })
        torpedoButtonState = 0
        Torpedo = "Boarding Torpedoes: 30cm"
    end
end

function onLoad()
    self.createButton({
        click_function = "spawnVanguard",
        function_owner = self,
        label = "Vanguard",
        position = {0, 0.3, 0},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "toggleShield",
        function_owner = self,
        label = "+1 Shield",
        position = {1.5, 0.3, 0},
        width = 600,
        height = 300,
        font_size = 100,
        color = Color(1,0,0)
    })
    self.createButton({
        click_function = "toggleTorpedo",
        function_owner = self,
        label = "Torpedo",
        position = {0, 0.3, 0.6},
        width = 600,
        height = 300,
        font_size = 100
    })
end

function spawnVanguard()
    spawnShip("vanguard")
end

function createDescription()
    return string.format([[
    [56f442] T     SP      TN  SH   ARM DF[-]
    %s   %s   %s  %d      %s    %d

    [e85545]Armament[-]
    [c6c930]Port Weapons Battery[-]
    30cm | 5 | [sub][00ff00]L[-][/sub] [sup][ff0000]F[-][/sup] [sub][ff0000]R[-][/sub]
    [c6c930]Starboard Weapons Battery[-]
    30cm | 5 | [sub][ff0000]L[-][/sub] [sup][ff0000]F[-][/sup] [sub][00ff00]R[-][/sub]
    [c6c930]Prow Torpedoes[-]
    30cm | 4 | [sub][ff0000]L[-][/sub] [sup][00ff00]F[-][/sup] [sub][ff0000]R[-][/sub]
    [c6c930]Prow Launch Bays[-]
    30cm | 1 | [sub][ff0000]L[-][/sub] [sup][00ff00]F[-][/sup] [sub][ff0000]R[-][/sub]

    [e85545]Attack Craft[-]
    Thunderhawks: 20cm
    Torpedoes: 30cm
    %s

    [ff00ff]Improved Thrusters[-]
    Vanguard cruisers add an additional
    +1D6cm to their speed while on All Ahead Full special
    orders.
    ]], T, SP, TN, SH, ARM, DF, Torpedo)
end

local description = string.format([[
[56f442] T     SP      TN  SH   ARM DF[-]
%s   %s   %s  %d      %s    %d

[e85545]Armament[-]
[c6c930]Port Weapons Battery[-]
30cm | 5 | [sub][00ff00]L[-][/sub] [sup][ff0000]F[-][/sup] [sub][ff0000]R[-][/sub]
[c6c930]Starboard Weapons Battery[-]
30cm | 5 | [sub][ff0000]L[-][/sub] [sup][ff0000]F[-][/sup] [sub][00ff00]R[-][/sub]
[c6c930]Prow Torpedoes[-]
30cm | 4 | [sub][ff0000]L[-][/sub] [sup][00ff00]F[-][/sup] [sub][ff0000]R[-][/sub]
[c6c930]Prow Launch Bays[-]
30cm | 1 | [sub][ff0000]L[-][/sub] [sup][00ff00]F[-][/sup] [sub][ff0000]R[-][/sub]

[e85545]Attack Craft[-]
Thunderhawks: 20cm
%s

[ff00ff]Improved Thrusters[-]
Vanguard cruisers add an additional
+1D6cm to their speed while on All Ahead Full special
orders.
]], T, SP, TN, SH, ARM, DF, Torpedo)

function spawnShip(shipKey)

    -- local ShipDB = Global.getTable("EscortShipDB")
    local ShipDB = getShipDB()
    if not ShipDB then
        print("ShipDB not ready yet")
        return
    end

    local bag = getObjectFromGUID("df7627")
    if not bag then
        print("Ship bag not found")
        return
    end

    local data = ShipDB[shipKey]
    if not data then
        print("Unknown ship: " .. tostring(shipKey))
        return
    end

    local pos = self.getPosition()

    -- FIND CORRECT OBJECT IN BAG
    local objects = bag.getObjects()
    local target = nil

    for _, obj in ipairs(objects) do
        -- IMPORTANT: match by bag object NAME
        if obj.name == shipKey then
            target = obj
            break
        end
    end

    if not target then
        print("No model in bag for: " .. shipKey)
        return
    end

    -- TAKE SPECIFIC OBJECT
    bag.takeObject({
        guid = target.guid,
        position = {0, 5, 0},
        smooth = false,
        callback_function = function(template)

            local cloned = template.clone({
                position = {pos.x, pos.y + 1, pos.z + 2},
                rotation = self.getRotation()
            })

            cloned.setName(data.name)
            cloned.setDescription(createDescription())

            print("Spawned: " .. data.name)

            -- return template to bag
            bag.putObject(template)
        end
    })
end

function getShipDB()
    local dbObj = getObjectFromGUID("5d43c3")
    if dbObj then
        return dbObj.getTable("EscortShipDB")
    end
end