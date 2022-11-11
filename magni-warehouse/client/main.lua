ESX = exports['es_extended']:getSharedObject()

local PlayerLoaded = false
local PlayerData = {}

Citizen.CreateThread(function()
    ESX.TriggerServerCallback('magni-warehouse:server:getWarehouseData', function(data)
        Config.Locations = data
    end)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    firstLogin()
    PlayerLoaded = true
end)

function firstLogin()
    PlayerData = ESX.GetPlayerData()
    CreateBlips()
end

Citizen.CreateThread(function()
    while true do
        local inRange = false
        --if PlayerLoaded then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            PlayerData = ESX.GetPlayerData()
            local identifier = PlayerData.identifier
            for k, v in pairs(Config.Locations) do
		        local dist = #(pos - v.coords)
                if dist <= 3 then
                    inRange = true
                    local owned = v.owner ~= nil
                    local text = '~g~E~w~ - To Buy Warehouse'
                    if owned then 
                        text = '~g~E~w~ - To Access Warehouse'
                    end
                    DrawMarker(2, v.coords.x,v.coords.y,v.coords.z + 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 255, 255, 255, 255, 0, 0, 0, 1, 0, 0, 0)
                    DrawText3Ds(v.coords.x, v.coords.y, v.coords.z + 1.25, text)
                    if IsControlJustPressed(0, 38) and dist <= 1.5 then -- E
                        if owned then 
                            if v.owner == identifier then
                                openMenu('bought', k, v)
                            else
                                exports['mythic_notify']:DoHudText('error', 'You do not own this warehouse')
                            end
                        else
                            CreateBlips()
                            openMenu('open', k, v)
                        end
                    end
                end

            end
        --end
        if not inRange then
            Wait(1000)
        end
        Citizen.Wait()
    end
end)

function openMenu(type, id, data)
    SendNUIMessage({type = type, id = id, name = data.name, price = data.price , image = data.image})
    SetNuiFocus(true, true)
end

RegisterNetEvent('magni-warehouse:client:updateData')
AddEventHandler('magni-warehouse:client:updateData',function(id, data, value)
    if id ~= nil then
        Config.Locations[id][data] = value
    end
end)

RegisterNUICallback("buy", function(data)
    TriggerServerEvent("magni-warehouse:buy", data)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("sell", function(data)
    TriggerServerEvent("magni-warehouse:sell", data)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("open", function(data)
    if Config.StashType == 'disc' then
        TriggerEvent('disc-inventoryhud:openInventory', {
        type = 'magni-warehouse',
        slots = 100,
        owner = ""..data.name.."", 
        })
    elseif Config.StashType == 'm3' then
        TriggerEvent('m3:inventoryhud:client:openCustomStash', ''..data.name..'')
    elseif Config.StashType == 'npinv' then
        TriggerEvent("server-inventory-open", "1", ''..data.name..'');
    elseif Config.StashType == 'custom' then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", ""..data.name)
        TriggerEvent("inventory:client:SetCurrentStash",""..data.name)
    elseif Config.StashType == 'oxinventory' then
        local name = data.name
        TriggerEvent('ox_inventory:openInventory', 'stash', {id = data.name, name = data.name, slots = 500, weight = 100000})

    end
    SetNuiFocus(false, false)
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function CreateBlips()
    Citizen.CreateThread(function()
        local blips = {}, {}
        for k, v in pairs(Config.Locations) do
            if Config.Blip then
                WarehouseBlip = AddBlipForCoord(v.coords)
                SetBlipSprite(WarehouseBlip, 473)
                SetBlipColour(WarehouseBlip, 0)
                SetBlipScale(WarehouseBlip, 0.6)
                SetBlipAsShortRange(WarehouseBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.name)
                EndTextCommandSetBlipName(WarehouseBlip)
                table.insert(blips, WarehouseBlip)
            end
        end
    end)
end

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        SetNuiFocus(false, false)
    end
end)