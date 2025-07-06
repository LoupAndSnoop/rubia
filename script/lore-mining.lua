--This script provides rubia lore when a specific number of entities is mined.
local lore_mining = {}
local lore_color = {r=0.2,g=0.9,b=0.9,a=1} --Color of lore text

--#region Custom executables on mining
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

---Create and use a capsule spawned at entity, by the name capsule_name, 
---targetting a position at entity_position + shift. Does not check entity validity.
local function throw_capsules(entity, capsule_name, shift_array)
    local capsules = (entity.surface.spill_item_stack{
            position = entity.position,
            stack = {name=capsule_name, count=#shift_array},
        })
    for i, shift in pairs(shift_array) do
        local target = {entity.position.x + shift[1], entity.position.y + shift[2]}
        local projectiles = capsules[i].stack.use_capsule(entity, target)
        --for _, proj in pairs(projectiles) do proj.speed = proj.speed * 0.05 end --Slow to see.
    end
    for _, entry in pairs(capsules) do entry.destroy() end
end

---Create a projectile spawned at entity, by the name projectile_name, 
---targetting a position at entity_position + shift for each shift in the array.
---Does not check entity validity.
local function throw_projectiles(entity, projectile_name, shift_array)
    for i, shift in pairs(shift_array) do
        local target = {entity.position.x + shift[1], entity.position.y + shift[2]}
        entity.surface.create_entity({
            name = projectile_name,
            position = entity.position,
            target = target,
            direction = entity.orientation,
            create_build_effect_smoke = false,
        })
    end
end

local function grenade_trap(entity)
    if not (entity and entity.valid
        and entity.surface and entity.surface.name == "rubia") then return end

    local position_shifts = {{3,3}, {1,-5}, {-2,0}, {0,4}, {-4,-3}, {0,2}, {-4,3}, {3,-4}}
    throw_projectiles(entity, "rubia-cluster-grenade-trap", position_shifts)
    --throw_capsules(entity, "rubia-grenade-trap", position_shifts) 

    --SFX
    for i = 1, 6, 1 do entity.surface.play_sound{path="rubia-grenade-throw"} end
end

local function destroyer_trap(entity)
    if not (entity and entity.valid
        and entity.surface and entity.surface.name == "rubia") then return end

    local position_shifts = {{2,2}, {-2,1}, {0,3}, {-3,-1.5}, {0,2}}
    throw_projectiles(entity, "rubia-destroyer-capsule-trap", position_shifts)

    --SFX
    for i = 1, 4, 1 do entity.surface.play_sound{path="rubia-grenade-throw"} end
end


--#endregion

--"Drop table" for lore, detailing the entity, the count, and which piece of lore to read
--execute = function to execute when this entity is mined.
local lore_drop_table ={
    ["rubia-spidertron-remnants"] = {
        {count = 1, string = "rubia-lore.spidertron-mine-hint-part1",
                    string2 = "rubia-lore.spidertron-mine-hint-part2", string2_delay = 30*60},
        {count = 5, string = "rubia-lore.spidertron-mine-part1"},
        {count = 18, string = "rubia-lore.spidertron-mine-part2"},
        {count = 35, string = "rubia-lore.spidertron-mine-part3"},
        {count = 50, execute = spoilage_failsafe, extra_id = "spoil1"},
        {count = 52, string = "rubia-lore.spidertron-mine-destroyer-trap", execute = destroyer_trap,
                     string2 = "rubia-lore.spidertron-mine-destroyer-trap-2", string2_delay = 60 * 20},
        {count = 60, execute = spoilage_failsafe, extra_id = "spoil2"}, --Extra failsafes for redundancy
        {count = 70, execute = spoilage_failsafe, extra_id = "spoil3"},
        {count = 73, string = "rubia-lore.spidertron-mine-part4"},
        {count = 75, execute = spoilage_failsafe, extra_id = "spoil4"},
    },
    ["rubia-pole-remnants"] = {
        {count = 12, string = "rubia-lore.train-stop-mine-part1"},
        {count = 34, string = "rubia-lore.train-stop-mine-part2"},
        {count = 67, string = "rubia-lore.train-stop-mine-part3"},
        {count = 112, string = "rubia-lore.train-stop-mine-part4"},
        {count = 157, string = "rubia-lore.train-stop-mine-part5",
                     string2 = "rubia-lore.train-stop-mine-part5-2", string2_delay = 5*60},
        {count = 183, string = "rubia-lore.train-stop-mine-part6",
                     string2 = "rubia-lore.train-stop-mine-part6-2", string2_delay = 78*3600},
    },
    ["rubia-junk-pile"] = {
        --{count = 1, string = "rubia-lore.junk-mine-hint-part1"},
        {count = 5, string = "rubia-lore.junk-mine-part1"},
        {count = 17, string = "rubia-lore.junk-mine-part2"},
        {count = 31, string = "rubia-lore.junk-mine-part3"},
        {count = 52, string = "rubia-lore.junk-mine-grenade-trap", execute = grenade_trap,
                     string2 = "rubia-lore.junk-mine-grenade-trap-2", string2_delay = 80},
        {count = 77, string = "rubia-lore.junk-mine-part4-rand", random = 6,
                     extra_id = "rubia-lore.junk-mine-part4-rand"},
        {count = 105, string = "rubia-lore.junk-mine-part5"},
        {count = 130, string = "rubia-lore.junk-mine-part6-rand", random = 3,
                     extra_id = "rubia-lore.junk-mine-part6-rand"},
    }
}
--Give every entry a non-string ID in the lore table. This function gets invoked to give access for migrations.
function lore_mining.assign_ids_to_lore(lore_table)
    local id_duplicate_check = {}
    for key, list in pairs(lore_table) do
        for _, entry in pairs(list) do
            local id =  entry.extra_id or entry.string
            assert(id, "This entry has no identification to make sure we don't invoke multiple times: "
                    .. key .. ": " .. serpent.block(entry))
            assert(not id_duplicate_check[id], "This ID is duplicated, but should be unique: " .. tostring(id))
            assert(not entry.unique_id, "Unique id should be set automatically, not in the lore definition. See: " .. serpent.block(entry))
            id_duplicate_check[id] = true
            entry.unique_id = id
        end
    end
end
lore_mining.assign_ids_to_lore(lore_drop_table)



--Code for testing. Comment in/out as needed.
log("RUBIA: Lore test code is active. Remove before release.")
for _, entry in pairs(lore_drop_table) do
    for i, lore in pairs(entry) do
        lore.count = i
    end
end


--When we just got a lore drop, check if we need an achievement for it
local try_lore_achievement = function()
    for entity_name, drop_table in pairs(lore_drop_table or {}) do
        --Haven't even mined one => NO
        if (not storage.rubia_mined_lore_entities[entity_name]) then return end
        for _, entry in pairs(drop_table or {}) do
            --There is a lore drop we haven't seen in that category, with actual lore
            if (not storage.rubia_lore_previously_played[entry.unique_id])
                and entry.string then return end
        end
    end

    --We made it past all the lore checks. Give achievement.
    local achievement_id = "rubia-lore.all-lore-done"
    if storage.rubia_lore_previously_played[achievement_id] then return end --We already gave it
    storage.rubia_lore_previously_played[achievement_id] = true
    game.print({"rubia-lore.all-lore-done"})
    for _, player in pairs(game.players) do
        player.unlock_achievement("rubia-lore-complete")
    end
end


--When an entity is mined, try to go get the lore for it.
lore_mining.try_lore_when_mined = function(entity)
    if not entity or not entity.valid then return end
    local prototype_name = entity.prototype.name
    if not lore_drop_table[prototype_name] then return end --not on drop table

    ---@type table<string, uint> Running count of everything we mined
    storage.rubia_mined_lore_entities = storage.rubia_mined_lore_entities or {}
    ---@type table<string, boolean> Hashset of previously played lore lines.
    storage.rubia_lore_previously_played = storage.rubia_lore_previously_played or {}
    local new_count = (storage.rubia_mined_lore_entities[prototype_name] or 0)+1
    storage.rubia_mined_lore_entities[prototype_name] = new_count
    --Check to give lore
    for index, entry in pairs(lore_drop_table[prototype_name]) do
        if new_count >= entry.count  --Time to trigger
            and not storage.rubia_lore_previously_played[entry.unique_id] then --Not seen before
            storage.rubia_lore_previously_played[entry.unique_id] = true

            --Base string print
            if entry.string then
                local to_print = entry.string
                if entry.random then
                    to_print = to_print .. tostring(game.create_random_generator()(entry.random))
                end
                game.print({"", {"rubia-lore.rubia-notice-prestring"}, ": ", {to_print}},{color=lore_color})
            end

            --Non-basic print functions
            if entry.string2 then 
                rubia.timing_manager.wait_then_do(entry.string2_delay or (5*60), "delayed-text-print", {"game", 
                    {"", {"rubia-lore.rubia-notice-prestring"}, ": ", {entry.string2}}, {color=lore_color}})
            end
            if entry.execute then entry.execute(entity) end
            
            try_lore_achievement()
            table.remove(lore_drop_table, index) --Remove because we've seen it.
            return
        end
    end
end

--#region Event subscription
local event_lib = require("__rubia__.lib.event-lib")
event_lib.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity},
  "lore-mining", function(event)
  lore_mining.try_lore_when_mined(event.entity)
end)
--#endregion

return lore_mining