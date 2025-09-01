--Ownlys tracers makes bullet projectiles that cannot hit trashsteroids.
if not mods["ownlys_tracers"] then return end

--Ownley's tracers makes specially named tracer projectiles
for _, entry in pairs(data.raw["projectile"]) do
    if string.find(entry.name, "visual-tracer-projectile",1,true)
        and entry.hit_collision_mask
        and entry.hit_collision_mask.layers then --And it had a hit collision mask then
        entry.hit_collision_mask.layers.trashsteroid = true
    end
end