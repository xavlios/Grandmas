ESX = nil
local GrandmasFee = 4000

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



RegisterServerEvent('grandma:heal')
AddEventHandler('grandma:heal', function(target, type)
	local xPlayer = ESX.GetPlayerFromId(source)
		--print("We in here. target is " .. target)
		TriggerClientEvent('esx_grandmas:heal', target, type)
	
end)


RegisterServerEvent('esx_grandma:revive')
AddEventHandler('esx_grandma:revive', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('esx_ambulancejob:revive', target)
end)


RegisterServerEvent("esx_grandmas:money")
AddEventHandler("esx_grandmas:money", function()
        local xPlayer = ESX.GetPlayerFromId(source)
		local money = xPlayer.getMoney()

		--print("Player has " .. money .. " on them.")
	TriggerClientEvent("esx_grandmas:amount",source, money)
end)

RegisterServerEvent("esx_grandmas:moneyTake")
AddEventHandler("esx_grandmas:moneyTake", function()
        local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeMoney(GrandmasFee)
end)
