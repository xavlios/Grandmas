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
				print(players)
			end
		end
	return players
end

local ped, plyDst

RegisterCommand('previve', function(source, args, rawCommand)
print("Command ran")
ped, plyDst = GetClosestPlayer()
print("ped is " .. ped)
print("plyDst is " .. plyDst)

local rplayer = GetPlayerPed(GetPlayerFromServerId(-1))
local crplayer = GetEntityCoords(rplayer,true)


-- 1392.0 , 3600.99, 38.94 grandmas location

	if( GetDistanceBetweenCoords( crplayer, 1392.0, 3600.99, 38.94 ) < 5)then
		print("Im in the area")
		if IsEntityDead(ped) then
            print("player is dead")
			if( plyDst < 2)then
				--check for cash
				TriggerServerEvent("grandma:buttonSelected",name, button)
			    --TriggerServerEvent('grandma:revive', GetPlayerServerId(ped))
			end
		else
			print("player not dead")
	   end
	end
end)


RegisterNetEvent("grandma:buttonSelected")
AddEventHandler("grandma:buttonSelected", function()
	TriggerServerEvent('grandma:revive', GetPlayerServerId(ped))
end)



RegisterNetEvent('xav_grandmas:revive')
AddEventHandler('xav_grandmas:revive', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)

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
end)