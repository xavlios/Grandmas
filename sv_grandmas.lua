ESX = nil
local playersHealing = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('grandma:revive')
AddEventHandler('grandma:revive', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
		--print("testing")
		TriggerClientEvent('esx_ambulancejob:revive', target)
		return
end)


RegisterServerEvent("grandma:buttonSelected")
AddEventHandler("grandma:buttonSelected", function(name, button)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	mymoney = 1000
			xPlayer.removeMoney(mymoney)
end)
