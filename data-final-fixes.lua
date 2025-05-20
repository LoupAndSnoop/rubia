require("__rubia__.script.crapapult-recipes")
require("__rubia__.script.rubia-surface-blacklist")

--Remove that science pack from the cost of the given technology (if the tech exists, and if it is there.
local function remove_science_pack_from_tech(science_pack_name, technology_name)
    local tech = data.raw["technology"][technology_name]
    if (not tech) then return end --Tech not found

    for i,entry in pairs(tech.unit.ingredients) do
        if (entry and entry[1] == science_pack_name) then
            table.remove(tech.unit.ingredients,i)
            break
        end
    end

end

--Conditionally remove rubia science from promethium science costs
if settings.startup["remove-rubia-from-promethium_sci"].value then
    remove_science_pack_from_tech("biorecycling-science-pack", "research-productivity")
end

--Remove biofusion from anywhere it accidentally got into.
remove_science_pack_from_tech("rubia-biofusion-science-pack", "research-productivity")

--[[
local promethium_tech = data.raw["technology"]["research-productivity"]
if (settings.startup["remove-rubia-from-promethium_sci"].value
    and promethium_tech) then
      for i,entry in pairs(promethium_tech.unit.ingredients) do
        if (entry and entry[1] == "biorecycling-science-pack") then
          table.remove(promethium_tech.unit.ingredients,i)
          break
        end
      end
end]]

--These lines are exclusively for debugging noise expressions. Do not delete.
--require("__rubia__/prototypes/planet/noise-expression-tests")
--noise_debug.apply_controls()