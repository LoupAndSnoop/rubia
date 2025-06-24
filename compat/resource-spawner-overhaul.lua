
if not mods["rso-mod"] then return end
--Resource spawner overhaul kills my spawners. Blacklist it!

data.rso_ignore_resource_entities = data.rso_ignore_resource_entities or {}
data.rso_ignore_resource_entities["rubia-bacterial-sludge"] = true
data.rso_ignore_resource_entities["rubia-cupric-scrap"] = true
data.rso_ignore_resource_entities["rubia-ferric-scrap"] = true
data.rso_ignore_planets = data.rso_ignore_planets or {}
data.rso_ignore_planets['rubia'] = true