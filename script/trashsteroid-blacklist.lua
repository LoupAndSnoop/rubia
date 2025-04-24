--This file details the items and entities that will NOT be affected by trashsteroids.

--Array of entity prototypes to ban from only rubia's surface.
--Input {type="type",name="entity-name"}, such that data.raw["type"]["entity-name"] gives the prototype. This is global, so other mods can add entries
--to this array before we do our thing. This array can also just be defined and populated
--at some other stage.
rubia.trashsteroid_pre_blacklist = rubia.trashsteroid_pre_blacklist or {}
local internal_blacklist = {
    --Rails
    {type="entity", name="straight-rail"},
    {type="entity", name="half-diagonal-rail"},
    {type="entity", name="curved-rail-a"},
    {type="entity", name="curved-rail-b"},
    {type="entity", name="elevated-straight-rail"},
    {type="entity", name="elevated-half-diagonal-rail"},
    {type="entity", name="elevated-curved-rail-a"},
    {type="entity", name="elevated-curved-rail-b"},
    {type="entity", name="legacy-straight-rail"},
    {type="entity", name="legacy-curved-rail"},
    {type="entity", name="rail-signal"},
    {type="entity", name="rail-chain-signal"},

    --Other
    {type="entity", name="craptonite-wall"},
    {type="entity", name="rubia-armored-locomotive"},
    {type="entity", name="rubia-armored-cargo-wagon"},
    {type="entity", name="rubia-armored-fluid-wagon"},
    {type="entity", name="character-corpse"},
}

if script.active_mods["elevated-rails"] then
    local elev_blacklist = {
        {type="entity", name="rail-ramp"},
        {type="entity", name="rail-support"},
        {type="entity", name="elevated-straight-rail"},
        {type="entity", name="elevated-half-diagonal-rail"},
        {type="entity", name="elevated-straight-rail"},
        {type="entity", name="elevated-half-diagonal-rail"},
        {type="entity", name="elevated-curved-rail-a"},
        {type="entity", name="elevated-curved-rail-b"},
    }
    internal_blacklist = rubia_lib.array_concat({internal_blacklist, elev_blacklist})
end

--Merge with any existing blacklist in case other mods want to add to this blacklist variable.
rubia.trashsteroid_pre_blacklist = rubia_lib.array_concat({rubia.trashsteroid_pre_blacklist, internal_blacklist})

--The actual working blacklist, which is a dictionary of hashsets.
rubia.trashsteroid_blacklist = {}
--On command, make a fast-access blacklist: dictionary of hashsets.
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
end
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