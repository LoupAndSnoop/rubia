--Based on the work of RockPaperKatana's Extrazoom mod, but then I wound up writing the whole thing from scratch.

if rubia.HAS_ZOOM_ALTERING_MOD then return end

local function set_zoom(player)
    --Default zoom in factorio: closest = {zoom = 3}, furthest = {zoom = 0.15625 = 1/64}, furthest_game_view = {distance = 200, max_distance = 500} 
	local min = 3 --In scale
	local max = 200 --In tiles

    --Technology status alters zoom extents
    local tech = player.force.technologies["rubia-craptonite-eyedrop"]
    local allow_zoom_change = settings.get_player_settings(player.index)["rubia-zoom-change"].value

    if tech and tech.researched and allow_zoom_change then
        min = min --* (1 + 0.01 * rubia.ZOOM_ALTERATION_PERCENT)
        max = max * (1 + 0.01 * rubia.ZOOM_ALTERATION_PERCENT)
    end 

    for controller_type in pairs(defines.controllers) do 
        local zoom_limits = {
                closest = { zoom = min },
                furthest = { distance = max, max_distance = 69420 },        -- same as furthest_game_view, to not allow going chart
                furthest_game_view = { distance = max, max_distance = 69420 }, -- going higher than this goes into "map" view
            }
        if controller_type == "remote" then
            zoom_limits.furthest = { zoom = 1 / 256 } --Allow us to transition to chart
        end
        player.set_zoom_limits(defines.controllers[controller_type], zoom_limits)
    end
end

--Set zoom for all players
local function set_zoom_all()
	for _, player in pairs(game.players) do
		set_zoom(player)
	end
end

--#region Events
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_event({defines.events.on_player_created, defines.events.on_player_joined_game},
    "zoom-extent-edit", function(event)
	set_zoom(game.players[event.player_index])
end)
event_lib.on_event(defines.events.on_runtime_mod_setting_changed, "zoom-extent-edit", function(event)
	if event.setting_type == "runtime-per-user" then
		set_zoom(game.players[event.player_index])
	end
end)

event_lib.on_event(defines.events.on_research_finished, "zoom-extent-edit", set_zoom_all)
event_lib.on_configuration_changed("zoom-extent-edit", set_zoom_all)
--#endregion