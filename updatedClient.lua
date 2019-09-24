ESX = nil
local PlayerData = {}
local reviveCost = 5000
local grandmasLocationx = 1392.0  -- coords as a float ex 112.3
local grandmasLocationy = 3600.99 -- coords as a float ex 112.3
local grandmasLocationz = 38.94 -- coords as a float ex 112.3

local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}

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

RegisterCommand('previve', function(source, args, rawCommand)
--print("Command ran")
 local revivingPlayer = GetPlayerPed(GetPlayerFromServerId(-1))

 local deadPlayer, distance = GetClosestPlayer()
 if(distance ~= -1 and distance < 5) then
    if IsEntityDead(deadPlayer) then
		if PlayerData.getMoney() >= reviveCost then
			-- check if at grandmas
			
				-- Trigger ems healing animation
				local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01'
				
				ESX.Streaming.RequestAnimDict(lib, function()
					TaskPlayAnim(revivingPlayer, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

					Citizen.Wait(500)
					while IsEntityPlayingAnim(revivingPlayer, lib, anim, 3) do
						Citizen.Wait(0)
						DisableAllControlActions(0)
					end
		
					--TriggerEvent('esx_ambulancejob:heal', 'big', true) use this ??
				end)
				-- Trigger revive event for dead player
				
			end --end distance to revive point
		end -- end money check
	end -- end if statement of if dead
 end -- end if statemsnt for distance
 
 
 
end)

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			for i = 1, #v.Pos, 1 do
				if(Config.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.DrawDistance) then
					DrawMarker(Config.Type, grandmasLocationx, grandmasLocationy, grandmasLocationz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		--for k,v in pairs(Config.Zones) do
			--for i = 1, #v.Pos, 1 do
				if(GetDistanceBetweenCoords(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, true) < Config.Size.x) then
					isInMarker  = true
					ShopItems   = v.Items
					currentZone = k
					LastZone    = k
				end
			--end
		--end
		if isInMarker and not HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = true
			TriggerEvent('esx_grandmas:hasEnteredMarker', currentZone)
		end
		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_grandmas:hasExitedMarker', LastZone)
		end
	end
end)

AddEventHandler('esx_grandmas:hasEnteredMarker', function(zone)
	CurrentAction     = 'heal_menu'
	CurrentActionMsg  = 'press [E] to start the revive process.'
	CurrentActionData = {zone = zone}
end)

AddEventHandler('esx_grandmas:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) then
				if CurrentAction == 'heal_menu' then
					healThem()
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function healThem()

local revivingPlayer = GetPlayerPed(GetPlayerFromServerId(-1))

 local deadPlayer, distance = GetClosestPlayer()
 if(distance ~= -1 and distance < 5) then
    if IsEntityDead(deadPlayer) then
		if PlayerData.getMoney() >= reviveCost then
				-- Trigger ems healing animation
				local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01'
				
				ESX.Streaming.RequestAnimDict(lib, function()
					TaskPlayAnim(revivingPlayer, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

					Citizen.Wait(500)
					while IsEntityPlayingAnim(revivingPlayer, lib, anim, 3) do
						Citizen.Wait(0)
						DisableAllControlActions(0)
					end
		
					--TriggerEvent('esx_ambulancejob:heal', 'big', true) use this ??
				end)
				-- Trigger revive event for dead player
		end -- end money check
	end -- end if statement of if dead
 end -- end if statemsnt for distance

end)




-----------------------------------------------
RegisterNetEvent("grandma:buttonSelected")
AddEventHandler("grandma:buttonSelected", function()
	TriggerServerEvent('grandma:revive', GetPlayerServerId(ped))
end)
