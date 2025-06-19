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
    --{type="car", name ="tank"},
}
--Specific mods blacklisting
local mod_item_blacklist = {
    {mod="SpidertronPatrols", type="proxy-container", name ="sp-spidertron-dock"},
    {mod="RenaiTransportation", type="constant-combinator", name ="DirectorBouncePlate"},
    {mod="RenaiTransportation", type="electric-energy-interface", name ="RTDivergingChute"},
    {mod="quantum-fabricator", type = "reactor", name = "dedigitizer-reactor"}, --Lets you teleport items in
    
    --Power
    {mod="Krastorio2-spaced-out", type = "electric-energy-interface", name = "kr-wind-turbine"},
}

--Miniloader-redux needs to have everything banned, because it keeps fighting back at control stage.
if mods["miniloader-redux"] then
    local function is_miniloader(name)
        local miniloader_prefix, miniloader_prefix_lane = "hps__ml-", "lane-hps__ml-"
        if string.sub(name,1,string.len(miniloader_prefix)) == miniloader_prefix then return true
        elseif string.sub(name,1,string.len(miniloader_prefix_lane)) == miniloader_prefix_lane then return true
        end
        return false
    end
    for _, type in pairs({"inserter","loader-1x1"}) do
        for name, _ in pairs(data.raw.inserter) do
            if is_miniloader(name) then 
                table.insert(mod_item_blacklist, {mod = "miniloader-redux", type = type, name = name})
            end
        end
    end
end

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

    --Modded items
    {type="cargo-wagon", name ="RTImpactWagon"},
}
--internal_whitelist = rubia_lib.array_to_dictionary(internal_whitelist,"type")

--All entities in these prototype type will be blacklisted automatically, unless explicitly whitelisted.
--This accounts for mods adding variants in these prototypes.
local prototype_type_blacklist = {--"logistic-container",
    "locomotive", "cargo-wagon", "fluid-wagon", "artillery-wagon",
    "linked-container", "linked-belt"
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
            table.insert(internal_blacklist, {type = type_to_check, name= prototype.name})
        end
    end
end


--Banning logistic containers EXCEPT storage and passive providers. If not defined, ban it
--[[local banned_modes = rubia_lib.array_to_hashset({ --Both string and enum forms
    "buffer", "active-provider", "requester",
    defines.logistic_mode.buffer, defines.logistic_mode.requester, defines.logistic_mode.active_provider})
]]
local allowed_modes = rubia_lib.array_to_hashset({ --Both string and enum forms
    "none", "passive-provider", "storage",
    defines.logistic_mode.none, defines.logistic_mode.passive_provider, defines.logistic_mode.storage})
for _, type_to_check in pairs({"logistic-container"}) do
    for _, prototype in pairs(data.raw[type_to_check] or {}) do
        --log("Checking: " .. prototype.name .. " - " .. tostring(prototype.logistic_mode))
        if not allowed_modes[prototype.logistic_mode or "blank"] then
            table.insert(internal_blacklist, {type = type_to_check, name= prototype.name})
        --else log("Not banning: " .. prototype.name .. " - " .. tostring(prototype.logistic_mode))--.. ": " .. serpent.block(prototype))
        end
    end
end

--#region Inserters
--I need to check for inserters that naturally violate my rules
--Differences less than this should be registered as zero for inserter position rounding
local MIN_INSERTER_LENGTH_THRESHOLD = 0.5

--Standardize the format of a vector to x/y
local function vector_to_xy(vector)
    if vector.x then return {x=vector.x, y=vector.y}
    else return {x=vector[1], y=vector[2]} end
end

---Return TRUE if the given inserter can be compatible with rubia.
---@param prototype data.InserterPrototype
---@return boolean
local function inserter_is_rubia_compatible(prototype)
    if prototype.allow_custom_vectors then return true end
    local pickup = vector_to_xy(prototype.pickup_position)
    local dropoff = vector_to_xy(prototype.insert_position)
    
    --Standardize
    --if not pickup.x then pickup = {pickup[1], pickup[2]} end
    --if not dropoff.x then dropoff = {dropoff[1], dropoff[2]} end

    local dot_product = pickup.x * dropoff.x + pickup.y * dropoff.y
    local pickup_length = math.sqrt(pickup.x ^2 + pickup.y ^2)
    local dropoff_length = math.sqrt(dropoff.x ^2 + dropoff.y ^2)

    --[[Reject any diagonal inserters. I have no reference, so if someone wants to complain,
    -- then I'll have to handle on a case-by-case basis
    if math.abs(pickup.x * pickup.y) > 0.5
        or math.abs(dropoff.x * dropoff.y) > 0.5 then return false end]]

    --If either vector is individually very small, then it is effectively inserting on its own spot
    --=> all OK
    if pickup_length < MIN_INSERTER_LENGTH_THRESHOLD
    or dropoff_length < MIN_INSERTER_LENGTH_THRESHOLD then return true end

    --log("Pickup = " .. serpent.block(pickup) .. ", dropoff = " .. serpent.block(dropoff)
    --    .. ", dot = " .. tostring(dot_product) .. ", pick length = " .. tostring(pickup_length) .. ", drop length = " .. tostring(dropoff_length))

    --The inserter has ample distance being covered. So we need to know its angle
    local cos_angle = dot_product / (pickup_length * dropoff_length)
    --Preprocess so acos doesn't throw an error
    cos_angle = math.max(math.min(cos_angle, 1), -1)
    local angle = math.acos(cos_angle) * 180 / 3.14159 --rad to degrees

    --log("angle = " .. tostring(angle) .. ", cos angle = " .. cos_angle)

    if angle > 170 then return true end --Angle is straight across => auto OK
    if angle > 10 then return false end --Angle is crooked => auto reject

    --Angle is now very shallow along a straight line => definitely OK
    return true
end
--Add all invalid inserters to the blacklist.
for _, prototype in pairs(data.raw.inserter) do
    if not inserter_is_rubia_compatible(prototype) then
        table.insert(internal_blacklist, prototype)
        log("Banning this inserter prototype from Rubia, because it looks incompatible: " .. prototype.name)
    end
end
--#endregion


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
log("Banning these entities from Rubia: " .. serpent.block(dictionary_blacklist))
for category, sub_blacklist in pairs(dictionary_blacklist) do
    for _, prototype in pairs(data.raw[category]) do
        if rubia_lib.array_find(sub_blacklist, prototype.name) then
            rubia.ban_from_rubia(prototype)
        end
    end
end