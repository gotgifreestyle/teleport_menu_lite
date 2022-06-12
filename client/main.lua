ESX = nil
menuIsOpen = false
translate = 1.0

Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports['es_extended']:getSharedObject()
	end
end)

Citizen.CreateThread(function()
    CloseTeleportMenu()
    local x = 0
    local y = 0
    while true do
        local sleep = 500
        for key,val in pairs(Config.Telepot) do
            local playerId = PlayerPedId()
            local playerCoords = GetEntityCoords(playerId)
            local distance = GetDistanceBetweenCoords(playerCoords, val.pos, true)
            if distance < 20.0 then
                local markerHeight = 0.5
                DrawMarker(1, val.pos.x,val.pos.y,val.pos.z-translate, 0.0,0.0,0.0, 0.0,0.0,0.0, Config.MarkerDistance,Config.MarkerDistance,markerHeight, Config.MarkerColor.r,Config.MarkerColor.g,Config.MarkerColor.b,Config.MarkerColor.a, false, true, 2, false, nil, nil, false)
                sleep = 5
                if distance <= Config.MarkerDistance/2 then
                    if not menuIsOpen then
                        ESX.ShowHelpNotification(Config.HelpMessage)
                        if IsControlJustReleased(0, Config.Button) then
                            if Config.CheckItem then
                                local xPlayer = ESX.GetPlayerData()
                                for _,val in pairs(xPlayer.inventory) do
                                    if val.name == Config.ItemName and val.count ~= 0 then
                                        OpenTeleportMenu(key)
                                    else
                                        Notification('warning', 'no item')
                                    end
                                    break
                                end
                            else
                                OpenTeleportMenu(key)
                            end
                        end
                    end
                elseif distance <= Config.MarkerDistance/2+1.0 then
                    if menuIsOpen then
                        CloseTeleportMenu(key)
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

RegisterCommand('teleport', function()
    if Config.CheckItem then
        local xPlayer = ESX.GetPlayerData()
        for _,val in pairs(xPlayer.inventory) do
            if val.name == Config.ItemName and val.count ~= 0 then
                OpenTeleportMenu()
            else
                Notification('warning', 'no item')
            end
            break
        end
    else
        OpenTeleportMenu()
    end
end, false)

function OpenTeleportMenu(index)
    index = index or 0
    menuIsOpen = true
    local elements = {}
    if next(Config.Telepot) then
        for key,val in pairs(Config.Telepot) do
            table.insert(elements, {
                label = val.label..(function(x,y) if x == y then return ' <span style="color:rgba(50,50,255,1);">NOW</span>' else return '' end end)(key, index),
                pos = val.pos,
                heading = val.heading,
                posNow = (key == index),
                enable = true
            })
        end
    else
        table.insert(elements, {
            label = 'Unknow',
            enable = false
        })
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'teleport', {
        title = Config.MenuName,
        align = Config.MenuPosition,
        elements = elements
    }, function(data, menu)
        if data.current.enable then
            if not data.current.posNow then
                CloseTeleportMenu(index)
                Teleport(data.current.pos, data.current.heading)
                Freeze(true)
            end
        end
    end, function(data, menu)
        CloseTeleportMenu(index)
    end)
end

function CloseTeleportMenu(index)
    index = index or 0
    menuIsOpen = false
    ESX.UI.Menu.CloseAll()
end

function Freeze(enable)
    if enable then
        menuIsOpen = enable
        local playerId = PlayerPedId()
        FreezeEntityPosition(playerId, enable)
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'teleport', {
            title = Config.MenuName,
            align = Config.MenuPosition,
            elements = { {label='Seccess'} }
        }, function(data, menu)
            Freeze(false)
        end, function(data, menu)
            Freeze(false)
        end)
    else
        menuIsOpen = enable
        local playerId = PlayerPedId()
        FreezeEntityPosition(playerId, enable)
        ESX.UI.Menu.CloseAll()
    end
end

function Teleport(pos, heading)
    local playerId = PlayerPedId()
    DoScreenFadeOut(500)
    FreezeEntityPosition(playerId, true)
    Citizen.Wait(500)
    SetEntityCoords(playerId, pos.x, pos.y, pos.z-0.9, false, false, false, true)
    SetEntityHeading(playerId, heading)
    SetGameplayCamRelativeHeading(0.0)
    Citizen.Wait(500)
    FreezeEntityPosition(playerId, false)
    DoScreenFadeIn(500)
end

function Notification(type, message)
    print(message)
end