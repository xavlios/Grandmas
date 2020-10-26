ESX = nil
local PlayerData = {}
local showCircle = true
local showBlip = true
local grandmasLocationx = 1392.0  -- coords as a float ex 112.3
local grandmasLocationy = 3600.99 -- coords as a float ex 112.3
local grandmasLocationz = 38.0 -- coords as a float ex 112.3


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer  
end)

function GetPlayers()
    local players = {}
    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end
    return players
end

function GetClosestPlayer()
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
	print("closestPlayer " .. closestPlayer)
	print("closestDistance " .. closestDistance)
    return closestPlayer, closestDistance
end

RegisterCommand('cpr', function(source)
    while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		-- check to see if your at grandmas
		if(GetDistanceBetweenCoords(coords, grandmasLocationx, grandmasLocationy, grandmasLocationz, true) < 3.0) then
			revivePlayer()
		end
	end
end, false)

function revivePlayer()
	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
	if(closestDistance ~= -1 and closestDistance < 5) then
		-- allow the revive to continue and check if player doing cpr has the money
		TriggerServerEvent("esx_grandmas:checkMoney")
	else
		print("No one else is close to me")
	end
end

RegisterNetEvent("esx_grandmas:accepted")
AddEventHandler("esx_grandmas:accepted", function()
	-- pull up bar to do revive
	local closestPlayerPed = GetPlayerPed(closestPlayer)
	local health = GetEntityHealth(closestPlayerPed)
	local target_id = GetPlayerServerId(closestPlayer)
	print("the health of the dead player is " .. health .. " the player is " .. closestPlayer .. " id is " .. target_id)

	if health == 0 then
		local playerPed = PlayerPedId()

		ESX.ShowNotification("heal in progress")
		TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
		Citizen.Wait(10000)
		ClearPedTasks(playerPed)

		TriggerServerEvent('esx_grandma:revive', GetPlayerServerId(closestPlayer))
		ESX.ShowNotification("heal complete", GetPlayerName(closestPlayer))
	else
		ESX.ShowNotification("player not dead")
	end
end)

RegisterNetEvent("esx_grandmas:rejected")
AddEventHandler("esx_grandmas:rejected", function(money)
	print("You dont have $" .. money)
end)

-- Display circle
Citizen.CreateThread(function()
	while showCircle do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		if(1 ~= -1 and GetDistanceBetweenCoords(coords, grandmasLocationx, grandmasLocationy, grandmasLocationz, true) < 100) then
			DrawMarker(27, grandmasLocationx, grandmasLocationy, grandmasLocationz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
		end
	end
end)

-- Display blip
Citizen.CreateThread(function()
	while showBlip do
		Citizen.Wait(0)
		grandmaBlip = AddBlipForCoord(grandmasLocationx, grandmasLocationy, grandmasLocationz)
		SetBlipSprite(grandmaBlip, 429)
		SetBlipDisplay(grandmaBlip, 6)
		SetBlipScale(grandmaBlip, 0.8)
		SetBlipColour(grandmaBlip, 2)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Grandmas")
		EndTextCommandSetBlipName(grandmaBlip)
	end
end)