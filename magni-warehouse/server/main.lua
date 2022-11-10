ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Warehouse = Config.Locations
Citizen.CreateThread(function()
	Citizen.Wait(0)
    if Config.SQL == "oxmysql" then
        exports.oxmysql:ready(function()
            local result = exports.oxmysql:executeSync("SELECT * FROM magni_warehouse")
            for warehouses = 1, #result do
                Warehouse[result[warehouses].id].owner = result[warehouses].owner
            end
        end)
    elseif Config.SQL == "mysql" then
        MySQL.ready(function()
            local result = MySQL.Sync.fetchAll("SELECT * FROM magni_warehouse")
            for warehouses = 1, #result do
                Warehouse[result[warehouses].id].owner = result[warehouses].owner
            end
        end)
    elseif Config.SQL == "ghmattimysql" then
        local result = exports.ghmattimysql:executeSync("SELECT * FROM magni_warehouse")
		for warehouses = 1, #result do
            Warehouse[result[warehouses].id].owner = result[warehouses].owner
		end
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
        if Config.SQL == "mysql" then
            MySQL.Async.execute("INSERT INTO magni_warehouse (owner, name, id) VALUES (@owner, @name, @id)", {["@owner"] = identifier, ["@name"] = data.name,["@id"] = data.id})
        elseif Config.SQL == "oxmysql" then
            exports.oxmysql:execute("INSERT INTO magni_warehouse (owner, name, id) VALUES (@owner, @name, @id)", {["@owner"] = identifier, ["@name"] = data.name,["@id"] = data.id})
        elseif Config.SQL == "ghmattimysql" then
            exports.ghmattimysql:execute("INSERT INTO magni_warehouse (owner, name, id) VALUES (@owner, @name, @id)", {["@owner"] = identifier, ["@name"] = data.name,["@id"] = data.id})
        end

        TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", identifier)
        Warehouse[data.id].owner = identifier
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = ""..data.name.. " "..price.."$ Purchased!"})
        if Config.Discordlog then
            Discordlog(data)
        end
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = "You don\'t have this amount."})
    end
end)

RegisterServerEvent("magni-warehouse:sell")
AddEventHandler("magni-warehouse:sell", function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer then
        local price = tonumber(data.price)
        data.id = tonumber(data.id)
        if Config.SQL == "mysql" then
            MySQL.Async.fetchAll("SELECT * FROM magni_warehouse WHERE id = @id", {
                ["@id"] = data.id
            }, function(result)
                if result[1] then
                    MySQL.Async.execute("DELETE FROM magni_warehouse WHERE id = @id", {
                        ['@id'] = data.id,
                    }, function()
                        local money = price * 0.5
                        xPlayer.addAccountMoney(Config.MoneyType,money)
                        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = ""..data.name.. " "..money.."$ sold!"})
                        Warehouse[data.id].owner = nil
                        TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", nil)
                        Warehouse[data.id].owner = nil
                    end)
                end
            end)
        elseif Config.SQL == "oxmysql" then
            exports.oxmysql:execute("SELECT * FROM magni_warehouse WHERE id = @id", {
                ["@id"] = data.id
            }, function(result)
                if result[1] then
                    exports.oxmysql:execute("DELETE FROM magni_warehouse WHERE id = @id", {
                        ['@id'] = data.id,
                    }, function()
                        local money = price * 0.5
                        xPlayer.addAccountMoney(Config.MoneyType,money)
                        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = ""..data.name.. " "..money.."$ sold!"})
                        Warehouse[data.id].owner = nil
                        TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", nil)
                        Warehouse[data.id].owner = nil
                    end)
                end
            end)
        elseif Config.SQL == "ghmattimysql" then
            exports.ghmattimysql:execute("SELECT * FROM magni_warehouse WHERE id = @id", {
                ["@id"] = data.id
            }, function(result)
                if result[1] then
                    MySQL.Async.execute("DELETE FROM magni_warehouse WHERE id = @id", {
                        ['@id'] = data.id,
                    }, function()
                        local money = price * 0.5
                        xPlayer.addAccountMoney(Config.MoneyType,money)
                        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'success', text = ""..data.name.. " "..money.."$ sold!"})
                        Warehouse[data.id].owner = nil
                        TriggerClientEvent('magni-warehouse:client:updateData', -1, data.id, "owner", nil)
                        Warehouse[data.id].owner = nil
                    end)
                end
            end)
        end
    end
end)

function Discordlog(data)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    local connect = {
        {
            ["title"] = data.name,
            ["description"] = ""..data.price.." $ Purchased",
            ["thumbnail"] = {["url"] = data.img1},
            ["footer"] = {
                ["text"] = ""..time,
            },
            
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = data.select, embeds = connect}), { ['Content-Type'] = 'application/json' })
end