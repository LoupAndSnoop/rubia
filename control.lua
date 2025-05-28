--Global var declaration
_G.rubia = require "__rubia__.lib.constants"
require("__rubia__.lib.lib")
require("__rubia__.lib.control-stage")
local event_lib = require("__rubia__.lib.event-lib")

local wind_speed_lib = require("__rubia__.script.wind-speed-visuals")
require("__rubia__.script.chunk-checker")
require("__rubia__.script.trashsteroid-blacklist")
require("__rubia__.script.trashsteroid-spawning")
local landing_cutscene = require("__rubia__.script.landing-cutscene")
local rubia_wind = require("__rubia__.script.wind-correction")
local init_functions = require("__rubia__.script.init")
local trashdragon = require("__rubia__.script.project-trashdragon")
local lore_mining = require("__rubia__.script.lore-mining")
local entity_swap = require("__rubia__.script.entity-swap")
local technology_scripts = require("__rubia__.script.technology-scripts")
local entity_modifier = require("__rubia__.lib.entity-modifier")
require("__rubia__.script.emergency-failsafes")


--Compatibility calls
require("__rubia__.compat.simple-adjustable-inserters")
require("__rubia__.compat.pickier-dollies")
require("__rubia__.compat.discovery-tree")


---Fake quality scaling onto the wind turbine.
local function quality_correct_wind_turbine(entity)
  --For some reason, 5000 = 300 kW
  if entity.valid and entity.name == "rubia-wind-turbine" then
      local quality_mult = 1 + 0.3 * entity.quality.level
      entity.power_production = entity.power_production * quality_mult
      entity.electric_buffer_size = entity.electric_buffer_size * quality_mult
   end
end
event_lib.on_built("wind-turbine-quality", quality_correct_wind_turbine)

--Start of rubia
event_lib.on_event(defines.events.on_surface_created, "rubia-created", function(event)
  if not storage.rubia_surface then
    local surface = game.get_surface(event.surface_index)
    if surface and surface.name == "rubia" then storage.rubia_surface = surface end
  end
  --wind_speed_lib.try_set_wind_speed()
end)

--To delete everything else once I know the new event system is stable

--[[
script.on_event(defines.events.on_technology_effects_reset, function(event)
  technology_scripts.on_startup()
  trashsteroid_lib.update_difficulty_scaling()
end)
--check_disable_temporary_science_recipes() --One check at startup
script.on_event(defines.events.on_research_finished, function(event)
  technology_scripts.on_research_update(event.research)
  trashsteroid_lib.update_difficulty_scaling()
end)]]



--#endregion


--#region Faux quality scaling





--#endregion

--Cutscene and surface-change related things

--[[script.on_event(defines.events.on_player_changed_surface, function(event)
  if game.get_surface("rubia") then
    chunk_checker.try_update_player_pos(game.get_player(event.player_index), game.get_surface("rubia"))
  end
end)]]

--[[script.on_event(defines.events.on_player_died, function(event)
  landing_cutscene.cancel_on_player_death(event)
end)

script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
  landing_cutscene.try_start_cutscene(event)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  landing_cutscene.check_respawn_off_rubia(event)
end)

script.on_event(defines.events.on_space_platform_changed_state, function(event)
  landing_cutscene.check_initial_journey_warning(event)
end)]]



-------Scripts to subscribe functions to events tied to building/modifying

--[[ Scripts to execute rotation-corrections
script.on_event({defines.events.on_player_flipped_entity, defines.events.on_player_rotated_entity}, function(event)
  rubia_wind.wind_rotation(event.entity, event.player_index)
end)
script.on_event(defines.events.on_entity_settings_pasted, function(event)
  rubia_wind.wind_rotation(event.destination, event.player_index)
end)]]


--[[
local function do_on_built_changes(event)
  entity_swap.try_entity_swap(event)
  if not event.entity.valid or event.entity.surface.name ~= "rubia" then return end

  --Consolidate robot/player events
  local player_index = event.player_index
  if not player_index and event.robot and event.robot.valid then
    local cell = event.robot.logistic_cell
    local owner = cell and cell.owner
    player_index = owner and owner.is_player() and owner.player.player_index
  end

  rubia_wind.wind_rotation(event.entity, player_index)
  quality_correct_wind_turbine(event.entity)
  --entity_modifier.update_on_build(event.entity)
  chunk_checker.register_new_entity(event.entity)
end
event_lib.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity,
  defines.events.script_raised_built, defines.events.script_raised_revive}, 
  "general-on-built", function(event) 
  do_on_built_changes(event)
end)]]


