--Global var declaration
_G.rubia = require "__rubia__.lib.constants"
require("__rubia__.lib.lib")
require("__rubia__.lib.control-stage")
local event_lib = require("__rubia__.lib.event-lib")

local wind_speed_lib = require("__rubia__.script.wind-speed-visuals")
require("__rubia__.script.chunk-checker")
require("__rubia__.script.trashsteroid-blacklist")
require("__rubia__.script.trashsteroid-spawning")

--require("__rubia__.script.wind-turbine-control")
local landing_cutscene = require("__rubia__.script.landing-cutscene")
require("__rubia__.script.wind-correction")
local init_functions = require("__rubia__.script.init")
require("__rubia__.script.lore-mining")
require("__rubia__.script.entity-swap")
require("__rubia__.script.technology-scripts")
require("__rubia__.script.eyedrops")
require("__rubia__.script.emergency-failsafes")
require("__rubia__.script.version-change-warnings")


--Compatibility calls
require("__rubia__.compat.simple-adjustable-inserters")
require("__rubia__.compat.renai-transportation")
require("__rubia__.compat.pickier-dollies")
require("__rubia__.compat.discovery-tree")
require("__rubia__.compat.factorissimo")
require("__rubia__.compat.surface-condition-rechecks")

--Start of rubia
event_lib.on_event(defines.events.on_surface_created, "rubia-created", function(event)
  if not storage.rubia_surface then
    local surface = game.get_surface(event.surface_index)
    if surface and surface.name == "rubia" then 
      storage.rubia_surface = surface
      surface.peaceful_mode = false
    end
  end
  --wind_speed_lib.try_set_wind_speed()
end)