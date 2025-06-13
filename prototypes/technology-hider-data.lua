--Data stage for making hidden technologies.
--The goal here is to make the prototypes for "unknown" technology placeholders.
local tech_lib = require("__rubia__.lib.technology-lib")

--List of techs to never hide.
local hiding_blacklist = rubia_lib.array_to_hashset({
    --"rubia-progression-stage1",
    "rubia-project-trashdragon",
    "planetslib-rubia-cargo-drops",
    "rubia-long-bulk-inserter",
    "rubia-long-stack-inserter",
    "rubia-biofusion-science-pack"
})
--List of tech names to hide, but not their children
local hiding_base_list = rubia_lib.array_to_hashset({
})
--List of techs where we should hide the tech AND all their children, only if the child is a Rubia tech.
--If it is blacklisted, skip (even if parent)
local hiding_parent_list = rubia_lib.array_to_hashset({
    "craptonite-axe",
    "rubia-progression-stage1",
    "rubia-progression-stage1B",
    "rubia-progression-stage2",
    "craptonite-processing",
    "rubia-biofusion-science-pack",
    "rubia-project-trashdragon",
    "planetslib-rubia-cargo-drops",
})

--Mostly disable the tech hiding feature.
if rubia.DISABLE_TECH_HIDING then
    --hiding_parent_list = {}
    --hiding_base_list = {}
    log("WARNING: Rubia Tech hiding feature currently disabled for techs in the middle of the tree.")
    for _, tech in pairs(data.raw["technology"]) do
        if #rubia_lib.get_child_technologies(tech.name) > 0 then hiding_blacklist[tech.name] = true end
    end
end


--Return a prototype for an unknown technology
local function make_unknown_tech_base()
return {
    type = "technology",
    name = "rubia-unknown-technology",
    localised_name = {"technology-name.rubia-unknown-technology"},
    localised_description = {"technology-description.rubia-unknown-technology"},
    icon = "__rubia-assets__/graphics/technology/unknown-technology.png",
    icon_size = 256,
    effects = {},
    prerequisites = {},
    research_trigger = {type="craft-item",  item = "rubia-unknown-technology", count = 69},--10^9}
    show_levels_info = false,
}
end
--Uncraftable-item to make impossible triggers
data:extend({
      {
    type = "item",
    name = "rubia-unknown-technology",
    flags = {"hide-from-bonus-gui", "hide-from-fuel-tooltip", "only-in-cursor"},
    icon = "__rubia-assets__/graphics/icons/unknown-technology-icon.png",
    icon_size = 64,
    order = "l",
    --subgroup = "science-pack",
    color_hint = { text = "T" },

    stack_size = 1,
    default_import_location = "rubia",
    weight = 10000*kg,
    spoil_ticks = 2,
    spoil_result = nil,
    hidden=true,
    hidden_in_factoriopedia=true,
    auto_recycle=false,
  },
})


---Given the name of this technology prototype, make the unknown tech for it,
---connect it to other prototypes, and connect it!
---@param technology_name string
local function make_unknown_tech_of(technology_name)
    local unk_tech = make_unknown_tech_base()

    local orig_tech = data.raw["technology"][technology_name]
    assert(orig_tech, "Invalid name for a technology prototype: " .. tostring(technology_name))
    assert(not tech_lib.is_unknown_tech_placeholder(technology_name), "Cannot make an unknown technology prototype of an unknown technology: " .. technology_name)

    unk_tech.name = tech_lib.get_unknown_tech_name(technology_name)
    assert(not data.raw["technology"][unk_tech.name], "Making duplicate unknown technology for tech: " .. technology_name)
    unk_tech.essential = orig_tech.essential

    local children = rubia_lib.get_child_technologies(technology_name)

    --Tie the children
    for _, child in pairs(children) do
        table.insert(data.raw["technology"][child].prerequisites, unk_tech.name)
    end

    --Tie to parents
    unk_tech.prerequisites = util.table.deepcopy(orig_tech.prerequisites)

    --Mint it
    data:extend({unk_tech})
end

--Make a hashset all tech names to which we should make unknown techs
local function get_techs_to_be_hidden() 
    local to_hide = {}

    --Go through parents that have auto-selected chuldren
    for tech in pairs(hiding_parent_list) do
        to_hide[tech] = true
        for _, child in pairs(rubia_lib.get_child_technologies(tech)) do
            if tech_lib.has_rubia_tech_cost(data.raw["technology"][child]) then
                to_hide[child] = true
            --log("Hiding child = " .. child) else log("Not Hiding child = " .. child) 
            end
        end
    end

    --Direct list
    for tech in pairs(hiding_base_list) do to_hide[tech] = true end
    
    --Blacklist
    for tech in pairs(hiding_blacklist) do 
        if to_hide[tech] then to_hide[tech] = nil end
    end

    --Remove any unknowns in case
    local to_remove = {}
    for tech in pairs(to_hide) do
        if tech_lib.is_unknown_tech_placeholder(tech) then 
            table.insert(to_remove, tech)
        end
    end

    for _, tech in pairs(to_remove) do
        to_hide[tech] = nil;
    end

    --Check for invalid tech names
    for tech in pairs(to_hide) do
        assert(data.raw["technology"][tech], "Invalid tech name when making the unknown tech list: " .. tech)
    end

    return to_hide
end

--Go make all the unknown tech prototypes, and put them in.
local function make_all_unknown_tech_prototypes()
    assert(data.raw["technology"]["rubia-project-trashdragon"], "Unknown techs cannot be made before Rubia techs prototypes are defined.")

    local to_hide = get_techs_to_be_hidden()
    --log("hiding techs: " .. serpent.block(to_hide))
    for tech in pairs(to_hide) do
        make_unknown_tech_of(tech)
    end
end

make_all_unknown_tech_prototypes()