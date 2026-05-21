    local torpedo = "none"
    local shield = 1
    local prow_module = "Launchbay"
    local side_module = "Weapons"
    local currentShipDB = nil
    local currentVariant = "SH1_Launchbays_Weapons"

    function toggleShield()
        if shield == 1 then
            self.editButton({
                index = 1,
                color = Color(0,1,0),
                hover_color = Color(0,1,0),
                press_color = Color(0,1,0)
            })
            shield = 2
        else
            self.editButton({
                index = 1,
                color = Color(1,0,0),
                hover_color = Color(1,0,0),
                press_color = Color(1,0,0)
            })
            shield = 1
        end
    end

    function toggleTorpedo()
        if torpedo == "none" then
            self.editButton({
                index = 4,
                label = "Torpedo: Boarding"
            })
            torpedo = "boarding"
        elseif torpedo == "boarding" then
            self.editButton({
                index = 4,
                label = "Torpedo: Shortburn"
            })
            torpedo = "shortburn"
        elseif torpedo == "shortburn" then
            self.editButton({
                index = 4,
                label = "Torpedo: Barrage"
            })
            torpedo = "barrage"
        elseif torpedo == "barrage" then
            self.editButton({
                index = 4,
                label = "Torpedo: None"
            })
            torpedo = "none"
        end
    end

    function toggleProw()
        if prow_module == "Launchbay" then
            self.editButton({
                    index = 2,
                    label = "Prow: Bombard"
                })
                prow_module = "Bombard"
        elseif prow_module == "Bombard" then
            self.editButton({
                    index = 2,
                    label = "Prow: Torpedo"
                })
                prow_module = "Torpedo"
        elseif prow_module == "Torpedo" then
            self.editButton({
                    index = 2,
                    label = "Prow: Launch Bay"
                })
                prow_module = "Launchbay"
        end
    end

    function spawnStrikeCruiser()
        spawnShip("strikecruiser")
    end

    function toggleSide()
        if side_module == "Weapons" then
            self.editButton({
                    index = 3,
                    label = "Side: Launch Bays"
                })
                side_module = "Launchbay"
        elseif side_module == "Launchbay" then
            self.editButton({
                    index = 3,
                    label = "Side: Weapons"
                })
                side_module = "Weapons"
        end
    end

    function onLoad()
        self.createButton({
            click_function = "spawnStrikeCruiser",
            function_owner = self,
            label = "Strike Cruiser",
            position = {0, 0.3, 0},
            width = 800,
            height = 300,
            font_size = 100
        })
        self.createButton({
            click_function = "toggleShield",
            function_owner = self,
            label = "+1 Shield",
            position = {1.5, 0.3, 0},
            width = 800,
            height = 300,
            font_size = 100,
            color = Color(1,0,0)
        })
        self.createButton({
            click_function = "toggleProw",
            function_owner = self,
            label = "Prow: Launch Bay",
            position = {0, 0.3, 0.6},
            width = 800,
            height = 300,
            font_size = 100
        })
        self.createButton({
            click_function = "toggleSide",
            function_owner = self,
            label = "Side: Weapons",
            position = {1.5, 0.3, 0.6},
            width = 800,
            height = 300,
            font_size = 100
        })
        self.createButton({
            click_function = "toggleTorpedo",
            function_owner = self,
            label = "Torpedo: None",
            position = {0, 0.3, 1.2},
            width = 800,
            height = 300,
            font_size = 100
        })

        -- Fetch JSON from hosted database
        WebRequest.get("https://scrubzie.github.io/TTS/SM_ships.json", function(response)
            if response.is_error then
                print("Failed to load ship database: " .. response.error)
            else
                local fullDB = JSON.decode(response.text)
                currentShipDB = fullDB["strikecruiser"]
                print("Ship loaded from JSON!")
            end
        end)
    end

    function spawnShip(shipKey)

        local bag = getObjectFromGUID("df7627")
        if not bag then
            print("Ship bag not found")
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

                cloned.setName(currentShipDB["name"])
                cloned.setDescription(createDescription())

                print("Spawned: " .. currentShipDB["name"])

                -- return template to bag
                bag.putObject(template)
            end
        })
    end

    function createDescription()

        local stats = {}
        local weapons = {}
        local ordance = {}
        local description = nil
        local variant = nil

        for k,v in pairs(currentShipDB["base_stats"] or {}) do
            stats[k] = v
        end

        for _, o in ipairs(currentShipDB["base_weapons"] or {}) do
            table.insert(weapons, o)
        end

        for _, o in ipairs(currentShipDB["base_ordance"] or {}) do
            table.insert(ordance, o)
        end

        if shield == 1 and prow_module == "Launchbay" and side_module == "Weapons" then
            variant = currentShipDB["variants"]["SH1_Launchbays_Weapons"]
        elseif shield == 1 and prow_module == "Launchbay" and side_module == "Launchbay" then
            variant = currentShipDB["variants"]["SH1_Launchbays_Launchbays"]
        elseif shield == 1 and prow_module == "Bombard" and side_module == "Weapons" then
            variant = currentShipDB["variants"]["SH1_Bombard_Weapons"]
        elseif shield == 1 and prow_module == "Bombard" and side_module == "Launchbay" then
            variant = currentShipDB["variants"]["SH1_Bombard_Launchbays"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Weapons" and torpedo == "boarding" then
            variant = currentShipDB["variants"]["SH1_Torpedo_Weapons"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Weapons" and torpedo == "barrage" then
            variant = currentShipDB["variants"]["SH1_Torpedo_Weapons_barr"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Weapons" and torpedo == "shortburn" then
            variant = currentShipDB["variants"]["SH1_Torpedo_Weapons_shortburn"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Launchbay" and torpedo == "boarding"  then
            variant = currentShipDB["variants"]["SH1_Torpedo_Launchbays"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Launchbay" and torpedo == "barrage" then
            variant = currentShipDB["variants"]["SH1_Torpedo_Launchbays_barr"]
        elseif shield == 1 and prow_module == "Torpedo" and side_module == "Launchbay" and torpedo == "shortburn" then
            variant = currentShipDB["variants"]["SH1_Torpedo_Launchbays_shortburn"]
        end

        if variant["edit_stats"] then
            for _, v in pairs(variant["edit_stats"]) do
                for k2, v2 in pairs(v) do
                    if stats[k2] then
                        stats[k2] = v2
                    end
                end
            end 
        end

        if variant["edit_weapons"] then
            for _, edit in ipairs(variant["edit_weapons"]) do

                -- Find existing weapon by type
                for i = #weapons, 1, -1 do
                    if weapons[i].type == edit.type then
                        table.remove(weapons, i)
                    end
                end

                -- If edit contains extra fields, insert as new weapon
                local hasData =
                    edit.range or
                    edit.firepower or
                    edit.arc

                if hasData then
                    table.insert(weapons, {
                        type = edit.type,
                        range = edit.range or "",
                        firepower = edit.firepower or "",
                        arc = edit.arc or ""
                    })
                end
            end
        end

        if variant["new_ordance"] then
            for _, v in ipairs(variant["new_ordance"]) do
                local exists = false
                for _, o in ipairs(ordance) do
                    if o.type == v.type then
                        exists = true
                        break
                    end
                end
                if not exists then
                    table.insert(ordance, {
                        type = v.type,
                        range = v.range or "",
                        firepower = v.firepower or "",
                        arc = v.arc or ""
                    })
                end
            end
        end

        local weaponsText = ""
        for _, w in ipairs(weapons) do
            weaponsText = weaponsText .. string.format("[c6c930]%s[-]\n%s | %s | %s\n", w.type, w.range or "", w.firepower or "", w.arc or "")
        end

        local ordnanceText = ""
        for _, o in ipairs(ordance) do
            ordnanceText = ordnanceText .. string.format("%s | %s\n", o.type, o.range or "")
        end

        description = string.format([[
[56f442]T     SP      TN  SH   ARM DF[-]
%s   %s   %s  %d      %s    %d

[e85545]Armament[-]
%s

[e85545]Ordnance[-]
%s
        ]], stats.type, stats.speed, stats.turn, stats.shield, stats.armour, stats.turrets, weaponsText, ordnanceText)

        return description

    end
