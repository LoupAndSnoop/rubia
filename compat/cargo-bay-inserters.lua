--Cargo bay inserters allows cheating items left. Selectively only throw an error if:
--1) Planet cargo bay mode allows input AND 2) Rubia is not blacklisted
local prototype_name = "cargo-bay-inserters--planet-cargo-bay-proxy"

local RUBIA_PROXY_CARGOBAY_NAME = rubia.RUBIA_PROXY_CARGOBAY_NAME

if rubia.stage == "data" then
    if not mods["cargo-bay-inserters"] then return end
    local blacklist = data.raw["mod-data"]["cargo-bay-inserters"].data.surface_name_blacklist
    local setting_value = settings.startup[prototype_name .. "-mode"].value
    if setting_value == "output" or setting_value == "none" then
        blacklist["rubia"] = nil
    else blacklist["rubia"] = true --Automated item insertion is allowed => blacklist
    end

    --Make our own proxy
    local rubia_bay_proxy = table.deepcopy(data.raw["proxy-container"][prototype_name])
    assert(rubia_bay_proxy, "No proxy container found for Cargo Bay Inserter compatibility!")
    rubia_bay_proxy.name = RUBIA_PROXY_CARGOBAY_NAME
    rubia_bay_proxy.localised_name = {"",{"entity-name." .. RUBIA_PROXY_CARGOBAY_NAME}, " (", {"space-location-name.rubia"},")"}
    rubia_bay_proxy.flags = {"player-creation", "not-on-map", "no-automated-item-insertion"}
    local bay_setting = settings.startup[prototype_name .. "-mode"].value
    if bay_setting == "input" or bay_setting == "none" then
        table.insert(rubia_bay_proxy.flags, "no-automated-item-removal")
    end
    if setting_value ~= "input" then --Allow insertion only if insertion is the only thing allowed.
        table.insert(rubia_bay_proxy, "no-automated-item-insertion")
    end
    data:extend({rubia_bay_proxy})
    --Unblacklist to be able to hook in properly.
    data.raw["mod-data"]["cargo-bay-inserters"].data.surface_name_blacklist.rubia = nil
    data.raw["mod-data"]["cargo-bay-inserters"].data.planetary_cargo_bay_proxies[RUBIA_PROXY_CARGOBAY_NAME] = true

else --Runtime checks in case other mods get cheeky.
    if not script.active_mods["cargo-bay-inserters"] then return end

    --We only have a problem if the prototype has automated item insertion.
    if prototypes.entity[prototype_name].has_flag("no-automated-item-insertion") and
        prototypes.entity["cargo-landing-pad"].has_flag("no-automated-item-insertion")
    then return end

    --[[local blacklist = prototypes.mod_data["cargo-bay-inserters"].data.surface_name_blacklist
    assert(blacklist["rubia"], "\n\n[img=utility/warning_icon] A mod removed Rubia from cargo bay insertion's blacklist " ..
        " but mod settings allow automated item insertion into cargo bays! Please EITHER: " ..
        "\n   Option 1) Disable the mod that is unblacklisting Rubia from cargo bay inserters, " ..
        "\n   Option 2) Change your mod settings for Cargo Bay Inserters for 'Planet Cargo bay mode' "
        .. "to a mode that does not allow automated item insertion (such as 'output').\n\n")]]
end