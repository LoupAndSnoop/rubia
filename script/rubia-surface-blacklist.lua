_G.rubia = _G.rubia or {}

-------Surface blacklist = list of things to ban from rubia's surface.
--Array of entity prototypes to ban from only rubia's surface.
--Input {type="type",name="entity-name"}, such that data.raw["type"]["entity-name"] gives the prototype. This is global, so other mods can add entries
--to this array before we do our thing. This array can also just be defined and populated
--at some other stage.
rubia.surface_blacklist = rubia.surface_blacklist or {}
local internal_blacklist = {
    {type="logistic-container", name="requester-chest"},
    {type="logistic-container", name="buffer-chest"},
    {type="logistic-container", name="active-provider-chest"},
    {type="furnace", name="recycler"},

    {type="locomotive", name ="locomotive"},
    {type="cargo-wagon", name ="cargo-wagon"},
    {type="fluid-wagon", name ="fluid-wagon"},
    {type="artillery-wagon", name ="artillery-wagon"},

    --Logistic cheese
    {type="car", name ="tank"},
}
--Specific mods blacklisting
local mod_item_blacklist = {
    {mod="SpidertronPatrols", type="proxy-container", name ="sp-spidertron-dock"},
    {mod="RenaiTransportation", type="constant-combinator", name ="DirectorBouncePlate"},
    {mod="RenaiTransportation", type="electric-energy-interface", name ="RTDivergingChute"},

}
for _, entry in pairs(mod_item_blacklist) do
    if mods[entry.mod] then table.insert(internal_blacklist, entry) end
end


--This is a list of all entities that are going to be in a blacklisted prototype type,
--but I want to keep them in the list.
local internal_whitelist = {
    {type="locomotive", name ="rubia-armored-locomotive"},
    {type="cargo-wagon", name ="rubia-armored-cargo-wagon"},
    {type="fluid-wagon", name ="rubia-armored-fluid-wagon"},
    {type="logistic-container", name="passive-provider-chest"},
    {type="logistic-container", name="storage-chest"},
}
--internal_whitelist = rubia_lib.array_to_dictionary(internal_whitelist,"type")

--All entities in these prototype type will be blacklisted automatically, unless explicitly whitelisted.
--This accounts for mods adding variants in these prototypes.
local prototype_type_blacklist = {"logistic-container",
    "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon"
}
--prototype_type_blacklist = rubia_lib.array_to_hashset(prototype_type_blacklist)

--Add entities in the prototype blacklist (not in the whitelist) to the growing blacklist.
for _, type in pairs(prototype_type_blacklist) do
    for _,entry in pairs(data.raw[type]) do
        if not rubia_lib.array_find_condition(internal_whitelist,function(value)
            return (value.type==type) and (value.name==entry.name) end) then
            table.insert(internal_blacklist, {type=entry.type,name=entry.name})
        end
    end
end


--I need to ban all possible modded recyclers
for _, type_to_check in pairs({"furnace", "assembling-machine","rocket-silo"}) do
    for _, prototype in pairs(data.raw[type_to_check]) do
        if prototype.crafting_categories and rubia_lib.array_find(prototype.crafting_categories, "recycling") then
            table.insert(internal_blacklist, {type = "furnace", name= prototype.name})
        end
    end
end


--Merge with any existing blacklist in case other mods want to add to this blacklist variable.
rubia.surface_blacklist = rubia_lib.array_concat({rubia.surface_blacklist, internal_blacklist})

--Apply Blacklist to make a dictionary
--Change from an array of {type, name} to a dictionary of {type, {name1, name2}}
-- for all in that category
local dictionary_blacklist = {}
for _, entry in pairs(rubia.surface_blacklist) do
    if not dictionary_blacklist[entry.type] then dictionary_blacklist[entry.type] = {entry.name}
    --Only add if not double ban
    elseif not rubia_lib.array_find(dictionary_blacklist[entry.type], entry.name) then 
        table.insert(dictionary_blacklist[entry.type], entry.name)
    end
end

--Now go through all the blacklist
for category, sub_blacklist in pairs(dictionary_blacklist) do
    for _, prototype in pairs(data.raw[category]) do
        if rubia_lib.array_find(sub_blacklist, prototype.name) then
            rubia.ban_from_rubia(prototype)
        end
    end
end