local RSGCore = exports['rsg-core']:GetCoreObject()


local huntedAnimals = {}


local mapUsageCooldowns = {}
local MAP_COOLDOWN_TIME = 3600 -- 30 minutes cooldown (in seconds)

RSGCore.Functions.CreateUseableItem('legendarymap', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player then
        
        local playerIdentifier = Player.PlayerData.citizenid
        local currentTime = os.time()
        
        if mapUsageCooldowns[playerIdentifier] and currentTime < mapUsageCooldowns[playerIdentifier] then
            
            local remainingTime = math.ceil((mapUsageCooldowns[playerIdentifier] - currentTime) / 60)
            
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Map Cooldown',
                description = 'Your legendary map needs to recharge. Try again in ' .. remainingTime .. ' minutes.',
                type = 'error',
                duration = 5000
            })
            return
        end
        
        
        if Player.Functions.RemoveItem(item.name, 1, item.slot) then
           
            mapUsageCooldowns[playerIdentifier] = currentTime + MAP_COOLDOWN_TIME
            
           
            TriggerClientEvent('rsg_legendarymap:updateCooldowns', source, huntedAnimals)
            TriggerClientEvent('rsg_legendarymap:displayLocations', source)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Error',
                description = 'You don\'t have a Legendary Map!',
                type = 'error',
                duration = 3000
            })
        end
    end
end)


RegisterNetEvent('rsg_legendarymap:spawnAnimal')
AddEventHandler('rsg_legendarymap:spawnAnimal', function(animalData)
    local src = source
   
    if huntedAnimals[animalData.name] and os.time() < huntedAnimals[animalData.name] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Hunt Unavailable',
            description = animalData.name .. ' is on cooldown. Try again later!',
            type = 'error',
            duration = 5000
        })
        return
    end
    
   
    TriggerClientEvent('rsg_legendarymap:spawnAnimalClient', -1, animalData)
    
   
    print("Server: Broadcasting spawn of " .. animalData.name .. " to all clients")
end)

RegisterNetEvent('rsg_legendarymap:animalKilled')
AddEventHandler('rsg_legendarymap:animalKilled', function(animalName)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    
    
    if Player then
       
        local rewardsDesc = ""
        
        
        if Config.Rewards.Cash > 0 then
            Player.Functions.AddMoney('cash', Config.Rewards.Cash, 'Legendary animal kill reward')
            rewardsDesc = "$" .. Config.Rewards.Cash
        end
        
       
        if Config.Rewards.Trophy then
            local info = {
                description = 'Trophy for killing ' .. animalName
            }
            
            Player.Functions.AddItem(Config.Rewards.TrophyItem, 1, false, info)
            
            if rewardsDesc ~= "" then
                rewardsDesc = rewardsDesc .. " and a trophy"
            else
                rewardsDesc = "a trophy"
            end
        end
        
        
        if rewardsDesc ~= "" then
           
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Reward Received',
                description = 'You received ' .. rewardsDesc .. ' for killing ' .. animalName .. '!',
                type = 'success',
                duration = 5000
            })
        end
        
       
        huntedAnimals[animalName] = os.time() + 3600
        
       
        TriggerClientEvent('rsg_legendarymap:updateCooldowns', -1, huntedAnimals)
    end
end)


CreateThread(function()
    while true do
        Wait(60000) 
        local currentTime = os.time()
        
        
        for name, expiry in pairs(huntedAnimals) do
            if currentTime >= expiry then
                huntedAnimals[name] = nil
            end
        end
        
        
        for identifier, expiry in pairs(mapUsageCooldowns) do
            if currentTime >= expiry then
                mapUsageCooldowns[identifier] = nil
            end
        end
    end
end)