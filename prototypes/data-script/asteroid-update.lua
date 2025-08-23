--This file focueses on rebalancing the HP/resistances of asteroids
--so that sniper turrets cannot harm them.
--Current iteration makes a whole new damage type for it.


--Make a new railgun ammo type
data:extend({
    {
        type = "damage-type",
        name = "rubia-railgun",
        order = "r-r",
    }
})

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
        delivery.target_effects.damage.type = "rubia-railgun"
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
    local proposed_railgun_res = {type = "rubia-railgun", decrease = 3000, percent = 10}
    for _, entry in pairs(prototype.resistances or {}) do
        if entry.type == "physical" and entry.decrease and entry.decrease > 500 then
            entry.percent = 100
            entry.decrease = nil--entry.decrease * HEALTH_MULTIPLIER
        elseif entry.type == "rubia-railgun" then --Has impact res => change it
            entry.percent = proposed_railgun_res.percent
            entry.decrease = proposed_railgun_res.decrease
            has_railgun_res = true
        end
    end
    if not has_railgun_res then --Doesn't already have impact res => give it
        table.insert(prototype.resistances, proposed_railgun_res)
    end
end

for _, prototype in pairs(data.raw.asteroid or {}) do
    try_scale_asteroid_health(prototype)
end