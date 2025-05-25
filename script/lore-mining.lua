--This script provides rubia lore when a specific number of entities is mined.
local lore_mining = {}
local lore_color = {r=0.2,g=0.9,b=0.9,a=1} --Color of lore text


--If we mined a lot of spidertron remnants, do this to ensure player gets what they need.
local function spoilage_failsafe(entity)
    if entity and entity.valid and entity.name == "rubia-spidertron-remnants"
        and entity.surface and entity.surface.name == "rubia" then
        entity.surface.spill_item_stack{
            position = entity.position, 
            stack = {name="spoilage", count=5},
            enable_looted =true,
            allow_belts = false,
            force = game.forces["player"],
        }
    end
end


--"Drop table" for lore, detailing the entity, the count, and which piece of lore to read
--execute = function to execute when this entity is mined.
local lore_drop_table ={
    ["rubia-spidertron-remnants"] = {
        {count = 1, string = "rubia-lore.spidertron-mine-hint-part1",
                    string2 = "rubia-lore.spidertron-mine-hint-part2", string2_delay = 30*60},
        {count = 5, string = "rubia-lore.spidertron-mine-part1"},
        {count = 13, string = "rubia-lore.spidertron-mine-part2"},
        {count = 23, string = "rubia-lore.spidertron-mine-part3"},
        {count = 41, string = "rubia-lore.spidertron-mine-part4"},
        {count = 50, execute = spoilage_failsafe},
        {count = 60, execute = spoilage_failsafe},
        {count = 70, execute = spoilage_failsafe},
    },
    ["rubia-pole-remnants"] = {
        {count = 3, string = "rubia-lore.train-stop-mine-part1"},
        {count = 12, string = "rubia-lore.train-stop-mine-part2"},
        {count = 23, string = "rubia-lore.train-stop-mine-part3"},
        {count = 32, string = "rubia-lore.train-stop-mine-part4"},
    },
    ["rubia-junk-pile"] = {
        --{count = 1, string = "rubia-lore.junk-mine-hint-part1"},
        {count = 5, string = "rubia-lore.junk-mine-part1"},
        {count = 12, string = "rubia-lore.junk-mine-part2"},
        {count = 21, string = "rubia-lore.junk-mine-part3"},
        {count = 31, string = "rubia-lore.junk-mine-part4-rand" .. tostring((storage.rubia_asteroid_rng and storage.rubia_asteroid_rng(6)) or 1)},
        {count = 39, string = "rubia-lore.junk-mine-part5"},
        {count = 54, string = "rubia-lore.junk-mine-part6-rand" .. tostring((storage.rubia_asteroid_rng and storage.rubia_asteroid_rng(4)) or 1)},
    }
}

--[[Code for testing. Comment in/out as needed.
log("Lore test code is active. Remove before release.")
for _, entry in pairs(lore_drop_table) do
    for i, lore in pairs(entry) do
        lore.count = i
    end
end]]


--When we just got a lore drop, check if we need an achievement for it
local try_lore_achievement = function()
    for entity_name, drop_table in pairs(lore_drop_table) do
        for _, entry in pairs(drop_table) do
            --Haven't even mined one => NO
            if (not storage.rubia_mined_lore_entities[entity_name]) then return end
            --There is one lore drop we haven't seen in that category
            if (entry.count > storage.rubia_mined_lore_entities[entity_name]) then return end
        end
    end

    --We made it past all the lore checks. Give achievement.
    game.print({"rubia-lore.all-lore-done"})
end


--When an entity is mined, try to go get the lore for it.
lore_mining.try_lore_when_mined = function(entity)
    if not entity or not entity.valid then return end
    local prototype_name = entity.prototype.name
    if not lore_drop_table[prototype_name] then return end --not on drop table

    --Running count of everything we mined
    storage.rubia_mined_lore_entities = storage.rubia_mined_lore_entities or {}
    local new_count = (storage.rubia_mined_lore_entities[prototype_name] or 0)+1
    storage.rubia_mined_lore_entities[prototype_name] = new_count
    --Check to give lore
    for _, entry in pairs(lore_drop_table[prototype_name]) do
        if new_count == entry.count then --Time to trigger
            if entry.string then 
                game.print({"", {"rubia-lore.rubia-notice-prestring"}, ": ", {entry.string}},{color=lore_color})
            end
            if entry.string2 then 
                rubia.timing_manager.wait_then_do(entry.string2_delay or (5*60), "delayed-text-print", {"game", 
                    {"", {"rubia-lore.rubia-notice-prestring"}, ": ", {entry.string2}}, {color=lore_color}})
            end
            if entry.execute then entry.execute(entity) end
            try_lore_achievement()
            return
        end
    end
end

return lore_mining