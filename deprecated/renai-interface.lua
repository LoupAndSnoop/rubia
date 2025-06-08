
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
        if not IS_A_THROWER(inserter_type) then return end 

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



-----Data-final fixes------

--Make sure all throwers make unit numbers
local UNIT_FLAG = "get-by-unit-number"
for _, prototype in pairs(data.raw["inserter"]) do
    if IS_A_THROWER(prototype.name) then
        if not prototype.flags or table_size(prototype.flags) == 0 then
            prototype.flags = {UNIT_FLAG}
        else --Ensure we don't double add a flag.
            local needs_unit_number_flag = true
            for _, flag in pairs(prototype.flags or {}) do
                if flag == "get-by-unit-number" then
                    needs_unit_number_flag = false
                    break
                end
            end
            if needs_unit_number_flag then
                table.insert(prototype.flags, UNIT_FLAG)
            end
        end
    end
end
