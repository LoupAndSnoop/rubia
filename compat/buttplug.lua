
--Based on work by ashkitten for Cubutt
local buttplug = {}

-- Try to activate thle buttplug with the given parameters, if applicable.
local function ButtpugUpdate()
    if game.simulation then return end
    storage.buttplug_status = storage.buttplug_status or {intensity = 0, end_timestamp = -1}
    
    if storage.buttplug_status.end_timestamp > game.tick then
        helpers.write_file("buttplug.commands", string.format("%f",storage.buttplug_status.intensity) .. "\n")
    elseif storage.buttplug_status.end_timestamp == game.tick then
        helpers.write_file("buttplug.commands", "0.0\n")
        storage.buttplug_status = nil
    end
end

--Try to enqueue a specific buttplug intensity for the given number of ticks.
buttplug.TryEnqueueButtplug = function(intensity, ticks)
    storage.buttplug_status = storage.buttplug_status or {intensity = 0, end_timestamp = -1}
    
    -- Priority is given to the most intense activation.
    if storage.buttplug_status.intensity < intensity then
        storage.buttplug_status = {intensity = intensity, end_timestamp = game.tick + ticks}
    -- If equal, then allow the timer to extend.
    elseif storage.buttplug_status.intensity == intensity then
        storage.buttplug_status = {intensity = intensity,
            end_timestamp = math.max(game.tick + ticks, storage.buttplug_status.end_timestamp)}
    end
end

if settings.startup["rubia-buttplug-integration"].value then
    local event_lib = require("__rubia__.lib.event-lib")
    event_lib.on_nth_tick(1, "buttplug_update", ButtpugUpdate)
else 
    --Make the enqueue function a do-nothing functions, to save UPS
    buttplug.TryEnqueueButtplug = function(intensity, ticks) end
end

return buttplug
--local buttplug = require("__rubia__.compat.buttplug")