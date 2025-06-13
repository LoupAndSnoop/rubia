

--[[Maraxsis remote interfaces
local external_light_modifiers = {}
local base_light_radius = 0
---The given source will add the given value to the light radius.
---@param source_key string A unique string to allow overwriting the previous source of a modifier.
---@param value double The actual bonus light radius to be added to the base.
local function set_light_modifier(source_key, value)
    if value and value ~= 0 then external_light_modifiers[source_key] = value --Told to have a modifier
    else external_light_modifiers[source_key] = nil --Told to remove modifier
    end

    --Update the base value from scratch
    base_light_radius = 0
    for _, entry in pairs(external_light_modifiers) do
        base_light_radius = base_light_radius + entry
    end
    --In case anyone gets spicey with negative light. >:(
    if base_light_radius < 0 then base_light_radius = 0 end
end

--Define the interface to modify underwater parameters
remote.add_interface("maraxsis-character-modifier",{
    set_light_modifier = set_light_modifier,
})
]]

--remote.call("maraxsis-character-modifier","set_light_modifier",{"rubia",3})


--Maraxsis remote interfaces
local external_modifiers = {light_radius = {}, swim_speed = {}}
local base_character_values = {light_radius = 0, swim_speed = 0}
---The given source will add the given value to light radius or other maraxsis modifiers.
---@param source_key string A unique string to allow overwriting the previous source of a modifier.
---@param modifier_type string string tied to the type of parameter to control. See relevant dic
---@param modifier double The actual bonus value to be added
local function set_modifier(source_key, modifier_type, modifier)
    local modifier_list = external_modifiers[modifier_type]
    assert(modifier_list, "Invalid modifier type for Maraxsis: " .. modifier_type)

    if modifier and modifier ~= 0 then modifier_list[source_key] = modifier --Told to have a modifier
    else modifier_list[source_key] = nil --Told to remove modifier
    end

    --Update the base value from scratch
    local base_value = 0
    for _, entry in pairs(modifier_list) do
        base_value = base_value + entry
    end
    --In case anyone gets spicey with negatives. >:(
    if base_value < 0 then base_value = 0 end

    base_character_values[modifier_type] = base_value
end

--Define the interface to modify underwater parameters
remote.add_interface("maraxsis-character-modifier",{
    set_light_radius_modifier = function(source_key, modifier) set_modifier(source_key, "light_radius", modifier) end,
    set_swim_speed_modifier =   function(source_key, modifier) set_modifier(source_key, "swim_speed", modifier) end,
})

--------


local blacklist = {}
local function set_blacklisted_tech(technology_name, to_blacklist)
    if to_blacklist then blacklist[technology_name] = true
    elseif blacklist[technology_name] then blacklist[technology_name] = nil end
end

--Define the interface to modify underwater parameters
remote.add_interface("discovery-tree-blacklist",{
    blacklist_technology = function(technology_name) blacklist[technology_name] = true end,
    unblacklist_technology = function(technology_name) blacklist[technology_name] = nil end,
})


local function check_techs(force)
    local mode = settings.global["discovery-tree-mode"].value
    local do_essential = settings.global["discovery-tree-require-essential"].value

    local evaluated = evaluate_state(force)

    for id, t in pairs(force.technologies) do
        if t.valid and t.prototype.enabled then
            evaluated[id] = evaluated[id] or { pre = 0, dst = 10, ess = false }
            local required = 0
            for _, _ in pairs(t.prerequisites) do
                required = required + 1
            end
            t.enabled = blacklist[t] or
                should_show(required, evaluated[id].pre, evaluated[id].dst, evaluated[id].ess, mode, do_essential)
        end
    end
end


--------- Renai interface

---Remove whatever custom trajectory may be tied to this inserter.
---Do not throw error if it doesn't even have a custom trajectory tied to it.
---@param inserter_unit_number uint
local function clear_custom_trajectory(inserter_unit_number)
    if not inserter_unit_number then return end --Not valid
    storage.trajectories = storage.trajectories or {}
    storage.trajectories[inserter_unit_number] = nil;
end

--Define an interface to allow other mods to request a particular yeet trajectory.
remote.add_interface("renai-transportaton", {
    ---Request a custom trajectory
    request_trajectory = function(inserter, initial_yeet_vector)
        if not inserter.valid then return end

        --Reject request unless we are actually talking about a thrower
        local inserter_type = inserter.type;
        if inserter.type == "entity-ghost" then inserter_type = inserter.ghost_type end
        --TODO: You need a method or dictionary or something to discern what is or is not a thrower.
        --You probably already have this
        if IS_NOT_A_THROWER(inserter_type) then return end 

        local new_path = 0 --TODO: Whatever Renai calculates goes here to 
        -- calculate a brand new path that this inserter will use.

        ---@type table<uint, RENAI_PATH_OBJECT>
        storage.trajectories = storage.trajectories or {}
        storage.trajectories[inserter.unit_number] = new_path;
        script.register_on_object_destroyed(inserter)
    end,

    ---Tell Renai to no longer consider this inserter's unique trajectory, if it has one defined.
    unrequest_trajectory = function(inserter_unit_id)
        clear_custom_trajectory(inserter_unit_id) end,
})

script.on_event(defines.events.on_object_destroyed,
    function(event) clear_custom_trajectory(event.registration_number) end)

--Initializing the storage, add to whatever you do for on_init or on_config_changed 
script.on_init(function() storage.trajectories = storage.trajectories or {} end)
script.on_configuration_changed(function() storage.trajectories = storage.trajectories or {} end)


------ Planet hoppers
