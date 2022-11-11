Config = {}

Config.SQL = "mysql-async" -- "oxmysql" , "ghmattimysql" or mysql-async
Config.MoneyType = "bank" -- "cash" or "bank"
Config.Blip = true -- "true" or "false"
Config.Discordlog = true -- "true" or "false"
Config.Webhook = ""
Config.StashType = "oxinventory" -- "disc", "m3", "npinv", "custom", "oxinventory"
Config.Notify = false

Config.Locations = {
    [1] = {
        owner = nil, 
        name = "Warehouse1",
        coords = vector3(993.1, -2968.6, 4.9),
        price = 250000,
        image = "https://i.hizliresim.com/96ok6kh.png"
    },
    [2] = {
        owner = nil, 
        name = "Warehouse2",
        coords = vector3(993.06, -2973.89, 4.9),
        price = 250000,
        image = "https://i.hizliresim.com/eensqd9.png"
    },
    [3] = {
        owner = nil, 
        name = "Warehouse3",
        coords = vector3(993.07, -2978.82, 4.9),
        price = 250000,
        image = "https://i.hizliresim.com/ir16o92.png"
    },
    [4] = {
        owner = nil, 
        name = "Warehouse4",
        coords = vector3(968.62, -2981.39, 4.9),
        price = 250000,
        image = "https://i.hizliresim.com/m3sj7rp.png"
    },
    [5] = {
        owner = nil, 
        name = "Warehouse5",
        coords = vector3(965.23, -2984.76, 4.9),
        price = 250000,
        image = "https://i.hizliresim.com/898eyru.png"
    },
}