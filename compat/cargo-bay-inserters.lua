--Cargo bay inserters allows cheating items left. Selectively only throw an error if:
--1) Planet cargo bay mode allows input AND 2) Rubia is not blacklisted
local prototype_name = "cargo-bay-inserters--planet-cargo-bay-proxy"

if rubia.stage == "data" then
    if not mods["cargo-bay-inserters"] then return end
    local blacklist = data.raw["mod-data"]["cargo-bay-inserters"].data.surface_name_blacklist
    local setting_value = settings.startup[prototype_name .. "-mode"].value
    if setting_value == "output" or setting_value == "none" then
        blacklist["rubia"] = nil
    else blacklist["rubia"] = true --Automated item insertion is allowed => blacklist
    end

else --Runtime checks in case other mods get cheeky.
    if not script.active_mods["cargo-bay-inserters"] then return end

    --We only have a problem if the prototype has automated item insertion.
    if prototypes.entity[prototype_name].has_flag("no-automated-item-insertion") and
        prototypes.entity["cargo-landing-pad"].has_flag("no-automated-item-insertion")
    then return end

    local blacklist = prototypes.mod_data["cargo-bay-inserters"].data.surface_name_blacklist
    assert(blacklist["rubia"], "\n\n[img=utility/warning_icon] A mod removed Rubia from cargo bay insertion's blacklist " ..
        " but mod settings allow automated item insertion into cargo bays! Please EITHER: " ..
        "\n   Option 1) Disable the mod that is unblacklisting Rubia from cargo bay inserters, " ..
        "\n   Option 2) Change your mod settings for Cargo Bay Inserters for 'Planet Cargo bay mode' "
        .. "to a mode that does not allow automated item insertion (such as 'output').\n\n")
end