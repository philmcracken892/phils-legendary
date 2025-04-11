local RSGCore = exports['rsg-core']:GetCoreObject() -- Add RSGCore dependency
local blipEntries = {}
local spawnedAnimals = {}
local huntedCooldowns = {}
local activeHunt = false 
local detectedClue = nil -- Track clue proximity notifications
local NOTIFY_VICINITY = 20.0 -- Distance for "nearby" notification
local IMMEDIATE_VICINITY = 5.0 -- Distance for "very close" notification
local NOTIFY_INTERVAL = 5000 -- 5-second cooldown between notifications

RegisterNetEvent('rsg_legendarymap:updateCooldowns')
AddEventHandler('rsg_legendarymap:updateCooldowns', function(cooldowns)
    huntedCooldowns = cooldowns
end)

local function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    local startTime = GetGameTimer()
    while not HasModelLoaded(hash) do
        Wait(10)
        if GetGameTimer() - startTime > 5000 then
            print("Failed to load model: " .. model)
            break
        end
        RequestModel(hash)
    end
    return hash
end

local function SpawnAnimal(animal)
    local modelHash = LoadModel(animal.model)
    if not modelHash then
        lib.notify({title = 'Error', description = 'Failed to load ' .. animal.name .. ' model!', type = 'error', duration = 5000})
        return nil
    end

    local groundZ = GetGroundZFor_3dCoord(animal.coords.x, animal.coords.y, animal.coords.z, false) or animal.coords.z
    local animalPed = CreatePed(modelHash, animal.coords.x, animal.coords.y, groundZ + 1.0, 0.0, true, true, true)
    
    if animalPed ~= 0 and DoesEntityExist(animalPed) then
        Citizen.InvokeNative(0x283978A15512B2FE, animalPed, true)
        SetModelAsNoLongerNeeded(modelHash)
        SetEntityAsMissionEntity(animalPed, true, true)
        
        if animal.outfit then
            Citizen.InvokeNative(0x77FF8D35EEC6BBC4, animalPed, animal.outfit, 0)
        end
        
        local animalBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, animalPed)
        Citizen.InvokeNative(0x9CB1A1623062F402, animalBlip, animal.name)
        Citizen.InvokeNative(0x662D364ABF16DE2F, animalBlip, GetHashKey("BLIP_MODIFIER_MP_COLOR_4"))

        spawnedAnimals[#spawnedAnimals + 1] = {coords = animal.coords, handle = animalPed, blip = animalBlip, name = animal.name}
        return animalPed
    else
        lib.notify({title = 'Error', description = 'Failed to spawn ' .. animal.name .. '!', type = 'error', duration = 5000})
        return nil
    end
end

local function SpawnClue(animalData)
    local clueHash = LoadModel(animalData.clueModel)
    if not clueHash then
        lib.notify({title = 'Error', description = 'Failed to load clue model for ' .. animalData.name .. '!', type = 'error', duration = 5000})
        return nil
    end

    local offsetX, offsetY = math.random(-15, 15), math.random(-15, 15)
    local clueCoords = vector3(animalData.coords.x + offsetX, animalData.coords.y + offsetY, animalData.coords.z)
    
    -- Improved ground detection
    local groundZ = nil
    local success, z = GetGroundZFor_3dCoord(clueCoords.x, clueCoords.y, clueCoords.z + 10.0, true)
    
    if success then
        groundZ = z
    else
        -- Fallback method if the first attempt fails
        for i = 1, 10 do
            success, z = GetGroundZFor_3dCoord(clueCoords.x, clueCoords.y, clueCoords.z + (5.0 * i), true)
            if success then
                groundZ = z
                break
            end
            Wait(50)
        end
        
        -- If still no success, use a ray trace as last resort
        if not groundZ then
            local startPos = vector3(clueCoords.x, clueCoords.y, clueCoords.z + 50.0)
            local endPos = vector3(clueCoords.x, clueCoords.y, clueCoords.z - 50.0)
            local ray = StartShapeTestRay(startPos.x, startPos.y, startPos.z, endPos.x, endPos.y, endPos.z, 1, 0, 0)
            local _, hit, hitCoords = GetShapeTestResult(ray)
            
            if hit == 1 then
                groundZ = hitCoords.z
            else
                groundZ = animalData.coords.z -- Last resort fallback
            end
        end
    end
    
    -- Add a small offset to prevent clipping into ground
    groundZ = groundZ + 0.03
    
    -- Create the clue object at the proper ground level
    local clue = CreateObject(clueHash, clueCoords.x, clueCoords.y, groundZ, true, true, true)
    
    if clue ~= 0 and DoesEntityExist(clue) then
        SetEntityAsMissionEntity(clue, true, true)
        PlaceObjectOnGroundProperly(clue) -- Ensure proper placement
        FreezeEntityPosition(clue, true) -- Prevent physics from moving it
        
        -- Update coordinates for return (in case PlaceObjectOnGroundProperly changed them)
        local finalCoords = GetEntityCoords(clue)
        print("Clue (poop) spawned at: " .. finalCoords.x .. ", " .. finalCoords.y .. ", " .. finalCoords.z) -- Debug
        
        return clue, finalCoords
    end
    return nil
end

local function CleanupHunt()
    for i = #blipEntries, 1, -1 do
        RemoveBlip(blipEntries[i].handle)
        table.remove(blipEntries, i)
    end
    ClearGpsMultiRoute()
    activeHunt = false
    detectedClue = nil -- Reset clue detection
end

local function CleanupAnimal(coords)
    for i = #spawnedAnimals, 1, -1 do
        local spawned = spawnedAnimals[i]
        if spawned.coords.x == coords.x and spawned.coords.y == coords.y and spawned.coords.z == coords.z then
            -- Remove only the blip but keep the entity
            if spawned.blip then RemoveBlip(spawned.blip) end
            -- We're keeping the animal entity but removing it from our tracking table
            table.remove(spawnedAnimals, i)
            break
        end
    end
    
    for i = #blipEntries, 1, -1 do
        local entry = blipEntries[i]
        if entry.coords.x == coords.x and entry.coords.y == coords.y and entry.coords.z == coords.z then
            RemoveBlip(entry.handle)
            table.remove(blipEntries, i)
        end
    end
end

local function ShowLegendaryLocations()
    CleanupHunt()
    
    lib.notify({
        title = 'Legendary Map',
        description = 'Track a legendary animal by finding its droppings!',
        type = 'success',
        duration = 5000
    })

    local options = {}
    local locationKeys = {}
    for key in pairs(Config.SpawnLocations) do table.insert(locationKeys, key) end

    for i, animal in pairs(Config.LegendaryAnimals) do
        local displayName = animal.names[math.random(1, #animal.names)]
        local isOnCooldown = huntedCooldowns[displayName] and os.time() < huntedCooldowns[displayName]
        
        local randomLocationKey = locationKeys[math.random(1, #locationKeys)]
        local spawnCoords = vector3(Config.SpawnLocations[randomLocationKey].x, Config.SpawnLocations[randomLocationKey].y, Config.SpawnLocations[randomLocationKey].z)

        local option = {
            title = displayName .. (isOnCooldown and " (On Cooldown)" or ""),
            description = 'Last seen near: ' .. randomLocationKey .. ' (' .. string.format("%.1f, %.1f, %.1f", spawnCoords.x, spawnCoords.y, spawnCoords.z) .. ')',
            onSelect = function()
                if activeHunt then
                    lib.notify({title = 'Hunt Already Active', description = 'You are already on a hunt! Complete or cancel it first.', type = 'error', duration = 5000})
                    return
                end
                if isOnCooldown then
                    lib.notify({title = 'Hunt Unavailable', description = displayName .. ' is on cooldown. Try again later!', type = 'error', duration = 5000})
                    return
                end
                
                activeHunt = true
                ClearGpsMultiRoute()
                
                local animalData = {
                    name = displayName,
                    model = animal.model,
                    coords = spawnCoords,
                    hash = animal.hash,
                    outfit = animal.outfit,
                    names = animal.names,
                    clueModel = animal.clueModel
                }

                local clue, clueCoords = SpawnClue(animalData)
                if not clue then
                    CleanupHunt()
                    lib.notify({title = 'Error', description = 'Failed to spawn clue!', type = 'error', duration = 5000})
                    return
                end

                StartGpsMultiRoute(`COLOR_BLUE`, true, true) -- Changed to blue
                AddPointToGpsMultiRoute(spawnCoords.x, spawnCoords.y, spawnCoords.z)
                SetGpsMultiRouteRender(true)

                lib.notify({
                    title = 'Track the Beast',
                    description = 'Find the fresh droppings near ' .. randomLocationKey .. ' to reveal ' .. animalData.name .. '!',
                    type = 'inform',
                    duration = 7000
                })

                CreateThread(function()
                    local clueTimer = 3600 -- 1 hr
                    local foundClue = false
                    detectedClue = {lastNotify = 0, notifiedImmediate = false} -- Initialize clue detection
                    
                    while clueTimer > 0 and DoesEntityExist(clue) and activeHunt do
                        Wait(500)
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local distance = #(playerCoords - clueCoords)
                        print("Player distance from clue: " .. distance) -- Debug

                        -- Proximity notifications
                        local currentTime = GetGameTimer()
                        if distance < NOTIFY_VICINITY then
                            if distance <= IMMEDIATE_VICINITY then
                                if not detectedClue.notifiedImmediate then
                                    lib.notify({
                                        title = "Very Close to Droppings",
                                        description = "The " .. animalData.name .. "'s droppings are right nearby!",
                                        type = "success",
                                        duration = 6000,
                                        position = 'top'
                                    })
                                    detectedClue.lastNotify = currentTime
                                    detectedClue.notifiedImmediate = true
                                end
                            elseif (currentTime - detectedClue.lastNotify) > NOTIFY_INTERVAL then
                                lib.notify({
                                    title = "Droppings Nearby",
                                    description = "The " .. animalData.name .. "'s droppings are close—about " .. math.floor(distance) .. " meters away.",
                                    type = "warning",
                                    duration = 6000,
                                    position = 'top'
                                })
                                detectedClue.lastNotify = currentTime
                                detectedClue.notifiedImmediate = false
                            end
                        end

                        if distance < IMMEDIATE_VICINITY then
                            foundClue = true
                            print("Player reached clue at: " .. clueCoords.x .. ", " .. clueCoords.y .. ", " .. clueCoords.z) -- Debug
                            DeleteObject(clue)
                            local animalPed = SpawnAnimal(animalData)
                            if animalPed then
                                local netId = NetworkGetNetworkIdFromEntity(animalPed)
                                TriggerServerEvent('rsg_legendarymap:spawnAnimal', {
                                    name = animalData.name, model = animalData.model, coords = animalData.coords, netId = netId
                                })
                                lib.notify({
                                    title = 'Clue Found',
                                    description = 'The ' .. animalData.name .. ' has appeared nearby!',
                                    type = 'success',
                                    duration = 5000
                                })

                                local huntTimer = Config.HuntTimer
                                local wasNearAnimal = false
                                while huntTimer > 0 and DoesEntityExist(animalPed) do
                                    Wait(1000)
                                    local ped = PlayerPedId()
                                    local pcoord = GetEntityCoords(ped)
                                    local distance = #(vector3(animalData.coords.x, animalData.coords.y, animalData.coords.z) - pcoord)
                                    huntTimer = huntTimer - 1

                                    if IsEntityDead(animalPed) then
                                        local killer = Citizen.InvokeNative(0x93C8B64DEB84728C, animalPed)
                                        if killer == ped then
                                            TriggerServerEvent('rsg_legendarymap:animalKilled', animalData.name)
                                            lib.notify({title = 'Hunt Success', description = 'You killed ' .. animalData.name .. '! Check your rewards.', type = 'success', duration = 5000})
                                        else
                                            lib.notify({title = 'Hunt Failed', description = 'Someone else killed ' .. animalData.name .. '.', type = 'error', duration = 5000})
                                        end
                                        CleanupAnimal(animalData.coords)
                                        ClearGpsMultiRoute()
                                        activeHunt = false
                                        break
                                    elseif huntTimer <= 0 then
                                        CleanupAnimal(animalData.coords)
                                        ClearGpsMultiRoute()
                                        activeHunt = false
                                        lib.notify({title = 'Hunt Expired', description = 'The hunt for ' .. animalData.name .. ' has expired.', type = 'error', duration = 3000})
                                        break
                                    elseif distance < 5.0 and not wasNearAnimal then
                                        wasNearAnimal = true
                                        lib.notify({title = 'Animal Found', description = 'You found ' .. animalData.name .. '! Hunt it down!', type = 'success', duration = 3000})
                                    end
                                end
                            else
                                lib.notify({title = 'Error', description = 'Failed to spawn animal!', type = 'error', duration = 5000})
                            end
                            break
                        end
                        clueTimer = clueTimer - 0.5 -- Decrease by 0.5 per 500ms
                    end
                    
                    if not foundClue then
                        if DoesEntityExist(clue) then DeleteObject(clue) end
                        CleanupHunt()
                        lib.notify({title = 'Hunt Abandoned', description = 'You didn’t find the droppings in time.', type = 'error', duration = 5000})
                    end
                    activeHunt = false
                    detectedClue = nil
                end)
            end
        }
        table.insert(options, option)
    end

    lib.registerContext({
        id = 'legendary_map_menu',
        title = 'Legendary Animal Tracking',
        options = options
    })
    lib.showContext('legendary_map_menu')
end

RegisterNetEvent('rsg_legendarymap:spawnAnimalClient')
AddEventHandler('rsg_legendarymap:spawnAnimalClient', function(animalData)
    for _, spawned in pairs(spawnedAnimals) do
        if spawned.coords.x == animalData.coords.x and 
           spawned.coords.y == animalData.coords.y and 
           spawned.coords.z == animalData.coords.z then
            return
        end
    end
    SpawnAnimal(animalData)
end)

RegisterNetEvent('rsg_legendarymap:displayLocations')
AddEventHandler('rsg_legendarymap:displayLocations', function()
    ShowLegendaryLocations()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, entry in pairs(blipEntries) do RemoveBlip(entry.handle) end
        for _, spawned in pairs(spawnedAnimals) do
            if DoesEntityExist(spawned.handle) then DeleteEntity(spawned.handle) end
            if spawned.blip then RemoveBlip(spawned.blip) end
        end
        ClearGpsMultiRoute()
    end
end)