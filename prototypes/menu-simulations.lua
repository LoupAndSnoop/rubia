
--File is derived from skewer's shatted planet.

--Delete other sims for testing purposes.
--data.raw["utility-constants"]["default"].main_menu_simulations = {}

local main_menu_simulations = data.raw["utility-constants"]["default"].main_menu_simulations
local make_simulation = function(duration, init_update_count, planet, filename, script)
return
{
    checkboard = false,
    save = filename,
    length = duration,
    game_view_settings = {
        show_quickbar = false,
        show_shortcut_bar = false,
        show_minimap = false,
        show_toolbar = false,
    },
    init_update_count = init_update_count or 0,

    mods = (planet == "rubia") and {"rubia"} or {},
    init =
    [[
    local sim_planet = game.surfaces["]] .. planet .. [["]
    local logo = sim_planet.find_entities_filtered{name = "factorio-logo-11tiles", limit = 1}[1]
    logo.destructible = false
    local center = {logo.position.x, logo.position.y+9.75}
    game.simulation.camera_surface_index = sim_planet.index
    game.simulation.camera_position = center
    game.simulation.camera_zoom = 1
    game.tick_paused = false

    for _, force in pairs(game.forces) do
        force.set_turret_attack_modifier("gun-turret", 0.1)
    end
    if ]] .. planet .. [[ == "rubia" then
        for _, player in pairs(game.players) do
            player.teleport({center[1]-9,center[2]}, game.get_surface("rubia"), true)
        end
    end
    ]]
    ..
    script
}
end

main_menu_simulations.rubia_sim_001 = make_simulation(60 * 16, 60*1, "rubia", "__rubia-assets__/menu-simulations/rubia-title-sim-gun-belts.zip", [[]])
main_menu_simulations.rubia_sim_002 = make_simulation(60 * 25, 0, "rubia", "__rubia-assets__/menu-simulations/rubia-title-sim-trashsteroid-destruction.zip", [[]])
main_menu_simulations.rubia_sim_003 = make_simulation(60 * 15, 0, "nauvis", "__rubia-assets__/menu-simulations/rubia-title-sim-trains.zip", [[]])


--[[Double define for greater chances
main_menu_simulations.rubia_sim_001_2 = main_menu_simulations.rubia_sim_001
main_menu_simulations.rubia_sim_002_2 = main_menu_simulations.rubia_sim_002
main_menu_simulations.rubia_sim_003_2 = main_menu_simulations.rubia_sim_003]]