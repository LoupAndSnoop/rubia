--Need to migrate the asteroid density surface condition 
for _, surface in pairs(game.surfaces) do
    if surface.platform 
    and not surface.planet --Some planets are platforms
    and surface.get_property("rubia-asteroid-density") then --It was never given an asteroid density
        surface.set_property("rubia-asteroid-density", 50)
        log("(RUBIA) Migrating asteroid density surface property for: " .. surface.name)
    end
end