--event_lib.on_built_early("entity-swap", entity_swap.try_entity_swap)


--event_lib.on_built("chunk-checker-register", function(entity)
--  if entity.surface.name == "rubia" then chunk_checker.register_new_entity(entity) end end)

--[[
script.on_event(defines.events.on_object_destroyed, function(event)
  chunk_checker.delist_entity(event.registration_number)
  --entity_modifier.update_on_object_destroyed(event.registration_number)
end)
]]



--#region UI


--entity_swap.rocket_silo_update(entity, player_index) --TODO: On experimental released



--[[
---Combine calls that happen on any gui updating event.
---@param player_index uint
local function on_entity_gui_update(entity, player_index)
  if entity.valid then 
      --For adjustable inserters
      rubia_wind.wind_rotation(entity, player_index)
      --entity_swap.rocket_silo_update(entity, player_index) --TODO: On experimental released
  end
end

script.on_event(defines.events.on_gui_closed, function(event)
  --Entity UI
  if event.gui_type == defines.gui_type.entity and event.entity
    and event.entity.valid then 
    on_entity_gui_update(event.entity, event.player_index)
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local player = game.players[event.player_index]
  if player.opened_gui_type == defines.gui_type.entity 
    and player.opened.object_name == "LuaEntity" then
      on_entity_gui_update(player.opened, event.player_index)
  end
end)]]


--#endregion


-- Special cases for mods that do adjustment events for adjustable inserters



--------------------

--[[script.on_event(defines.events.on_gui_opened, function(event)
  entity_swap.try_modified_gui(event)
end)]]


--------------------

--- Asteroid and on-tick Management



--[[
script.on_event(defines.events.on_player_changed_position, function(event)
  chunk_checker.try_update_player_pos(game.get_player(event.player_index), storage.rubia_surface)
end)


script.on_nth_tick(1,function()
  rubia.timing_manager.update()
  trashsteroid_lib.try_spawn_trashsteroids()
end)

script.on_nth_tick(3, function()
  trashsteroid_lib.update_trashsteroid_rendering()

  --trashsteroid_lib.try_spawn_trashsteroids()
end)

--Trashsteroid Impact checks
script.on_nth_tick(4, function()
  trashsteroid_lib.trashsteroid_impact_update()
end)

--Rough updates
script.on_nth_tick(10, function()
  wind_speed_lib.fluctuate_wind_speed(10)
end)
script.on_nth_tick(60 * 10, function()
  trashsteroid_lib.reset_failsafe()
end)]]

--event_lib.on_nth_tick(1, "timing-manager", rubia.timing_manager.update)



--[[
----Mining item checks
event_lib.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity},
  "lore-mining", function(event)
  lore_mining.try_lore_when_mined(event.entity)
end)
]]



-----------

--Initialization





--[[Initialization/loadup
script.on_init(function()
  init_functions.hard_initialize()
  init_functions.on_every_load()
  technology_scripts.on_startup()
  trashsteroid_lib.update_difficulty_scaling()
end)

script.on_configuration_changed(function()
  init_functions.hard_initialize()
  technology_scripts.on_startup()
  trashsteroid_lib.update_difficulty_scaling()
end)

script.on_load(function()
  init_functions.on_every_load()
end)]]


--[[Protect collectors from having items added to them
script.on_event(defines.events.on_player_fast_transferred, function(event)
  --If adding things in to a garbo gatherer, undo it.
  if (event.from_player --Adding things in
  and event.entity and event.entity.valid
  and event.entity.name == "garbo-grabber") then
    local player_inv = game.get_player(event.player_index).get_inventory(defines.inventory.character_main)
    local collector_inv = event.entity.get_inventory(defines.inventory.chest)
    
    --TODO: Transfer everything back

  end
end)]]


-------

--storage.rubia_surface.wind_speed = 10 / 6000; storage.rubia_surface.wind_orientation = defines.direction.east; storage.rubia_surface.wind_orientation_change = 0;
