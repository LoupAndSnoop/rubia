if not script.active_mods["simpleadjustableinserters"] then return end
local rubia_wind = require("__rubia__.script.wind-correction")

---@param event EventData.CustomInputEvent
---@return LuaEntity? inserter
---@return LuaEntityPrototype? prototype
local function find_inserter(event)
    local player = game.get_player(event.player_index)  --[[@as LuaPlayer]]

    local entity = player.selected
    if not entity then return nil, nil end

    if entity.type == "inserter" then
        return entity, entity.prototype
    elseif entity.type == "entity-ghost" and entity.ghost_type == "inserter" then
        return entity, prototypes.entity[entity.ghost_name]
    else
        return nil, nil
    end
end

local function respond_to_rotation(event)
    local inserter, prototype = find_inserter(event)
    if not inserter or not prototype then return end
    rubia_wind.wind_rotation(inserter, event.player_index)
end

script.on_event({"sai_rotate_pickup_clockwise","sai_rotate_pickup_anti_clockwise"},
    respond_to_rotation)

--[[
  local sai_events = {"sai_set_drop_forwards", "sai_set_drop_backwards",
      "sai_rotate_pickup_clockwise","sai_rotate_pickup_anti_clockwise"}
  --script.on_event({"sai_set_drop_forwards", "sai_set_drop_backwards", "sai_rotate_pickup_"}, function(event)
  --  rubia_wind.wind_rotation(event.inserter, event.player_index) 
  --end)

  ]]