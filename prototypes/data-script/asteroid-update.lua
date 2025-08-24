--This file focueses on rebalancing the HP/resistances of asteroids
--so that sniper turrets cannot harm them.
--Current iteration makes a whole new damage type for it.


--Make a new railgun ammo type
data:extend({
    {
        type = "damage-type",
        name = "rubia-kinetic",
        order = "a-b",
    }
})

--[[ --order strings don't work to damage types
--Order it right after, but vanilla doesn't even give it an order!
local phys_type = data.raw["damage-type"]["physical"]
if phys_type then
    local kinetic_type = data.raw["damage-type"]["rubia-kinetic"]
    if phys_type.order then phys_type.order = "a-a"
    else kinetic_type.order = (phys_type.order or "a") .. "-b"
    end
end]]

--local HEALTH_MULTIPLIER = 10
--Scale the damage of each relevant ammunition
local function try_scale_ammo_damage(ammo_prototype)
    local delivery
    if ammo_prototype.ammo_category == "railgun"
        and ammo_prototype.ammo_type
        and ammo_prototype.ammo_type.action
        and ammo_prototype.ammo_type.action.action_delivery then
        delivery = ammo_prototype.ammo_type.action.action_delivery
    else return
    end

    if delivery.target_effects
    and delivery.target_effects.type == "damage"
    and delivery.target_effects.damage then
        delivery.target_effects.damage.type = "rubia-kinetic"
    end
    --This version changes the damage of the ammo, while keeping it physical
    --[[and delivery.target_effects.damage.amount then
        delivery.target_effects.damage.amount =
        delivery.target_effects.damage.amount * HEALTH_MULTIPLIER
    end]]
end

for _, prototype in pairs(data.raw.ammo) do
    try_scale_ammo_damage(prototype)
end

--Try to scale the HP and resistance of huge asteroids.
local function try_scale_asteroid_health(prototype)
    --Skip invalid asteroids
    if not (prototype.type == "asteroid"
        and string.find(prototype.name, "huge", 1, true)) then return end

    --Is a valid asteroid
    --prototype.max_health = (prototype.max_health or 5000) * HEALTH_MULTIPLIER
    --Also the resistance
    local has_railgun_res = false
    local proposed_kinetic_res = {type = "rubia-kinetic", decrease = 3000, percent = 10}
    for _, entry in pairs(prototype.resistances or {}) do
        if entry.type == "physical" and entry.decrease and entry.decrease > 500 then
            entry.percent = 100
            entry.decrease = nil--entry.decrease * HEALTH_MULTIPLIER
        elseif entry.type == "rubia-kinetic" then --Has impact res => change it
            entry.percent = proposed_kinetic_res.percent
            entry.decrease = proposed_kinetic_res.decrease
            has_railgun_res = true
        end
    end
    if not has_railgun_res then --Doesn't already have impact res => give it
        table.insert(prototype.resistances, proposed_kinetic_res)
    end
end

for _, prototype in pairs(data.raw.asteroid or {}) do
    try_scale_asteroid_health(prototype)
end

-----------

--Now add kinetic type resistance to everything to match the physical resistance
local function add_matched_kinetic_resistance(prototype)
    if not prototype.resistances then return end

    --Just in case someone chose to do something cheeky (or the above asteroid logic),
    --don't double add the resistance.
    for _, entry in pairs(prototype.resistances or {}) do
        if entry.type == "rubia-kinetic" then return end
    end

    for _, entry in pairs(prototype.resistances or {}) do
        if entry.type == "physical" and (entry.decrease or entry.percent) then
            --Omit adding resistance if it would get OHKO'd anyway. => low max HP.
            if not (entry.percent and entry.percent < 89) --Do transfer immunities or massive resistances
                or (prototype.max_health and (prototype.max_health < 1001)) then return end

            --Small flat/% resistances => 0
            local decrease = entry.decrease or 0
            if decrease < 100 then decrease = 0 end 
            local percent = entry.percent or 0
            if percent < 15 then percent = 0 end

            --Transfer only if it actually has some resistance to impart.
            if (percent > 0.001) or (decrease > 0.001) then
                table.insert(prototype.resistances, {
                    type = "rubia-kinetic",
                    decrease = decrease,
                    percent = percent
                })
            end
            return
        end
    end
end

for subtype in pairs(defines.prototypes['entity']) do
    --if subtype ~= "asteroid" then
    for _, proto in pairs(data.raw[subtype] or {}) do
        add_matched_kinetic_resistance(proto)
    end
    --end
end