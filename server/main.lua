local TrackedVehicles = {}

-- Debug print function
local function DebugPrint(message)
    if Config.Debug then
        print('[permanente-Fahrzeuge] ' .. message)
    end
end

-- Check if a vehicle is owned (exists in owned_vehicles table)
local function IsOwnedVehicle(plate, callback)
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM ' .. Config.OwnedVehiclesTable .. ' WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(count)
        callback(count > 0)
    end)
end

-- Save vehicle position and state to database
local function SaveVehicleState(plate, position, heading, damage)
    local positionData = json.encode({
        x = position.x,
        y = position.y,
        z = position.z,
        heading = heading
    })
    
    local damageData = json.encode(damage)
    
    MySQL.Async.execute('UPDATE ' .. Config.OwnedVehiclesTable .. ' SET parking_position = @position, parking_damage = @damage, last_parked = NOW() WHERE plate = @plate', {
        ['@position'] = positionData,
        ['@damage'] = damageData,
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            DebugPrint('Saved position for vehicle: ' .. plate)
        end
    end)
end

-- Load and spawn all parked vehicles on server start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    DebugPrint('Loading parked vehicles from database...')
    
    MySQL.Async.fetchAll('SELECT plate, vehicle, parking_position, parking_damage FROM ' .. Config.OwnedVehiclesTable .. ' WHERE parking_position IS NOT NULL', {}, function(results)
        if results then
            for _, vehicle in ipairs(results) do
                local position = json.decode(vehicle.parking_position)
                if position then
                    DebugPrint('Queuing vehicle for spawn: ' .. vehicle.plate)
                    TrackedVehicles[vehicle.plate] = {
                        model = vehicle.vehicle,
                        position = position,
                        damage = vehicle.parking_damage and json.decode(vehicle.parking_damage) or nil,
                        spawned = false
                    }
                end
            end
            print('[permanente-Fahrzeuge] Loaded ' .. #results .. ' parked vehicles')
        end
    end)
end)

-- Handle vehicle position update from client
RegisterNetEvent('permanente-fahrzeuge:saveVehiclePosition')
AddEventHandler('permanente-fahrzeuge:saveVehiclePosition', function(plate, position, heading, damage)
    local _source = source
    
    -- Verify the plate exists in owned_vehicles
    IsOwnedVehicle(plate, function(isOwned)
        if isOwned then
            SaveVehicleState(plate, position, heading, damage)
            TrackedVehicles[plate] = {
                position = position,
                heading = heading,
                damage = damage,
                spawned = true
            }
        else
            DebugPrint('Attempted to save non-owned vehicle: ' .. plate)
        end
    end)
end)

-- Request to spawn a parked vehicle
RegisterNetEvent('permanente-fahrzeuge:requestVehicleSpawn')
AddEventHandler('permanente-fahrzeuge:requestVehicleSpawn', function(plate)
    local _source = source
    
    if TrackedVehicles[plate] and not TrackedVehicles[plate].spawned then
        TriggerClientEvent('permanente-fahrzeuge:spawnVehicle', _source, 
            TrackedVehicles[plate].model,
            TrackedVehicles[plate].position,
            TrackedVehicles[plate].damage
        )
        TrackedVehicles[plate].spawned = true
        DebugPrint('Spawned vehicle: ' .. plate)
    end
end)

-- Get all parked vehicles for client
RegisterNetEvent('permanente-fahrzeuge:requestParkedVehicles')
AddEventHandler('permanente-fahrzeuge:requestParkedVehicles', function()
    local _source = source
    local parkedVehicles = {}
    
    for plate, data in pairs(TrackedVehicles) do
        if not data.spawned then
            table.insert(parkedVehicles, {
                plate = plate,
                model = data.model,
                position = data.position,
                damage = data.damage
            })
        end
    end
    
    TriggerClientEvent('permanente-fahrzeuge:receiveParkedVehicles', _source, parkedVehicles)
end)

-- Mark vehicle as spawned
RegisterNetEvent('permanente-fahrzeuge:vehicleSpawned')
AddEventHandler('permanente-fahrzeuge:vehicleSpawned', function(plate)
    if TrackedVehicles[plate] then
        TrackedVehicles[plate].spawned = true
        DebugPrint('Vehicle marked as spawned: ' .. plate)
    end
end)

-- Remove vehicle from tracking when deleted
RegisterNetEvent('permanente-fahrzeuge:removeVehicle')
AddEventHandler('permanente-fahrzeuge:removeVehicle', function(plate)
    -- Update database to clear parking position
    MySQL.Async.execute('UPDATE ' .. Config.OwnedVehiclesTable .. ' SET parking_position = NULL, parking_damage = NULL WHERE plate = @plate', {
        ['@plate'] = plate
    }, function(affectedRows)
        if affectedRows > 0 then
            DebugPrint('Cleared parking data for vehicle: ' .. plate)
        end
    end)
    
    if TrackedVehicles[plate] then
        TrackedVehicles[plate] = nil
    end
end)

print('[permanente-Fahrzeuge] Server script loaded')
