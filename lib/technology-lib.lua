--This file provides information used for both data stage and control stage stage
--to know how techs connect for hiding.

local tech_lib = {}

local rubia_sciences = rubia_lib.array_to_hashset({
    "rubia-biofusion-science-pack", "makeshift-biorecycling-science-pack",
    "ghetto-biorecycling-science-pack","biorecycling-science-pack"})

---Return true if the given technology prototype has a cost associated with being tied
---to Rubia. This is not specific enough to weed out things like research-prod, that
---may have science costs on them automatically tied to my sciences.
----@param technology_prototype
tech_lib.has_rubia_tech_cost = function(technology_prototype)
    assert(type(technology_prototype) ~= type("s"), "Expecting tech prototype, not tech name.")

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

local UNKNOWN_TECH_PREFIX = "rubia-unknown-technology-"

--Return TRUE if the technology name corresponds to an unknown tech placeholder
tech_lib.is_unknown_tech_placeholder = function(technology_name)
    return string.find(technology_name, UNKNOWN_TECH_PREFIX)
end

--Givem the name of a tech, produce the name that should be given to the equiv
--unknown technolgy placeholder. If it already is a unknown technology, then just return it.
tech_lib.get_unknown_tech_name = function(technology_name)
    if tech_lib.is_unknown_tech_placeholder(technology_name) then 
        return technology_name
    else return UNKNOWN_TECH_PREFIX .. technology_name end
end

--Givem the name of a tech, produce the name that should be given to the equiv
--unknown technolgy placeholder. If it already is a unknown technology, then just return it.
tech_lib.get_known_tech_name = function(technology_name)
    if tech_lib.is_unknown_tech_placeholder(technology_name) then 
        return string.sub(technology_name, string.len(UNKNOWN_TECH_PREFIX) + 1, -1)
    else return technology_name end
end

--[[Return true if the given technology name is a rubia tech
tech_hider.is_key_rubia_tech = function(technology_name)
    if key_techs[technology_name] then return true end
    return false
end]]

--tech_hider.get_unknown_tech_names_children

return tech_lib