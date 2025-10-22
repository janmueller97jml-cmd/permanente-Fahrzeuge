local TrackedVehicles = {}
local SpawnedVehicles = {}
local ParkedVehiclesData = {} -- Store parked vehicle data for respawning

-- Debug print function
local function DebugPrint(message)
    if Config.Debug then
        print('[permanente-Fahrzeuge Client] ' .. message)
    end
end

-- Get vehicle plate
local function GetVehiclePlate(vehicle)
    if DoesEntityExist(vehicle) then
        return GetVehicleNumberPlateText(vehicle)
    end
    return nil
end

-- Get vehicle position and heading
local function GetVehiclePositionData(vehicle)
    local coords = GetEntityCoords(vehicle)
    local heading = GetEntityHeading(vehicle)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, heading
end

-- Get vehicle damage state
local function GetVehicleDamageData(vehicle)
    local damageData = {
        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        windows = {},
        doors = {},
        tyres = {}
    }
    
    -- Window damage
    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            damageData.windows[i] = true
        end
    end
    
    -- Door damage
    for i = 0, 5 do
        if IsVehicleDoorDamaged(vehicle, i) then
            damageData.doors[i] = true
        end
    end
    
    -- Tyre damage
    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) then
            damageData.tyres[i] = {
                burst = true,
                completely = IsVehicleTyreBurst(vehicle, i, true)
            }
        end
    end
    
    return damageData
end

-- Apply vehicle damage
local function ApplyVehicleDamage(vehicle, damageData)
    if not damageData then return end
    
    -- Apply health values
    if damageData.bodyHealth then
        SetVehicleBodyHealth(vehicle, damageData.bodyHealth + 0.0)
    end
    if damageData.engineHealth then
        SetVehicleEngineHealth(vehicle, damageData.engineHealth + 0.0)
    end
    if damageData.tankHealth then
        SetVehiclePetrolTankHealth(vehicle, damageData.tankHealth + 0.0)
    end
    if damageData.dirtLevel then
        SetVehicleDirtLevel(vehicle, damageData.dirtLevel + 0.0)
    end
    
    -- Apply window damage
    if damageData.windows then
        for window, isDamaged in pairs(damageData.windows) do
            if isDamaged then
                SmashVehicleWindow(vehicle, window)
            end
        end
    end
    
    -- Apply door damage
    if damageData.doors then
        for door, isDamaged in pairs(damageData.doors) do
            if isDamaged then
                SetVehicleDoorBroken(vehicle, door, true)
            end
        end
    end
    
    -- Apply tyre damage
    if damageData.tyres then
        for tyre, data in pairs(damageData.tyres) do
            if data.burst then
                SetVehicleTyreBurst(vehicle, tyre, data.completely, 1000.0)
            end
        end
    end
end

-- Save vehicle position to server
local function SaveVehiclePosition(vehicle)
    local plate = GetVehiclePlate(vehicle)
    if not plate then return end
    
    local position, heading = GetVehiclePositionData(vehicle)
    local damage = GetVehicleDamageData(vehicle)
    
    -- Update parked vehicle data if this is a parked vehicle
    if ParkedVehiclesData[plate] then
        ParkedVehiclesData[plate].position = {
            x = position.x,
            y = position.y,
            z = position.z,
            heading = heading
        }
        ParkedVehiclesData[plate].damage = damage
        DebugPrint('Updated parked vehicle position: ' .. plate)
    end
    
    TriggerServerEvent('permanente-fahrzeuge:saveVehiclePosition', plate, position, heading, damage)
    DebugPrint('Saved position for vehicle: ' .. plate)
end

-- Spawn a parked vehicle
local function SpawnParkedVehicle(model, position, damage, plate)
    local modelHash = GetHashKey(model)
    
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(100)
    end
    
    local vehicle = CreateVehicle(modelHash, position.x, position.y, position.z, position.heading, true, false)
    
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
        
        -- Apply damage if available
        if damage then
            ApplyVehicleDamage(vehicle, damage)
        end
        
        local vehiclePlate = GetVehiclePlate(vehicle)
        SpawnedVehicles[vehiclePlate] = vehicle
        
        TriggerServerEvent('permanente-fahrzeuge:vehicleSpawned', vehiclePlate)
        DebugPrint('Spawned vehicle: ' .. vehiclePlate .. ' at ' .. position.x .. ', ' .. position.y .. ', ' .. position.z)
    end
    
    SetModelAsNoLongerNeeded(modelHash)
end

RegisterNetEvent('permanente-fahrzeuge:spawnVehicle')
AddEventHandler('permanente-fahrzeuge:spawnVehicle', function(model, position, damage)
    SpawnParkedVehicle(model, position, damage)
end)

