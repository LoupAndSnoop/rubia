--Changed color of windturbines on map. Must rechart.
if storage.rubia_surface then
    for _, force in pairs(game.forces) do
        force.rechart(storage.rubia_surface)
    end
end