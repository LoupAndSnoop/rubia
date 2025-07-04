require("__rubia__.prototypes.data-script.crapapult-recipes")
require("__rubia__.prototypes.data-script.rubia-surface-blacklist")
require("__rubia__.prototypes.technology-final-fixes")
require("__rubia__.compat.distant-misfires")

--Generic compat calls
for _, entry in pairs(rubia_lib.compat.to_call_on_data_final_fixes) do entry() end

--log(serpent.block(data.raw.planet.nauvis.map_gen_settings.autoplace_settings.entity.settings))

--These lines are exclusively for debugging noise expressions. Do not delete.
--require("__rubia__/prototypes/planet/noise-expression-tests")
--noise_debug.apply_controls()