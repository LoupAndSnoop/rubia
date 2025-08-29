--Validate: If surface conditions have been removed, then we need
--to be managing the crapapult differently.

---Detection
local entities_to_lock = {"rubia-biorecycling-plant", "rubia-wind-turbine"}
local entities_to_ban = {"requester-chest", "locomotive"}
local recipes_to_lock = {"rubia-biofusion-science-pack", "biorecycling-science-pack",
    "yeet-makeshift-biorecycling-science-pack"}
local recipes_to_ban = {"yeet-(tool)-makeshift-biorecycling-science-pack"}

--This is a wind speed that falls right in between rubia banning and locking.
local INTERMEDIATE_WIND_SPEED = 200

--Return TRUE if we detected surface conditions being removed.
--banned = true means this entity is supposed to be banned from Rubia. False = it is supposed to be locked to Rubia
local function check_conditions(prototype, banned)
    if not prototype then return false end
    if not prototype.surface_conditions then return true end --It was supposed to have surface conditions, but they were removed!

    local check
    if banned then check = function(entry) return entry.max and entry.max < INTERMEDIATE_WIND_SPEED end
    else check = function(entry) return entry.min and entry.min > INTERMEDIATE_WIND_SPEED end
    end

    for _, entry in pairs(prototype.surface_conditions or {}) do
        if entry.property == "rubia-wind-speed" and check(entry) then return false
        end
    end
    log("Rubia found violation of surface conditions for: " .. prototype.name)
    return true
end

--Return TRUE if surface conditions have been removed.
local function are_surface_conditions_removed()
    for _, entry in pairs(entities_to_ban) do
        if check_conditions(prototypes.entity[entry], true) then return true end
    end
    for _, entry in pairs(entities_to_lock) do
        if check_conditions(prototypes.entity[entry], false) then return true end
    end
    for _, entry in pairs(recipes_to_ban) do
        if check_conditions(prototypes.recipe[entry], true) then return true end
    end
    for _, entry in pairs(recipes_to_lock) do
        if check_conditions(prototypes.recipe[entry], false) then return true end
    end

    --Now check Rubia
    local rubia_cond = prototypes.space_location["rubia"].surface_properties
    if not rubia_cond or not rubia_cond["rubia-wind-speed"] 
        or rubia_cond["rubia-wind-speed"] < INTERMEDIATE_WIND_SPEED then
        return true
    end

    return false
end
local surface_conditions_were_removed = are_surface_conditions_removed()

-----Enforcement

--Block biofusion.
local function block_biofusion()
    if not surface_conditions_were_removed then return end

    for _, name in pairs(rubia.BIOFUSION_LINE.recipe) do
        local recipe = prototypes.recipe[name]
        if recipe then
            for _, force in pairs(game.forces) do
                force.recipes[name].enabled = false
            end
        end
    end
end


--If someone turns on such a mod, then undoes it, bring it back
local function recheck_biofusion()
    if surface_conditions_were_removed then return end

    for _, force in pairs(game.forces) do
        local technologies = force.technologies
        for _, name in pairs(rubia.BIOFUSION_LINE.technology) do
            local tech = technologies[name] and technologies[name].prototype or nil
            if tech then 
                for _, effect in pairs(tech.effects) do
                    if effect.type == "unlock-recipe" and force.recipes[effect.recipe] then
                        force.recipes[effect.recipe].enabled = technologies[name].researched
                    end
                end
            end
        end
    end
end

--------------------

--Crapapult also needs to be disabled on foreign surfaces outright if 
--the special yeet recipes had surface restrictions removed.
--This basically allows the trigger techs to be done outside Rubia.

local special_yeet_recipes = prototypes.mod_data["rubia-crapapult-recipes-trigger"].data.names --[[@as table<string, boolean>]]

--Consistency check
local critical_recipe_names = {"yeet-makeshift-biorecycling-science-pack",
    "yeet-ghetto-biorecycling-science-pack", "yeet-biorecycling-science-pack"}
for _, name in pairs(critical_recipe_names) do
    assert(special_yeet_recipes[name], "A mod destroyed critical mod data required for Rubia to function.")
end
assert(table_size(special_yeet_recipes) > 4, "A mod destroyed critical mod data required for Rubia to function.")

local trigger_recipe_conditions_unlocked = false
for recipe_name in pairs(special_yeet_recipes) do
    if check_conditions(prototypes.recipe[recipe_name], false) then
        trigger_recipe_conditions_unlocked = true
        break
    end
end
local function disable_foreign_crapapult(entity)
    if not entity or not entity.valid then return end
    if entity.surface.name == "rubia" then return end

    local true_prototype = entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
    if true_prototype.name == "crapapult" then
        entity.active = false --Foreign crapapult
    end
end

------------

---Event subscriptions (do actual logic
local event_lib = require("__rubia__.lib.event-lib")
--if surface_conditions_were_removed then
--    event_lib.on_nth_tick(60, "biofusion-allowance-check", block_biofusion)
--end
event_lib.on_configuration_changed("biofusion-unblock-check", recheck_biofusion)

if trigger_recipe_conditions_unlocked then 
    event_lib.on_built("disable-foreign-crapapults", disable_foreign_crapapult)
end