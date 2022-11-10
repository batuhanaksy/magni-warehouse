Do not forget to add the code to the oxmysql or ghmattimysql script!

-for oxmysql

exports("ready", function (callback)
    Citizen.CreateThread(function ()
        while GetResourceState('oxmysql') ~= 'started' do
            Citizen.Wait(0)
        end
        callback()
    end)
end)

-for ghmattimysql

exports("ready", function (callback)
    Citizen.CreateThread(function ()
        while GetResourceState('ghmattimysql') ~= 'started' do
            Citizen.Wait(0)
        end
        callback()
    end)
end)