--This file details the items and entities that will NOT be affected by trashsteroids.

--Array of entity prototypes to ban from only rubia's surface.
--This array can also just be defined and populated at some other stage.
rubia.trashsteroid_pre_blacklist = rubia.trashsteroid_pre_blacklist or {}
local internal_blacklist = {
    --Rails
    "straight-rail","half-diagonal-rail","curved-rail-a","curved-rail-b",
    "elevated-straight-rail","elevated-half-diagonal-rail","elevated-curved-rail-a",
    "elevated-curved-rail-b","legacy-straight-rail","legacy-curved-rail",
    "rail-signal","rail-chain-signal",
    --Muh cheats
    "infinity-pipe","linked-belt","electric-energy-interface",
    "infinity-chest","heat-interface",
    --Anything made with craptonite
    "craptonite-wall","rubia-armored-locomotive","rubia-armored-cargo-wagon",
    "rubia-armored-fluid-wagon",
    "rubia-long-bulk-inserter", "rubia-long-stack-inserter", 
    --Other
    "character-corpse",
}

if script.active_mods["elevated-rails"] then
    local elev_blacklist = {"rail-ramp","rail-support","elevated-straight-rail",
        "elevated-half-diagonal-rail","elevated-straight-rail",
        "elevated-half-diagonal-rail","elevated-curved-rail-a",
        "elevated-curved-rail-b"}
    internal_blacklist = rubia_lib.array_concat({internal_blacklist, elev_blacklist})
end

--Muh cheats
if script.active_mods["EditorExtensions"] then
    local ee_blacklist = {"ee-infinity-chest", "ee-aggregate-chest",
        "ee-infinity-chest-passive-provider", "ee-infinity-chest-storage", "ee-infinity-chest-buffer",
        "ee-infinity-chest-requester", "ee-aggregate-chest","ee-aggregate-chest-passive-provider",
        "ee-linked-chest", "ee-infinity-loader", "ee-linked-belt",
        "ee-super-inserter", "ee-super-radar", "ee-super-pump", "ee-infinity-pipe",
        "ee-infinity-heat-pipe", "ee-super-lab", "ee-super-beacon", "ee-super-roboport",
        "ee-infinity-accumulator-primary-output", "ee-infinity-accumulator-secondary-output", "ee-infinity-accumulator-tertiary-output",
        "ee-infinity-accumulator-primary-input", "ee-infinity-accumulator-secondary-input", "ee-infinity-accumulator-tertiary-input",
        "ee-infinity-accumulator-tertiary-buffer",
        "ee-super-electric-pole", "ee-super-substation"}
    internal_blacklist = rubia_lib.array_concat({internal_blacklist, ee_blacklist})
end



--Merge with any existing blacklist in case other mods want to add to this blacklist variable.
rubia.trashsteroid_pre_blacklist = rubia_lib.array_concat({rubia.trashsteroid_pre_blacklist, internal_blacklist})

--The actual working blacklist, which is a dictionary of hashsets.
rubia.trashsteroid_blacklist = {}

--On command, make a fast-access blacklist: hashset of all names of all entities that are blacklisted.
rubia.generate_trashsteroid_blacklist = function()
    local trashsteroid_blacklist = {}
    for _, entry in pairs(rubia.trashsteroid_pre_blacklist) do
        assert(prototypes["entity"][entry], "In trashsteroid blacklist, Did not find " .. entry)

        if not trashsteroid_blacklist then 
            trashsteroid_blacklist = {[entry] = 1}
        else trashsteroid_blacklist[entry] = 1
        end
    end
    rubia.trashsteroid_blacklist = trashsteroid_blacklist
end

--[[On command, make a fast-access blacklist: dictionary of hashsets.
--dictionary[prototype type] = hashset of names of everything in it.
rubia.generate_trashsteroid_blacklist = function()
    local trashsteroid_blacklist = {}
    for _, entry in pairs(rubia.trashsteroid_pre_blacklist) do
        assert(prototypes[entry.type][entry.name], 
            "In trashsteroid blacklist Did not find " .. entry.name .. " of type " .. entry.type)

        if not trashsteroid_blacklist[entry.type] then 
            trashsteroid_blacklist[entry.type] = {[entry.name] = 1}
        else trashsteroid_blacklist[entry.type][entry.name] = 1
        end
    end
    rubia.trashsteroid_blacklist = trashsteroid_blacklist
end]]
--Invoke at least once in control phase to make that runtime blacklist.
rubia.generate_trashsteroid_blacklist()


--Other mods: Use this interface to add prototypes to the blacklist to make them
--immune to trashsteroid damage. Input an array of {type="type",name="entity-name"}
remote.add_interface("add-to-trashsteroid-blacklist", {
    trashsteroid_blacklist = function(additional_blacklist) 
        rubia.trashsteroid_pre_blacklist = rubia_lib.merge(rubia.trashsteroid_pre_blacklist, additional_blacklist)
        rubia.generate_trashsteroid_blacklist()
    end
  })