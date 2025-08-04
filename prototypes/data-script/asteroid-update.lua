--This file focueses on rebalancing the HP/resistances of asteroids
--so that sniper turrets cannot harm them

local HEALTH_MULTIPLIER = 10

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
    and delivery.target_effects.damage
    and delivery.target_effects.damage.amount then
        delivery.target_effects.damage.amount =
        delivery.target_effects.damage.amount * HEALTH_MULTIPLIER
    end
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
    prototype.max_health = (prototype.max_health or 5000) * HEALTH_MULTIPLIER
    --Also the flat resistance
    for _, entry in pairs(prototype.resistances or {}) do
        if entry.type == "physical" and entry.decrease
            and entry.decrease > 500 then
            entry.decrease = entry.decrease * HEALTH_MULTIPLIER
            break
        end
    end
end

for _, prototype in pairs(data.raw.asteroid or {}) do
    try_scale_asteroid_health(prototype)
end