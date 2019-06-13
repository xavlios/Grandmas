RegisterServerEvent("Checkhealplayer")
AddEventHandler("Checkhealplayer", function(player)
	TriggerClientEvent("healplayer", tonumber(player))
end)