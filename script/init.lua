local picker_dollies = require("__rubia__.compat.pickier-dollies")

local init_functions = {}

--Give a warning if Rubia is not removed from promethium sci, when 
--you just downloaded the mod, and you DO have some ranks of it.
storage.promethium_warning_done = storage.promethium_warning_done or false

--Warning functions to queue up
rubia.timing_manager.register("promethium-warning-part1", function(player)
    if (not storage.promethium_warning_done) then
        game.print({"alert.promethium_warning"},{color={r=0.9,g=0.2,b=0.2,a=1}})
        storage.promethium_warning_done = true
        player.play_sound({path = "utility/console_message"})
    end
end)
rubia.timing_manager.register("promethium-warning-part2", function(player)
    game.print({"alert.promethium_warning-part2"},{color={r=0.9,g=0.2,b=0.2,a=1}})
end)

local function promethium_warning()
    local player = game.forces["player"]
    if not settings.startup["remove-rubia-from-promethium_sci"].value
        and player.technologies["research-productivity"]
        and (player.technologies["research-productivity"].level > 1)
        and not (player.players and player.players[1] and player.players[1].cheat_mode)
        and not storage.promethium_warning_done then

        --We need to give a warning, but game is not open yet.
        rubia.timing_manager.wait_then_do(10, "promethium-warning-part1", {player})
        rubia.timing_manager.wait_then_do(90, "promethium-warning-part2", {player})
    end
end




--Hard re-initialize. Nuke data, and recalculate everything the mod needs. Helpful for when everything is fucked.
function init_functions.hard_initialize()
    promethium_warning()
    chunk_checker.init()
    trashsteroid_lib.hard_refresh()
end

--Everything to be done every time we boot up the game, via init OR load
function init_functions.on_every_load()
    picker_dollies.add_picker_dollies_blacklists()
end

return init_functions


--picker_dollies.add_picker_dollies_blacklists()