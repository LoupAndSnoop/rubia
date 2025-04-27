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

--These lines are exclusively for debugging noise expressions. Do not delete.
--require("__rubia__/prototypes/planet/noise-expression-tests")
--noise_debug.apply_controls()