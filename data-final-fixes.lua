require("__rubia__.script.crapapult-recipes")

--Conditionally remove rubia science from promethium science costs
local promethium_tech = data.raw["technology"]["research-productivity"]
if (settings.startup["remove-rubia-from-promethium_sci"].value
    and promethium_tech) then
      for i,entry in pairs(promethium_tech.unit.ingredients) do
        if (entry and entry[1] == "biorecycling-science-pack") then
          table.remove(promethium_tech.unit.ingredients,i)
          break
        end
      end
end


--[[
local handle_lab = true

--(if planetlib exists and we care) or we don't want to populate
if ( (mods["planetslib"] ~= nil and settings.startup["consider-planetslib"].value == true) or settings.startup["automatically-populate-pressure-lab"].value == false) then handle_lab = false end

--After every mod added their sciences to the base lab. I'll add update mine.
if(handle_lab == true) then data.raw["lab"]["pressure-lab"].inputs = data.raw['lab']['lab'].inputs end

]]