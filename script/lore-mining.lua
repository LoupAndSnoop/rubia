--This script provides rubia lore when a specific number of entities is mined.
local lore_mining = {}
local lore_color = {r=0.2,g=0.9,b=0.9,a=1} --Color of lore text

--"Drop table" for lore, detailing the entity, the count, and which piece of lore to read
local lore_drop_table ={
    ["rubia-spidertron-remnants"] = {
        {count = 2, string = "rubia-lore.spidertron-mine-part1"},
        {count = 4, string = "rubia-lore.spidertron-mine-part2"},
        {count = 6, string = "rubia-lore.spidertron-mine-part3"},
        {count = 8, string = "rubia-lore.spidertron-mine-part4"},
    },
    ["rubia-pole-remnants"] = {
        {count = 7, string = "rubia-lore.train-stop-mine-part1"},
        {count = 14, string = "rubia-lore.train-stop-mine-part2"},

    },
    ["rubia-junk-pile"] = {
        {count = 3, string = "rubia-lore.junk-mine-part1"},
    }
}

--When we just got a lore drop, check if we need an achievement for it
local try_lore_achievement = function()
    for entity_name, drop_table in pairs(lore_drop_table) do
        for _, entry in pairs(drop_table) do
            --Haven't even mined one => NO
            if (not storage.rubia_mined_lore_entities[entity_name]) then return end
            --There is one lore drop we haven't seen in that category
            log(serpent.block(entry) .. " - " .. entity_name .. " - " .. serpent.block(storage.rubia_mined_lore_entities))
            if (entry.count > storage.rubia_mined_lore_entities[entity_name]) then return end
        end
    end

    --We made it past all the lore checks. Give achievement.
    game.print("TODO: Give lore achievement")
end


--When an entity is mined, try to go get the lore for it.
lore_mining.try_lore_when_mined = function(entity)
    local prototype_name = entity.prototype.name
    if not lore_drop_table[prototype_name] then return end --not on drop table

    --Running count of everything we mined
    storage.rubia_mined_lore_entities = storage.rubia_mined_lore_entities or {}
    local new_count = (storage.rubia_mined_lore_entities[prototype_name] or 0)+1
    storage.rubia_mined_lore_entities[prototype_name] = new_count
    --Check to give lore
    for _, entry in pairs(lore_drop_table[prototype_name]) do
        if new_count == entry.count then
            game.print({"", {"rubia-lore.rubia-notice-prestring"}, ": ", {entry.string}},{color=lore_color})
            try_lore_achievement()
            return
        end
    end
end

return lore_mining