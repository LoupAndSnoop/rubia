--The problem with the distant-misfires mod is that the hit collision masks of the projectiles it makes cannot collide with trashsteroids.
--Ownlys tracers has the exact same issue.
if not mods["distant-misfires"] and not mods["ownlys_tracers"] then return end

--Return true if the given projectile prototype name corresponds to a 
--bullet=>projectile that needs to be given proper collision
local function is_modified_projectile(name)
    --Distant misfires makes a projectile of the same name as the ammo.
    if data.raw["ammo"][name] then return true end
    
    --Ownly's tracers makes tracer projectiles with a unique naming:
    if string.find(name, "visual-tracer-projectile",1,true) then return true end

    return false
end

--DataCpt's code is very illegible. I'm going to iterate over all projectiles, and hope I get them all -.-
for _, entry in pairs(data.raw["projectile"]) do
    if is_modified_projectile(entry.name)
        and entry.hit_collision_mask
        and entry.hit_collision_mask.layers then --And it had a hit collision mask then
        entry.hit_collision_mask.layers.trashsteroid = true
    end
end