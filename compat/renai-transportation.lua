if not script.active_mods["RenaiTransportation"] then return end

local rubia_wind = require("__rubia__.script.wind-correction")

local EJECTOR_HATCH = "RTThrower-EjectorHatchRT"

---For a given renai thrower, get the position where the throw should start.
---comment
---@param thrower LuaEntity
---@return MapPosition
local function start_throw_position(thrower)
    --Ejectors are unique
    local pickup_position = thrower.pickup_position
    local inserter_base = thrower.position
    local pickup_dist = math.sqrt((inserter_base.x - pickup_position.x)^2 + (inserter_base.y - pickup_position.y)^2)
    --Thrower seems to extend by +1 unit at the peak
    local arm_length = math.max(0, pickup_dist) + 1

    --Ejectors have a unique start point
    if thrower.prototype.name == EJECTOR_HATCH then
        return {x = inserter_base.x + 0.6, y = inserter_base.y - 0.4, }
    end

    --Thrower rotates to 30deg clockwise of north
    --sin30 = 0.5, sin60 = 0.86602. Do trigonometry: x = xo + r sin 30, y = yo - r cos 30
    return {x = inserter_base.x + arm_length * 0.5,
        y = inserter_base.y - arm_length * 0.86602 }
end

--Special case for thrower inserters, to adjust their orientation and trajectory
remote.add_interface("rubia-thrower-trajectories", {
    sinusoid = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = start_throw_position(thrower), thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 
        
        local path = {}
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / total_ticks-- + 0.00001
            table.insert(path, {
                x= start_pos.x + dimensionless_time * delta_x,
                y = start_pos.y + dimensionless_time * delta_y 
                    - 2 * math.sin(3 * 2 * 3.14159 * dimensionless_time),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            })
        end
        --game.print(serpent.block(path))
        return path
    end,

    corkscrew = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = start_throw_position(thrower), thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 

        local path = {}
        local revolutions = math.min(4, math.max(2, math.floor(delta_x / 4)))
        local radius = math.min(1.5, math.max(0.5, delta_x / 5))
        local start_x, start_y = start_pos.x, start_pos.y --Optimize because we're about to do a lot of these
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / (total_ticks + 0.0001)--0.00001)
            local theta = 2 * 3.14159 * revolutions * dimensionless_time
            local entry = {
                x= start_x + dimensionless_time * delta_x
                    + radius * math.cos(theta) - radius,
                y = start_y + dimensionless_time * delta_y 
                    + radius * math.sin(theta),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            }
            table.insert(path, entry)
        end
        return path
    end
})

local function force_thrower_orientation(entity, player_index)
    rubia_wind.force_orientation_to(entity, player_index, defines.direction.west)
    
    --Make funny trajectory
    if not remote.interfaces["RenaiTransportation"] then return end

    local trajectory_type = "corkscrew"
    if entity.prototype.name == EJECTOR_HATCH then trajectory_type = "sinusoid" end

    local delta_x = math.abs(entity.drop_position.x - entity.position.x)
    --Special trajectories disabled OR too close range => clear
    if not settings.global["rubia-renai-special-trajectories"].value
        or (delta_x <= 5) then
        remote.call("RenaiTransportation", "ClearTrajectoryAdjust", entity)

    else
        local trajectory = {type="interface_fixed", interface="rubia-thrower-trajectories",  --"interface_dynamic"
            name = trajectory_type,
            parameters={start_pos = entity.position, end_pos = entity.drop_position}}

        remote.call("RenaiTransportation", "SetTrajectoryAdjust", entity, trajectory)
    end

end

--Special cases for compatibility with Renai
--local force_thrower_orientation
for _, prototype in pairs(prototypes.entity) do
    --Throwers must be rotated
    if (string.find(prototype.name, "RTThrower")) then 
        rubia_wind.assign_wind_behavior(prototype.name,
            {wind_type = "custom", custom = force_thrower_orientation})
    end
end
rubia_wind.update_wind_behavior()


--Renai transportation: Focused flinging event calls.
if script.active_mods["RenaiTransportation"] then
    script.on_event({"RTtcaretnI", "RTInteract"}, function(event)
        local player = event.player_index and game.players[event.player_index]
        if not player.surface or player.surface.name ~= "rubia" then return end --wrong surface
        local entity = player.selected
        if entity and entity.valid then
            rubia_wind.wind_correction(entity, player_index)
        end
        --local search_area = --local spot = event.cursor_position
        --wind_correct_position(search_area, player_index)
    end
    )
end


