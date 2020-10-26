ESX = nil
local GrandmasFee = 4000

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_grandmas:checkMoney")
AddEventHandler("esx_grandmas:checkMoney", function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local money = xPlayer.getMoney()
	if money >= GrandmasFee then
		TriggerClientEvent("esx_grandmas:accepted",source, money) -- send accept to client for if needed
		TriggerEvent("esx_grandmas:removeMoney") -- take the money from the player doing cpr
	else
		TriggerClientEvent("esx_grandmas:rejected",source, money)
	end
end)

RegisterServerEvent("esx_grandmas:removeMoney")
AddEventHandler("esx_grandmas:removeMoney", function()
        local xPlayer = ESX.GetPlayerFromId(source)
		xPlayer.removeMoney(GrandmasFee)
end)



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




