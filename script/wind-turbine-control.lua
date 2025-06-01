--This file is for runtime-controls of the wind turbine.

local event_lib = require("__rubia__.lib.event-lib")



---Fake quality scaling onto the wind turbine.
local function quality_correct_wind_turbine(entity)
    if not entity.valid then return end

    local true_name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
    --For some reason, 5000 = 300 kW
    if true_name == "rubia-wind-turbine" then
        --Also set inoperable, as this is on the LuaEntity, not proto
        entity.operable = false

        --Can only modify elec energy interface for non-ghost.
        if entity.name ~= "entity-ghost" then
            local quality_mult = 1 + 0.3 * entity.quality.level
            entity.power_production = entity.power_production * quality_mult
            entity.electric_buffer_size = entity.electric_buffer_size * quality_mult
        end
    end
end
event_lib.on_built("wind-turbine-quality", quality_correct_wind_turbine)