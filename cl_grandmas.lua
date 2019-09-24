ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

end)

function GetClosestPlayer()
	print("getting closest player")
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
print("closestPlayer" .. closestPlayer)
print("closestDistance" .. closestDistance)
    return closestPlayer, closestDistance
end

function GetPlayers()
  local players = {}
  	for i = 0, 31 do
      if NetworkIsPlayerActive(i) then
				table.insert(players, i)
				--print(players)
			end
		end
	return players
end

local ped, plyDst
function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z)
    ClearPedBloodDamage(ped)

    ESX.UI.Menu.CloseAll()
end
RegisterCommand('previve', function(source, args, rawCommand)
--print("Command ran")
-----------------------------------------------
 local rplayer = GetPlayerPed(GetPlayerFromServerId(-1))
 local crplayer = GetEntityCoords(rplayer,true)
-- print("player is" .. rplayer .. " and coords x is " .. crplayer.x)
if( GetDistanceBetweenCoords( crplayer, 1392.0, 3600.99, 38.94 ) < 5)then
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
    TriggerServerEvent("grandma:buttonSelected",name, button)
    Citizen.CreateThread(function()
        DoScreenFadeOut(800)

        while not IsScreenFadedOut() do
            Citizen.Wait(50)
        end

        local formattedCoords = {
            x = ESX.Math.Round(coords.x, 1),
            y = ESX.Math.Round(coords.y, 1),
            z = ESX.Math.Round(coords.z, 1)
        }

        ESX.SetPlayerData('lastPosition', formattedCoords)

        TriggerServerEvent('esx:updateLastPosition', formattedCoords)

        RespawnPed(playerPed, formattedCoords, 0.0)

        StopScreenEffect('DeathFailOut')
        DoScreenFadeIn(800)
    end)
end
end)
-----------------------------------------------
RegisterNetEvent("grandma:buttonSelected")
AddEventHandler("grandma:buttonSelected", function()
	TriggerServerEvent('grandma:revive', GetPlayerServerId(ped))
end)
