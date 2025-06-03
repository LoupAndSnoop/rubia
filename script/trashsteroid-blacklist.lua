--This file details the items and entities that will NOT be affected by trashsteroids.

--Array of entity prototypes to ban from only rubia's surface.
--This array can also just be defined and populated at some other stage.
--storage.trashsteroid_pre_blacklist = storage.trashsteroid_pre_blacklist or {}
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

--Rocketizer is immune to trashsteroids, but only if made with craptonite.
if not settings.startup["rubia-rocketizer-early-unlock"].value then
    table.insert(internal_blacklist, "rci-rocketizer") end

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


--Misc mods. This is more specific because names are more likely to conflict.
local mod_item_blacklist = {
    {mod = "RenaiTransportation", name = "RTImpactWagon"},


}
for _, entry in pairs(mod_item_blacklist) do
   if script.active_mods[entry.mod] then table.insert(internal_blacklist, entry.name) end
end

--The actual working blacklist, which is a dictionary of hashsets.
rubia.trashsteroid_blacklist = {}

--On command, make a fast-access blacklist: hashset of all names of all entities that are blacklisted.
rubia.generate_trashsteroid_blacklist = function()
    local full_blacklist = rubia_lib.merge(internal_blacklist, 
        storage.trashsteroid_external_blacklist or {})
    rubia.trashsteroid_blacklist = rubia_lib.array_to_hashset(full_blacklist)
end

--Invoke at least once in control phase to make that runtime blacklist.
rubia.generate_trashsteroid_blacklist()


--Other mods: Use this interface to add prototypes to the blacklist to make them
--immune to trashsteroid damage. Input an array of {type="type",name="entity-name"}
remote.add_interface("add-to-trashsteroid-blacklist", {
    trashsteroid_blacklist = function(additional_blacklist) 
        storage.trashsteroid_external_blacklist = storage.trashsteroid_external_blacklist or {}
        storage.trashsteroid_external_blacklist = rubia_lib.merge(
            storage.trashsteroid_external_blacklist or {}, additional_blacklist) or {}
        rubia.generate_trashsteroid_blacklist()
    end
  })