--Update the status of all thrower inserters.
local function update_all_thrower_inserters()
    if not storage.rubia_surface then return end
    local entities = storage.rubia_surface.find_entities_filtered{type = "inserter"}
    for _, entity in pairs(entities) do
        if (entity and entity.valid and string.find(entity.prototype.name, "RTThrower")) then 
            rubia_wind.wind_correction(entity, nil)
        end
    end
end


local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_event(defines.events.on_runtime_mod_setting_changed, 
    "rubia-renai-special-trajectories", function(event)
    if event.setting == "rubia-renai-special-trajectories" then update_all_thrower_inserters() end
end)
event_lib.on_configuration_changed("rubia-renai-special-trajectories", function(event)
    update_all_thrower_inserters()
end)

--#region Renai old version that was in the wind correction file
--[[
--Special case for thrower inserters, to adjust their orientation and trajectory
remote.add_interface("rubia-thrower-trajectories", {
    sinusoid = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = thrower.held_stack_position, thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 
        
        local path = {}
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / total_ticks-- + 0.00001
            table.insert(path, {
                x=start_pos.x + dimensionless_time * delta_x,
                y = start_pos.y + dimensionless_time * delta_y 
                    + 2 * math.sin(3 * 2 * 3.14159 * dimensionless_time),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            })
        end
        --game.print(serpent.block(path))
        return path
    end,

    corkscrew = function(parameters, total_ticks, thrower)
        local start_pos, end_pos = thrower.held_stack_position, thrower.drop_position--parameters.start_pos, parameters.end_pos
        local delta_x, delta_y = end_pos.x - start_pos.x, end_pos.y - start_pos.y 

        local path = {}
        local revolutions = math.min(4, math.max(2, math.floor(delta_x / 4)))
        local radius = math.min(1.5, math.max(0.5, delta_x / 5))
        for i = 0, total_ticks, 1 do
            local dimensionless_time = i / (total_ticks + 0.0001)--0.00001)
            local theta = 2 * 3.14159 * revolutions * dimensionless_time
            local entry = {
                x= start_pos.x + dimensionless_time * delta_x
                    + radius * math.cos(theta) - radius,
                y = start_pos.y + dimensionless_time * delta_y 
                    + radius * math.sin(theta),
                height = -(dimensionless_time) * (dimensionless_time - 1),
            }
            table.insert(path, entry)
            --assert(tostring(dimensionless_time) ~= tostring(0/0) and tostring(dimensionless_time) ~= tostring(-(0/0)),
            --    "Got a nan for t for total ticks = " .. tostring(total_ticks) .. ": " .. serpent.line(start_pos) .. " - " .. serpent.line(end_pos))
            --assert(tostring(entry.x) ~= tostring(0/0) and tostring(entry.x) ~= tostring(-(0/0)),
            --    "Got a nan for x for: " .. serpent.line(start_pos) .. " - " .. serpent.line(end_pos))
            --assert(tostring(entry.y) ~= tostring(0/0) and tostring(entry.y) ~= tostring(-(0/0)),
            --    "Got a nan for y for: " .. serpent.line(start_pos) .. " - " .. serpent.line(end_pos))
        end
        --game.print(serpent.block(path))
        return path
    end
})
local function force_thrower_orientation(entity, player_index)
    force_orientation_to(entity, player_index, defines.direction.west)
    
    --Make funny trajectory
    if remote.interfaces["RenaiTransportation"] then
        local delta_x = math.abs(entity.drop_position.x - entity.position.x)
        --Only if far enough away, and special trajectories enabled.
        if delta_x > 5 and settings.global["rubia-renai-special-trajectories"].value then
            local trajectory = {type="interface_fixed", interface="rubia-thrower-trajectories",  --"interface_dynamic"
                name = "corkscrew",--name="sinusoid",
                parameters={start_pos = entity.position, end_pos = entity.drop_position}}

            remote.call("RenaiTransportation", "SetTrajectoryAdjust", entity, trajectory)
        else
            remote.call("RenaiTransportation", "ClearTrajectoryAdjust", entity)
        end
    end
end
--Special cases for compatibility with Renai
--local force_thrower_orientation
for _, prototype in pairs(prototypes.entity) do
    --Throwers must be rotated
    if (string.find(prototype.name, "RTThrower")) then 
        wind_entity_dic[prototype.name] = {wind_type = "custom", custom = force_thrower_orientation}
        --wind_entity_dic[prototype.name] = {wind_type = "force-to", orient=defines.direction.west} --Old version. Works until new interface
    end
end
]]
--#endregion
