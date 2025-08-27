local blacklist_file = require("__rubia__.prototypes.data-script.rubia-surface-blacklist")
local dictionary_blacklist = blacklist_file.copy_blacklist()

--Now go through all the blacklist
---Dictionary of prototype type => Array of all strings of internal names of banned items
---@type table<string, string[]>
local banlist_for_string = {}
log("Banning these entities from Rubia: " .. serpent.block(dictionary_blacklist))
for category, sub_blacklist in pairs(dictionary_blacklist) do
    for _, prototype in pairs(data.raw[category]) do
        if prototype.name and rubia_lib.array_find(sub_blacklist, prototype.name) then
            rubia.ban_from_rubia(prototype)

            --Log for blacklist string, with order strings, if they exist.
            if not prototype.hidden_in_factoriopedia and not prototype.hidden then
                table.insert(banlist_for_string, {
                    order = rubia_lib.get_entity_order(prototype), name = prototype.name})
            end


        end
    end
end

--Sort by order strings
table.sort(banlist_for_string, function(entry1, entry2)
    return rubia_lib.compare_entity_order(entry1.order, entry2.order) end)
--log("RUBIA ORDERING_TEST"); log(serpent.block(banlist_for_string))
local banlist_strings = {"", {"tips-and-tricks-item-description.rubia-wind-tips"}}
local last = table_size(banlist_for_string)
for i, entry in pairs(banlist_for_string) do
    local string = "[entity=" .. entry.name .. "]"
    if i ~= last then string = string .. ", " end
    table.insert(banlist_strings, string)
end
data.raw["tips-and-tricks-item"]["rubia-wind-tips"].localised_description =
    rubia_lib.crunch_localised_string(banlist_strings)


--Send blacklist as mod-data
---Just a hashset of strings of the actual names of entities banned from Rubia
local blacklist_names = {}
for _, entry in pairs(rubia.surface_blacklist) do
    blacklist_names[entry.name] = true
end
data:extend({
    {
        type = "mod-data",
        name = "rubia-surface-blacklist",
        data_type = "rubia-surface-blacklist",
        data = blacklist_names,
    }
})


--[[
--Older version of localized string, where everything is sorted by prototype type, then by internal name.

--Log for blacklist string, categorized by category
--if banlist_for_string[category] then
--    table.insert(banlist_for_string[category], prototype.name)
--else banlist_for_string[category] = {prototype.name} end

--Let's add them to the wind mechanics tips and tricks, sorted first by prototype type, then
--alphabetically by internal names
local banlist_strings = {""}
for _, sub_blacklist in pairs(banlist_for_string) do
    table.sort(sub_blacklist)

    local sub_blacklist_strings = {""}
    for i, entry in pairs(sub_blacklist) do
        local string = "[entity=" .. entry .. "]"
        if i ~= table_size(sub_blacklist) then string = string .. ", " end
        table.insert(sub_blacklist_strings, string)

        if table_size(sub_blacklist_strings) > 17 then
            table.insert(banlist_strings, table.deepcopy(sub_blacklist_strings))
            sub_blacklist_strings = {""}
        end
    end
    --table.insert(sub_blacklist_strings, "\n")
    table.insert(banlist_strings, sub_blacklist_strings)
    if table_size(banlist_strings) > 17 then break end --We're going to overflow!
end

data.raw["tips-and-tricks-item"]["rubia-wind-tips"].localised_description =
    {"", {"tips-and-tricks-item-description.rubia-wind-tips"}, banlist_strings}
    ]]