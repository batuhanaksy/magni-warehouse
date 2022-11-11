ESX = exports['es_extended']:getSharedObject()

if Config.StashType == "oxinventory" then
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        for k, v in pairs(Config.Locations) do
            exports.ox_inventory:RegisterStash(v.name, v.name, 50, 1000000, false)
        end
    end)
end    

function ExecuteSql(query)
	local IsBusy = true
	local result = nil
	if Config.SQL == "oxmysql" then
	    if MySQL == nil then
	        exports.oxmysql:execute(query, function(data)
		  result = data
		  IsBusy = false
	        end)
	    else
	        MySQL.query(query, {}, function(data)
		  result = data
		  IsBusy = false
	        end)
	    end
      
	elseif Config.SQL == "ghmattimysql" then
	    exports.ghmattimysql:execute(query, {}, function(data)
	        result = data
	        IsBusy = false
	    end)
	elseif Config.SQL == "mysql-async" then   
	    MySQL.Async.fetchAll(query, {}, function(data)
	        result = data
	        IsBusy = false
	    end)
	end
	while IsBusy do
	    Citizen.Wait(0)
	end
	return result
end

local Warehouse = Config.Locations
Citizen.CreateThread(function()
	Citizen.Wait(0)
    local result = ExecuteSql("SELECT * FROM magni_warehouse")
    for warehouses = 1, #result do
        Warehouse[result[warehouses].id].owner = result[warehouses].owner
    end
end)

ESX.RegisterServerCallback('magni-warehouse:server:getWarehouseData', function(source, cb)
	cb(Warehouse)
end)

RegisterServerEvent("magni-warehouse:buy")
AddEventHandler("magni-warehouse:buy", function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local identifier = xPlayer.identifier
    local price = tonumber(data.price)
    local currentMoney = xPlayer.getAccount(Config.MoneyType).money
    data.id = tonumber(data.id)
    if currentMoney >= price then
        xPlayer.removeAccountMoney(Config.MoneyType, price)
        ExecuteSql(string.format("INSERT INTO `magni_warehouse` (`owner`,`name`,`id`) VALUES ('"..identifier.."', '"..data.name.."','"..data.id.."')"))

        TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", identifier)
        Warehouse[data.id].owner = identifier
        if Config.Notify then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = ""..data.name.. " "..price.."$ Purchased!"})
        end
        if Config.Discordlog then
            Discordlog(data)
        end
    else
        if Config.Notify then
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "You don\'t have this amount."})
        end
    end
end)

RegisterServerEvent("magni-warehouse:sell")
AddEventHandler("magni-warehouse:sell", function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local price = tonumber(data.price)
        data.id = tonumber(data.id)
        ExecuteSql("SELECT * FROM magni_warehouse WHERE id = @id", {
            ["@id"] = data.id
        }, function(result)
            if result[1] then
                MySQL.Async.execute("DELETE FROM magni_warehouse WHERE id = @id", {
                    ['@id'] = data.id,
                }, function()
                    local money = price * 0.5
                    xPlayer.addAccountMoney(Config.MoneyType,money)
                    if Config.Notify then
                        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = ""..data.name.. " "..money.."$ Sold!"})
                    end
                    Warehouse[data.id].owner = nil
                    TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", nil)
                    Warehouse[data.id].owner = nil
                end)
            end
        end)
    end
end)

function GetName(source)
    local xPlayer = ESX.GetPlayerFromId(tonumber(source))
    if xPlayer then
        return xPlayer.getName()
    else
        return "Magni#0247"
    end
end

function Discordlog(data)
    local src = source
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local name = GetName(src)
    local connect = {
        {
            ["title"] = data.name,
            ["description"] = "Buyer: "..name.." "..data.price.." $ Purchased",
            ["thumbnail"] = {["url"] = data.img1},
            ["footer"] = {
                ["text"] = ""..time,
            },
            
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = data.select, embeds = connect}), { ['Content-Type'] = 'application/json' })
end