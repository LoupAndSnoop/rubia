--Migrating from old lore values
if not storage.rubia_surface or not storage.rubia_mined_lore_entities then return end
--If we had this storage already, don't do anything
if storage.rubia_lore_previously_played then return end


--if rubia.flib.is_newer_version(script.active_mods["rubia"])
local lore_mining = require("__rubia__/script/lore-mining")

local old_lore_drop_table ={
    ["rubia-spidertron-remnants"] = {
        {count = 1, string = "rubia-lore.spidertron-mine-hint-part1",
                    string2 = "rubia-lore.spidertron-mine-hint-part2", string2_delay = 30*60},
        {count = 5, string = "rubia-lore.spidertron-mine-part1"},
        {count = 13, string = "rubia-lore.spidertron-mine-part2"},
        {count = 23, string = "rubia-lore.spidertron-mine-part3"},
        {count = 41, string = "rubia-lore.spidertron-mine-part4"},
        {count = 50, extra_id = "spoil1"},
        {count = 60, extra_id = "spoil2"},
        {count = 70, extra_id = "spoil3"},
    },
    ["rubia-pole-remnants"] = {
        {count = 3, string = "rubia-lore.train-stop-mine-part1"},
        {count = 12, string = "rubia-lore.train-stop-mine-part2"},
        {count = 23, string = "rubia-lore.train-stop-mine-part3"},
        {count = 32, string = "rubia-lore.train-stop-mine-part4"},
        {count = 47, string = "rubia-lore.train-stop-mine-part5",
                    string2 = "rubia-lore.train-stop-mine-part5-2", string2_delay = 5*60},
    },
    ["rubia-junk-pile"] = {
        --{count = 1, string = "rubia-lore.junk-mine-hint-part1"},
        {count = 5, string = "rubia-lore.junk-mine-part1"},
        {count = 12, string = "rubia-lore.junk-mine-part2"},
        {count = 21, string = "rubia-lore.junk-mine-part3"},
        {count = 31, extra_id = "rubia-lore.junk-mine-part4-rand"},
        {count = 39, string = "rubia-lore.junk-mine-part5"},
        {count = 54, extra_id = "rubia-lore.junk-mine-part6-rand"},
    }
}
lore_mining.assign_ids_to_lore(old_lore_drop_table)

--Add to the list that we had already seen that lore.
storage.rubia_lore_previously_played = {}
for entity_name, list in pairs(old_lore_drop_table) do
    for _, entry in pairs(list) do
        --We already saw this lore.
        if storage.rubia_mined_lore_entities[entity_name] and
            storage.rubia_mined_lore_entities[entity_name] >= entry.count then
            storage.rubia_lore_previously_played[entry.unique_id] = true
        end
    end
end