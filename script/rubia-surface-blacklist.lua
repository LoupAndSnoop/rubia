_G.rubia = _G.rubia or {}

-------Surface blacklist = list of things to ban from rubia's surface.
--Array of entity prototypes to ban from only rubia's surface.
--Input {type="type",name="entity-name"}, such that data.raw["type"]["entity-name"] gives the prototype. This is global, so other mods can add entries
--to this array before we do our thing. This array can also just be defined and populated
--at some other stage.
rubia.surface_blacklist = rubia.surface_blacklist or {}
local internal_blacklist = {
    {type="logistic-container", name="requester-chest"},
    {type="logistic-container", name="storage-chest"},
    {type="logistic-container", name="active-provider-chest"},
    {type="furnace", name="recycler"},

    {type="locomotive", name ="locomotive"},
    {type="cargo-wagon", name ="cargo-wagon"},
    {type="fluid-wagon", name ="fluid-wagon"},
}

--Merge with any existing blacklist in case other mods want to add to this blacklist variable.
rubia.surface_blacklist = rubia_lib.array_concat({rubia.surface_blacklist, internal_blacklist})

--Apply Blacklist.
--Change from an array of {type, name} to a dictionary of {type, {name1, name2}}
-- for all in that category
local dictionary_blacklist = {}
for _, entry in pairs(rubia.surface_blacklist) do
    if not dictionary_blacklist[entry.type] then dictionary_blacklist[entry.type] = {entry.name}
    else table.insert(dictionary_blacklist[entry.type], entry.name) end
end

--Now go through all the blacklist
for category, sub_blacklist in pairs(dictionary_blacklist) do
    for _, prototype in pairs(data.raw[category]) do
        if rubia_lib.array_find(sub_blacklist, prototype.name) then
            rubia.ban_from_rubia(prototype)
        end
    end
end