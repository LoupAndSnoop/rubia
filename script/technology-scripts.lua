--This file focuses on control-stage scripts to do various things in response to technologies.

tech_lib = require("__rubia__/lib/technology-lib")


local technology_scripts = {}

--Map the name of a tech to the behavior we want to do whenever something is researched.
--on_startup = run the script if the tech is researched on init/config changed/load
local technology_dic = {

    --Disable makeshift/ghetto sci if the progression techs for which they are required are done.
    ["rubia-progression-stage2"] = {
        on_startup = true,
        execute = function(force) force.recipes["makeshift-biorecycling-science-pack"].enabled = false end
    },
    ["craptonite-processing"] = {
        on_startup = true,
        execute = function(force) force.recipes["ghetto-biorecycling-science-pack"].enabled = false end
    },

    --Unique techs
    ["rubia-craptonite-lamp"] = {
        --To test: /c game.planets["maraxsis-trench"].create_surface(); game.players[1].character.teleport( {x=0,y=0}, "maraxsis-trench")
        -- /c game.forces["player"].technologies["rubia-craptonite-lamp"].research_recursive()
        -- /c remote.call("maraxsis-character-modifier","set_light_radius_modifier","rubia-craptonite-lamp", 10)
        on_startup = true,
        execute = function(force) 
            if script.active_mods["maraxsis"] and remote.interfaces["maraxsis-character-modifier"] then 
                local modifier = (force.technologies["rubia-craptonite-lamp"].researched and 1) or 0
                remote.call("maraxsis-character-modifier","set_light_radius_modifier","rubia-craptonite-lamp", modifier)
            end
        end
    },

}

--Whenever we startup, go through any scripts tied to things being researched, and execute.
local execute_startup_scripts = function()
    for tech_name, tech_script in pairs(technology_dic) do
        for _, force in pairs(game.forces) do
            if (force.technologies[tech_name] and force.technologies[tech_name].researched
                and tech_script.on_startup) then
                tech_script.execute(force)
            end
        end
    end
end

---Run scripts we need whenever something relevant is researched. Input the relevant LuaTechnology.
---@param technology LuaTechnology
local execute_on_research_scripts = function(technology)
    if not technology.valid then return end 
    local tech_script = technology_dic[technology.name]
    if tech_script then tech_script.execute(technology.force) end
end


--#region Technology hiding/unhiding


-----@param recursive_sync boolean True => do search recursively to sync

---Make the researched state of the given tech match its actual researched state for that force.
---Tech can be named by known or unknown version
---@param tech_name string
---@param force LuaForce
---@param force_sync_children boolean True => sync children, regardless of recursion
local function sync_unknown_tech(tech_name, force, force_sync_children)
    local orig_tech = force.technologies[tech_lib.get_known_tech_name(tech_name)]

    --In every case, we must non-recursively sync the children
    if force_sync_children then
        for child_name in pairs(orig_tech.successors) do
            sync_unknown_tech(child_name, force, false)
        end
    end

    --If we don't have an unknown tech by that name, syncing this technology is not needed
    if not prototypes.technology[tech_lib.get_unknown_tech_name(tech_name)] then 
        --log("abort sync of: " .. tech_name);
        return end

    --local orig_tech = force.technologies[tech_lib.get_known_tech_name(tech_name)]
    local unknown_tech = force.technologies[tech_lib.get_unknown_tech_name(tech_name)]


    --TODO: unhiding doesn't work well on current engine.
    log("Rubia unhiding behavior might need a mod interface request or a bugfix to have proper unhiding behavior")
    --This is the current workaround kind of
    if _ENV.table_size(unknown_tech.successors) == 0 then unknown_tech.researched = false
    else unknown_tech.researched = orig_tech.researched
    end
    --Intended line I want to end on.
    --unknown_tech.researched = orig_tech.researched --This needs to be done because disabled techs are still enforced prereqs.
    --unknown_tech.researched = false --Should always be false, because researched techs are forced visible.



    orig_tech.visible_when_disabled = false
    unknown_tech.visible_when_disabled = false

    --Unhide if: the original tech in question has been researched, OR all its prereqs are researched
    local should_hide
    if orig_tech.researched then should_hide = false
    else
        should_hide = false
        for _, prereq in pairs(orig_tech.prerequisites) do
            if not prereq.researched 
                and not tech_lib.is_unknown_tech_placeholder(prereq.name) --unk do not block
                and prototypes.get_history("technology", prereq.name).created == "rubia" --Only rubia techs can hide things
                --and tech_lib.has_rubia_tech_cost(prototypes.technology[prereq.name]) --Only Rubia techs can hide things
                then should_hide = true; break; end
        end
    end

    --Apply the hiding to this tech
    orig_tech.enabled = not should_hide
    --unknown_tech.enabled = should_hide --TODO: This should be uncommented after a bugfix
    
    --log("do sync of: " .. tech_name .. ". Should hide = " .. tostring(should_hide))

    --[[We might need to hide/unhide the children. Go sync them recursively.
    if not recursive_sync then return end
    for child_name in pairs(orig_tech.successors) do
        sync_unknown_tech(child_name, force, recursive_sync, false)
    end]]
end

--Go sync ALL unknown techs for all forces
local function sync_all_unknown_techs()
    --Array of all unknown tech placeholders
    local unknown_techs = {}
    for tech_name in pairs(prototypes.technology) do
        if tech_lib.is_unknown_tech_placeholder(tech_name) then
            table.insert(unknown_techs, tech_name)
        --else log("Not syncing: " .. tech_name)
        end
    end
    --log("PING! Unknown techs currently: " .. serpent.block(unknown_techs))

    --Now sync them
    for _, force in pairs(game.forces) do
        for _, tech_name in pairs(unknown_techs) do
            sync_unknown_tech(tech_name, force, true)
        end
    end
end

--#endregion


--Putting everything together

---Take care of all technology updates that have to happen when something is researched.
---@param technology LuaTechnology
technology_scripts.on_research_update = function(technology)
    sync_unknown_tech(technology.name, technology.force, true)
    execute_on_research_scripts(technology)
end

---Run tech-related scripts that should happen whenever booting up the game from a new state.
technology_scripts.on_startup = function()
    sync_all_unknown_techs()
    execute_startup_scripts()
end

--Testing tech hiding sync
_G.rubia.testing.test_sync_tech_hiding = sync_all_unknown_techs



return technology_scripts


--[[Disable makeshift/ghetto sci if the progression techs for which they are required are done.
rubia.check_disable_temporary_science_recipes = function()
    for _, force in pairs(game.forces) do
      if force.technologies["rubia-progression-stage2"].researched then
        force.recipes["makeshift-biorecycling-science-pack"].enabled = false
      end
      if force.technologies["craptonite-processing"].researched then
      --if force.technologies["rubia-progression-stage3"].researched then
        force.recipes["ghetto-biorecycling-science-pack"].enabled = false
      end
    end
  end]]


--/c __rubia__ game.forces["player"].technologies["rubia-progression-stage2"].enabled =false