-- Receive parked vehicles from server
RegisterNetEvent('permanente-fahrzeuge:receiveParkedVehicles')
AddEventHandler('permanente-fahrzeuge:receiveParkedVehicles', function(parkedVehicles)
    DebugPrint('Received ' .. #parkedVehicles .. ' parked vehicles from server')
    
    for _, vehicleData in ipairs(parkedVehicles) do
        -- Store parked vehicle data for respawning
        ParkedVehiclesData[vehicleData.plate] = {
            model = vehicleData.model,
            position = vehicleData.position,
            damage = vehicleData.damage
        }
        
        -- Spawn each vehicle
        SpawnParkedVehicle(vehicleData.model, vehicleData.position, vehicleData.damage, vehicleData.plate)
    end
end)

-- Handle case where vehicles aren't ready yet
RegisterNetEvent('permanente-fahrzeuge:vehiclesNotReady')
AddEventHandler('permanente-fahrzeuge:vehiclesNotReady', function()
    DebugPrint('Server not ready, retrying in 5 seconds...')
    Wait(5000)
    TriggerServerEvent('permanente-fahrzeuge:requestParkedVehicles')
end)

-- Handle vehicles ready notification from server
RegisterNetEvent('permanente-fahrzeuge:vehiclesReady')
AddEventHandler('permanente-fahrzeuge:vehiclesReady', function()
    DebugPrint('Server vehicles are ready, requesting parked vehicles')
    TriggerServerEvent('permanente-fahrzeuge:requestParkedVehicles')
end)

-- Handle vehicle removal from tracking
RegisterNetEvent('permanente-fahrzeuge:removeVehicleFromTracking')
AddEventHandler('permanente-fahrzeuge:removeVehicleFromTracking', function(plate)
    -- Remove from parked vehicles data so it doesn't respawn
    if ParkedVehiclesData[plate] then
        ParkedVehiclesData[plate] = nil
        DebugPrint('Removed vehicle from tracking: ' .. plate)
    end
    
    -- Also remove from spawned vehicles
    if SpawnedVehicles[plate] then
        local vehicle = SpawnedVehicles[plate]
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        SpawnedVehicles[plate] = nil
    end
end)

-- Track vehicles periodically
CreateThread(function()
    while true do
        Wait(Config.SaveInterval)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        -- Save position of current vehicle if player is in one
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local plate = GetVehiclePlate(vehicle)
            if plate and not TrackedVehicles[plate] then
                TrackedVehicles[plate] = vehicle
            end
            SaveVehiclePosition(vehicle)
        end
        
        -- Also track any owned vehicles that were previously driven
        for plate, trackedVehicle in pairs(TrackedVehicles) do
            if DoesEntityExist(trackedVehicle) then
                -- Only save if vehicle is not being driven by player currently
                if trackedVehicle ~= vehicle then
                    SaveVehiclePosition(trackedVehicle)
                end
            else
                -- Vehicle no longer exists, remove from tracking
                TrackedVehicles[plate] = nil
            end
        end
    end
end)

-- Request parked vehicles when player spawns
AddEventHandler('playerSpawned', function()
    Wait(5000) -- Wait 5 seconds after spawn to avoid conflicts
    TriggerServerEvent('permanente-fahrzeuge:requestParkedVehicles')
    DebugPrint('Requested parked vehicles from server (playerSpawned)')
end)

-- On resource start, request parked vehicles
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    
    Wait(5000) -- Wait 5 seconds to ensure everything is loaded
    TriggerServerEvent('permanente-fahrzeuge:requestParkedVehicles')
    DebugPrint('Client loaded, requesting parked vehicles (onClientResourceStart)')
end)

-- Track when player enters a vehicle
CreateThread(function()
    local currentVehicle = 0
    
    while true do
        Wait(1000)
        
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        
        -- Player entered a new vehicle
        if vehicle ~= 0 and vehicle ~= currentVehicle then
            local plate = GetVehiclePlate(vehicle)
            if plate and not TrackedVehicles[plate] then
                TrackedVehicles[plate] = vehicle
                DebugPrint('Started tracking vehicle: ' .. plate)
            end
            currentVehicle = vehicle
        elseif vehicle == 0 and currentVehicle ~= 0 then
            -- Player left vehicle, save its position
            if DoesEntityExist(currentVehicle) then
                SaveVehiclePosition(currentVehicle)
            end
            currentVehicle = 0
        end
    end
end)

-- Monitor spawned parked vehicles and respawn if deleted
CreateThread(function()
    while true do
        Wait(5000) -- Check every 5 seconds
        
        for plate, vehicleData in pairs(ParkedVehiclesData) do
            local spawnedVehicle = SpawnedVehicles[plate]
            
            -- Check if vehicle exists or needs to be respawned
            if not spawnedVehicle or not DoesEntityExist(spawnedVehicle) then
                -- Check if any player is currently using a vehicle with this plate
                local playerPed = PlayerPedId()
                local currentVehicle = GetVehiclePedIsIn(playerPed, false)
                
                -- Don't respawn if player is currently in a vehicle with this plate
                if currentVehicle ~= 0 then
                    local currentPlate = GetVehiclePlate(currentVehicle)
                    if currentPlate == plate then
                        -- Player is in this vehicle, update the spawned reference
                        SpawnedVehicles[plate] = currentVehicle
                        DebugPrint('Updated reference for vehicle being driven: ' .. plate)
                        goto continue
                    end
                end
                
                DebugPrint('Vehicle ' .. plate .. ' was deleted, respawning...')
                SpawnParkedVehicle(vehicleData.model, vehicleData.position, vehicleData.damage, plate)
            end
            
            ::continue::
        end
    end
end)

print('[permanente-Fahrzeuge] Client script loaded')
