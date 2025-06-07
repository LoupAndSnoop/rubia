--The problem with the distant-misfires mod is that the hit collision masks of the projectiles it makes cannot collide with trashsteroids.
if not mods["distant-misfires"] then return end

--DataCpt's code is very illegible. I'm going to iterate over all projectiles, and hope I get them all -.-
for _, entry in pairs(data.raw["projectile"]) do
    if data.raw["ammo"][entry.name] --There is an ammo of the same name
        and entry.hit_collision_mask
        and entry.hit_collision_mask.layers then --And it had a hit collision mask then
        entry.hit_collision_mask.layers.trashsteroid = true
    end
end