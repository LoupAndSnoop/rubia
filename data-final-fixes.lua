


require("__rubia__.script.crapapult-recipes")

--[[
local handle_lab = true

--(if planetlib exists and we care) or we don't want to populate
if ( (mods["planetslib"] ~= nil and settings.startup["consider-planetslib"].value == true) or settings.startup["automatically-populate-pressure-lab"].value == false) then handle_lab = false end

--After every mod added their sciences to the base lab. I'll add update mine.
if(handle_lab == true) then data.raw["lab"]["pressure-lab"].inputs = data.raw['lab']['lab'].inputs end

]]