ESX = nil
local PlayerData = {}
local reviveCost = 5000
local grandmasLocationx = 1392.0  -- coords as a float ex 112.3
local grandmasLocationy = 3600.99 -- coords as a float ex 112.3
local grandmasLocationz = 38.0 -- coords as a float ex 112.3
-- dont touch these values below
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local amount = 0

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




-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())

		--for k,v in pairs(Config.Zones) do
		--	for i = 1, #v.Pos, 1 do
				if(1 ~= -1 and GetDistanceBetweenCoords(coords, grandmasLocationx, grandmasLocationy, grandmasLocationz, true) < 100) then
					DrawMarker(27, grandmasLocationx, grandmasLocationy, grandmasLocationz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
				end
		--	end
		--end
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
				if(GetDistanceBetweenCoords(coords, grandmasLocationx, grandmasLocationy, grandmasLocationz, true) < 3.0) then
					isInMarker  = true
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
	CurrentActionMsg  = 'Press [E] to start the revive process.'
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

			if IsControlJustReleased(0, 51) then
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

	local revivingPlayer = GetPlayerPed(source)
	print("reviving player is " .. GetPlayerName(revivingPlayer)) -- returning **Invalid**

	local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

	print("dead player is " .. GetPlayerName(closestPlayer)) -- Returns players name i want to revive
	if(closestDistance ~= -1 and closestDistance < 5) then
		print("Distance good")
	    if 	(closestPlayer) then
	    	TriggerServerEvent("esx_grandmas:money")
	    	Citizen.Wait(5000)
	    	print("You have $" .. amount)
			if amount >= reviveCost then
				-- Trigger ems healing animation
				local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01'
				
				ESX.Streaming.RequestAnimDict(lib, function()

					print("Running heal script")

						ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
							
								local closestPlayerPed = GetPlayerPed(closestPlayer)
								local health = GetEntityHealth(closestPlayerPed)
								local target_id = GetPlayerServerId(closestPlayer)
								print("the health of the dead player is " .. health .. " the player is " .. closestPlayer .. " id is " .. target_id)

								if health == 0 then
									local playerPed = PlayerPedId()

									IsBusy = true
									ESX.ShowNotification("heal in progress")
									TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
									Citizen.Wait(10000)
									ClearPedTasks(playerPed)

									TriggerServerEvent('esx_grandma:revive', GetPlayerServerId(closestPlayer))
									----TriggerServerEvent('grandma:heal', target_id, 'big')
									ESX.ShowNotification("heal complete", GetPlayerName(closestPlayer))
									IsBusy = false
									TriggerServerEvent("esx_grandmas:moneyTake", reviveCost)
								else
									ESX.ShowNotification("player not dead")
								end
							
						end, 'bandage')

				end)
				
			else
				print("Not enough money on player")
			end -- end money check
		else 
			print("Player not dead")
		end -- end if statement of if dead
	else
		print("No one else is close to me")
	end -- end if statemsnt for distance
	
end

RegisterNetEvent("esx_grandmas:amount")
AddEventHandler("esx_grandmas:amount", function(newvalue)
	print("New value is " .. newvalue)
	amount = newvalue
	print("amount is now $" .. amount)
end)

RegisterNetEvent('esx_grandmas:heal')
AddEventHandler('esx_grandmas:heal', function(healType, quiet)

	local playerPed = PlayerPedId()
	print("Healing the player " .. playerPed)
	local maxHealth = GetEntityMaxHealth(playerPed)
	print("max health is " .. maxHealth)

	SetEntityHealth(playerPed, maxHealth)
	print("Set player to max health")

	if not quiet then
		ESX.ShowNotification(_U('healed'))
	end
end)
