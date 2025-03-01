local blacklistedHashes = vx.array:new()

Citizen.CreateThread(function()
  blacklistedHashes = SharedConfig.blacklist:map(function(model)
    return joaat(model)
  end)
end)

vx.addCommand("geefsleutels", {
  help = "Zet je auto op iemand zijn naam",
  params = {
    {
      name = "playerId",
      type = "playerId",
      label = "Speler ID"
    }
  }
}, function(source, args)
  local ped = GetPlayerPed(source)
  local targetPed = GetPlayerPed(args.playerId)

  local pedCoords = GetEntityCoords(ped)
  local targetCoords = GetEntityCoords(targetPed)
  local distance = #(pedCoords - targetCoords)
  if distance > 5 then
    return vx.notify(source, {
      title = "Fout!",
      message = "De speler is niet dichtbij genoeg!",
      type = "error"
    })
  end

  local vehicle = GetVehiclePedIsIn(ped, false)
  if not vehicle or vehicle == 0 then
    return vx.notify(source, {
      title = "Fout!",
      message = "Je moet in een voertuig zitten!",
      type = "error"
    })
  end

  local model = GetEntityModel(vehicle)
  if blacklistedHashes:contains(model) then
    return vx.notify(source, {
      title = "Fout!",
      message = "Dit voertuig kan je niet overschrijven!",
      type = "error"
    })
  end

  local identifier = vx.player.getIdentifier(source, false, "license")
  local targetIdentifier = vx.player.getIdentifier(args.playerId, false, "license")
  local plate = GetVehicleNumberPlateText(vehicle)
  local result = MySQL.query.await(
    "UPDATE owned_vehicles SET owner = @newOwner WHERE owner = @owner AND plate = @plate", {
      ["@newOwner"] = targetIdentifier,
      ["@owner"] = identifier,
      ["@plate"] = plate
    })

  if result.affectedRows < 1 then
    return vx.notify(source, {
      title = "Fout!",
      message = "Dit is niet jou voertuig!",
      type = "error"
    })
  end

  vx.notify(source, {
    title = "Success!",
    message = "Je heb de voertuig successvol overgeschreven!",
    type = "success"
  })

  vx.notify(args.playerId, {
    title = "Success!",
    message = string.format("Je heb een voertuig met kenteken %s ontvangen!", plate),
    type = "success"
  })
end)
