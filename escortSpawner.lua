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
            cloned.setDescription(data.description)

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

function onLoad()
    self.createButton({
        click_function = "spawnGladius",
        function_owner = self,
        label = "Gladius",
        position = {0, 0.3, 0},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnHunter",
        function_owner = self,
        label = "Hunter",
        position = {1.5, 0.3, 0},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnNova",
        function_owner = self,
        label = "Nova",
        position = {0, 0.3, 0.6},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnCobra",
        function_owner = self,
        label = "Cobra",
        position = {1.5, 0.3, 0.6},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnFalchion",
        function_owner = self,
        label = "Falchion",
        position = {0, 0.3, 1.2},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnFirestorm",
        function_owner = self,
        label = "Firestorm",
        position = {1.5, 0.3, 1.2},
        width = 600,
        height = 300,
        font_size = 100
    })
    self.createButton({
        click_function = "spawnSword",
        function_owner = self,
        label = "Sword",
        position = {0, 0.3, 1.8},
        width = 600,
        height = 300,
        font_size = 100
    })
    
end

function spawnGladius()
    spawnShip("gladius")
end

function spawnHunter()
    spawnShip("hunter")
end

function spawnNova()
    spawnShip("nova")
end

function spawnCobra()
    spawnShip("cobra")
end

function spawnFalchion()
    spawnShip("falchion")
end

function spawnFirestorm()
    spawnShip("firestorm")
end

function spawnSword()
    spawnShip("sword")
end