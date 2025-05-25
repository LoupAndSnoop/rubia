--This file makes sure that all rubia technologies are blacklisted from discovery tree.
if not script.active_mods["discovery_tree"] then return {} end

--Find all rubia techs, and output an array of all the tech names
local function find_all_rubia_techs()
    local techs = {}
    for name, _ in pairs(prototypes.technology) do
        if prototypes.get_history("technology", name).created == "rubia" then
            table.insert(techs, name)
        end
    end
    return techs
end

local compatibility = {}
function compatibility.update_tech_discovery_blacklist()
    if not script.active_mods["discovery_tree"] 
        or not remote.interfaces["discovery-tree"] then return end

    local rubia_techs = find_all_rubia_techs()
    for _, tech in pairs(rubia_techs) do
        remote.call("discovery-tree", "blacklist_technology", tech)
        log("Blacklisting: " .. tech)
    end
    remote.call("discovery-tree", "force_update")
end

return compatibility

--[[
rubia.timing_manager.register("discovery-tree-update", function() 
    if remote.interfaces["discovery-tree-blacklist"] then
        update_tech_discovery_blacklist()
    end
end)

local do_compatibility = {}
do_compatibility.
rubia.timing_manager.wait_then_do(1, "discovery-tree-update", {})]]