--This file provides information used for both data stage and control stage stage
--to know how techs connect for hiding.

local tech_hider = {}

--Array of technology names for key technologies that will unlock everything below them until researched.
local key_techs = rubia_lib.array_to_hashset({
    "rubia-progression-stage2",


})

local rubia_sciences = rubia_lib.array_to_hashset({
    "rubia-biofusion-science-pack", "makeshift-biorecycling-science-pack",
    "ghetto-biorecycling-science-pack","biorecycling-science-pack"})

--Return true if the given technology prototype is a rubia technology
tech_hider.is_rubia_tech = function(technology_prototype)
    --Yeet trigger techs
    if technology_prototype.research_trigger and technology_prototype.research_trigger.type == "craft-item"
    and (string.sub(technology_prototype.research_trigger.item,1,5) == "yeet-") then
        return true
    end

    --Check to see if a rubia science is in the research cost
    if technology_prototype.unit and technology_prototype.unit.ingredients then
        for _, entry in pairs(technology_prototype.unit.ingredients) do
            if rubia_sciences[entry[1]] then return true end
        end
    end

    return false --Not one of my sciences!
end

--Return true if the given technology name is a rubia tech
tech_hider.is_key_rubia_tech = function(technology_name)
    if key_techs[technology_name] then return true end
    return false
end

--tech_hider.get_unknown_tech_names_children



return tech_hider