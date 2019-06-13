ESX = nil
local PlayerData = {}


Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(1)
    end

    while ESX.GetPlayerData() == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

    
end) 

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)


RegisterCommand("previve", function(source, args, rawCommand)
    local targetped = GetPedInFront()
    local coords = GetEntityCoords(targetped)

	    if targetped ~= 0 then
			local targetplayer = GetPlayerFromPed(targetped)
			if targetedPlayer ~= -1 then
				TriggerServerEvent("Checkhealplayer", GetPlayerServerId(targetplayer))
			end
		end

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

		RespawnPed(targetped, formattedCoords, 0.0)

    	DoScreenFadeIn(800)
    end)
    
end, false)


function GetPedInFront()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.3, 0.0)
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, 1.0, 12, plyPed, 7)
	local _, _, _, _, ped = GetShapeTestResult(rayHandle)
	return ped
end



RegisterNetEvent("healplayer")
AddEventHandler("healplayer", function()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	if DoesEntityExist(plyPed) then
		plyPed.
	end
end)