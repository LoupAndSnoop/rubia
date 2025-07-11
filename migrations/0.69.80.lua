if not storage.rubia_surface then return end


--Bring everyone's biochamber productivity bonus to the normal amount.
for _, force in pairs(game.forces) do
    local tech = force.technologies["rubia-biochamber-productivity-bonus"]
    if tech.researched or tech.level > 5 then tech.level = 10
    else tech.level = math.max(tech.level, 
        math.min(math.max(1, tech.level * 2 - 1), 10)) end
end