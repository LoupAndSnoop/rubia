--Update all thrower inserters to custom trajectories
if not storage.rubia_surface then return end

if not script.active_mods["RenaiTransportation"] then return end

local rubia_wind = require("__rubia__.script.wind-correction")

local entities = storage.rubia_surface.find_entities()
for _, entity in pairs(entities) do
    if (entity and entity.valid and string.find(entity.prototype.name, "RTThrower")) then 
        --rubia_wind.wind_correction(entity, nil)
    end
end