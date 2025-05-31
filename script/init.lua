--local discovery_tree = require("__rubia__.compat.discovery-tree")
local chunk_checker = require("__rubia__.script.chunk-checker")

local init_functions = {}

--#region Warnings
--Give a warning if Rubia is not removed from promethium sci, when 
--you just downloaded the mod, and you DO have some ranks of it.
storage.promethium_warning_done = storage.promethium_warning_done or false
storage.rocketizer_warning_done = storage.rocketizer_warning_done or false

--Warning functions to queue up
local WARNING_PRINT_SETTINGS = {color={r=1,g=0.4,b=0.4,a=1}}

rubia.timing_manager.register("promethium-warning-part1", function(player)
    if (not storage.promethium_warning_done) then
        game.print({"alert.promethium_warning"},WARNING_PRINT_SETTINGS)
        storage.promethium_warning_done = true
        player.play_sound({path = "utility/console_message"})
    end
end)
rubia.timing_manager.register("promethium-warning-part2", function(player)
    game.print({"alert.promethium_warning-part2"},WARNING_PRINT_SETTINGS)
end)

local function promethium_warning()
    local player = game.forces["player"]
    if not settings.startup["remove-rubia-from-promethium_sci"].value
        and player.technologies["research-productivity"]
        and (player.technologies["research-productivity"].level > 1)
        and not (player.players and player.players[1] and player.players[1].cheat_mode)
        and not storage.promethium_warning_done then

        --We need to give a warning, but game is not open yet.
        rubia.timing_manager.wait_then_do(30, "promethium-warning-part1", {player})
        rubia.timing_manager.wait_then_do(90, "promethium-warning-part2", {player})
    end
end
---------

--Warning functions to queue up
rubia.timing_manager.register("rubia-rocketizer-warning", function(player)
    if (not storage.rocketizer_warning_done) then
        game.print({"alert.rocketizer-warning"},WARNING_PRINT_SETTINGS)
        storage.rocketizer_warning_done = true
        player.play_sound({path = "utility/console_message"})
    end
end)

local function rocketizer_warning()
    local player = game.forces["player"]

    --Check for the relevant entity on all surfaces:
    local entity_dic = rubia_lib.find_all_entity_of_name("rci-rocketizer")
    local has_rocketizer = false
    for _, list in pairs(entity_dic) do
        if #list > 0 then
            has_rocketizer = true
            break
        end
    end

    if not settings.startup["rubia-rocketizer-early-unlock"].value
        and has_rocketizer
        and not storage.rocketizer_warning_done then

        --We need to give a warning, but game is not open yet.
        rubia.timing_manager.wait_then_do(120, "rubia-rocketizer-warning", {player})
    end
end
--#endregion


--Hard re-initialize. Nuke data, and recalculate everything the mod needs. Helpful for when everything is fucked.
function init_functions.hard_initialize()
    chunk_checker.init()
    trashsteroid_lib.hard_refresh()
end

--[[Everything to be done every time we boot up the game, via init OR load
function init_functions.on_every_load()
    --picker_dollies.add_picker_dollies_blacklists()
    --if discovery_tree.update_tech_discovery_blacklist then discovery_tree.update_tech_discovery_blacklist() end
end]]


--#region Event subscription
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_init("hard-initialize", init_functions.hard_initialize)
event_lib.on_configuration_changed("hard-initialize", init_functions.hard_initialize)

event_lib.on_init("initial-warning-promethium", promethium_warning)
event_lib.on_init("initial-warning-rocketizer", rocketizer_warning)

--event_lib.on_init("every-load", init_functions.on_every_load)
--event_lib.on_load("every-load", init_functions.on_every_load)

--#endregion

return init_functions