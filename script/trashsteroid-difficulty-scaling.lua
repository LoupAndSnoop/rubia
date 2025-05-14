--This file controls the difficulty scaling of trashsteroids

local difficulty_scaling = {}

--Estimate the damage potential of a gun-turret with yellow ammo, as a ratio
--of the base damage. 1 = normal damage with no bells and whistles.
local function damage_multiplier()
    local force = game.forces["player"]
    assert(force, "Did not find player force!")
    return (1 + force.get_gun_speed_modifier("bullet"))
        * (1 + force.get_ammo_damage_modifier("bullet"))
        * (1 + force.get_turret_attack_modifier("gun-turret"))
end

--Notes on typical values of dmg multipliers:
--start of the game = 1
--Phys4, shooting4 (needs only blue+mil sci)=  4.608
--Phys5, shooting5 (needs only blue+mil sci)=  6.804
--Phys6, shooting6 (needs yellow sci) = 19.6
--Phys18, shooting6 (postgame) = 44.1

local shield_prototypes = {}
local function find_all_shield_prototypes()
    shield_prototypes = {}
    for _, entry in pairs(prototypes.equipment) do
        if string.sub(entry.name,1,string.len("trashsteroid-shield-")) == "trashsteroid-shield-" then
            table.insert(shield_prototypes, {name = entry.name, shield = entry.get_shield()})
        end
    end

    --Sort for fast access by shield value
    local function sorter(entry1, entry2) return entry1.shield < entry2.shield end
    table.sort(shield_prototypes, sorter)
end


difficulty_scaling.initialize = function()
    find_all_shield_prototypes()
end

--Cached values for how trashsteroids should be shielded.
local shielding_amount = 0
local current_shield_prototype = "trashsteroid-shield-1"
--Note: Since I clear checked the mod with the absolute shittiest techs,
--I know this is reasonable with maxed out difficulty settings.
local DIFFICULTY_EXPONENT = 0.69 + 0.02 --Bigger exponent = techs give less benefit
assert(0 < DIFFICULTY_EXPONENT and DIFFICULTY_EXPONENT < 1, "Difficulty scaling is out of bounds")
--Call to update caches for difficulty scaling.
difficulty_scaling.update_difficulty_scaling = function ()
    local base_HP = prototypes.entity["medium-trashsteroid"].get_max_health()
    --Multiply HP to scale up with damage multiplier. It should ALWAYS be between 1 and the damage multplier
    local damage_multiplier = damage_multiplier()
    local health_multiplier = damage_multiplier ^ DIFFICULTY_EXPONENT
    health_multiplier = math.max(1,math.min(health_multiplier, damage_multiplier))
    
    --Now convert that into an amount to shield.
    shielding_amount = base_HP * (health_multiplier - 1)
    shielding_amount = math.max(0, shielding_amount)
    
    --Find the right shield
    if not shield_prototypes then find_all_shield_prototypes() end
    for _, entry in ipairs(shield_prototypes) do
        if entry.shield <= shielding_amount then
            current_shield_prototype = entry.name
        end
    end
end


--Fetch the amount we expect to shield, and the relevant shield prototype
difficulty_scaling.get_current_shield = function()
    return shielding_amount, current_shield_prototype
end

--/c __rubia__ rubia.testing.show_difficulty_scaling ()
rubia.testing = rubia.testing or {}
rubia.testing.show_difficulty_scaling = function() 
    game.print("Current damage multiplier = " .. tostring(damage_multiplier())
        .. ". Curent shielding amount = " .. tostring(shielding_amount))
end

return difficulty_scaling