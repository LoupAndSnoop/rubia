--This file is for runtime-controls of the wind turbine.
local wind_turbine = {}
local event_lib = require("__rubia__.lib.event-lib")
--True => wind turbines are implemented as EEI, not solar panels.
local EEI_MODE = prototypes.entity["rubia-wind-turbine"].type == "electric-energy-interface"

local function initialize_storage()
    ---@type table<uint, uint> Table of (wind_turbine_id) => (wind_turbine rendering id)
    storage.wind_turbine_renders = storage.wind_turbine_renders or {}
end

---Fake quality scaling onto the wind turbine for EEI mode.
---Assume this is a valid wind turbine
local function quality_correct_wind_turbine(entity)
    --For some reason, 5000 = 300 kW
    --Also set inoperable, as this is on the LuaEntity, not proto
    entity.operable = false

    --Can only modify elec energy interface for non-ghost.
    if entity.name ~= "entity-ghost" then
        local quality_mult = 1 + 0.3 * entity.quality.level
        entity.power_production = entity.power_production * quality_mult
        entity.electric_buffer_size = entity.electric_buffer_size * quality_mult
    end
end

---Add the LuaRendering for a given wind turbine. Assume that this is actually a valid wind-turbine.
---@param entity LuaEntity
local function try_add_turbine_rendering(entity)
    if entity.type == "entity-ghost" then return end 

    local deregister_id = script.register_on_object_destroyed(entity)
    if storage.wind_turbine_renders[deregister_id] then return end --We already have one

    local render = rendering.draw_animation{
        animation = "rubia-wind-turbine-animation",
        --render_layer="object",
        xscale = 1, yscale = 1,
        target= entity,
        surface=entity.surface,
    }

    storage.wind_turbine_renders[deregister_id] = render.id
end

---Entity deregistration ID goes in. If it is a wind turbine, then clear its stored data.
local function on_wind_turbine_destroyed(deregistration_id)
    storage.wind_turbine_renders[deregistration_id] = nil
end

--Destroy ALL renderings of wind turbines
local function remove_all_turbine_renderings()
    local to_remove = rubia_lib.find_entity_renderings("rubia-wind-turbine", true)
    for _, entry in pairs(to_remove) do entry.destroy() end
    storage.wind_turbine_renders = {}
end


---Do all the updates associated with a wind-turbine.
---@param entity LuaEntity
local function update_wind_turbine(entity)
    if not entity.valid then return end

    local true_name = entity.name == "entity-ghost" and entity.ghost_name or entity.name
    if true_name ~= "rubia-wind-turbine" then return end

    if EEI_MODE then
        quality_correct_wind_turbine(entity)
    else
        entity.operable = true
        --try_add_turbine_rendering(entity)
    end
end


--Refresh the quality correction etc on all turbines
function wind_turbine.hard_refresh_all_turbines()
    --[[
    remove_all_turbine_renderings()

    local all_entity = rubia_lib.find_all_entity_of_name("rubia-wind-turbine")
    for _, entity_list in pairs(all_entity or {}) do
        for _, entity in pairs(entity_list or {}) do
            update_wind_turbine(entity)
        end
    end
    ]]
end

--Events

event_lib.on_built("wind-turbine-update", update_wind_turbine)

if not EEI_MODE then 
    event_lib.on_init("wind-turbine-storage", initialize_storage)
    event_lib.on_configuration_changed("wind-turbine-storage", initialize_storage)
    event_lib.on_event(defines.events.on_object_destroyed,
        "wind-turbine-destroyed", on_wind_turbine_destroyed)
end

return wind_turbine