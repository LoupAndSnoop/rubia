--This file focuses on control-stage scripts to do various things in response to technologies.

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
        on_startup = true,
        execute = function(force) 
            if script.active_mods["maraxsis"] then 
                remote.call("maraxsis-character-modifier","set_light_radius_modifier","rubia-craptonite-lamp",2)
            end
        end
    },

}

--Whenever we startup, go through any scripts tied to things being researched, and execute.
technology_scripts.execute_startup_scripts = function()
    for tech_name, tech_script in pairs(technology_dic) do
        for _, force in pairs(game.forces) do
            if (force.technologies[tech_name] and force.technologies[tech_name].researched
                and tech_script.on_startup) then
                tech_script.execute(force)
            end
        end
    end
end

--Run scripts we need whenever something relevant is researched. Input the relevant LuaTechnology.
technology_scripts.execute_on_research_scripts = function(technology)
    if not technology.valid then return end 
    local tech_script = technology_dic[technology.name]
    if tech_script then tech_script.execute(technology.force) end
end

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
