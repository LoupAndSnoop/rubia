

--Remove settings from Rocket Cargo insertion to force it to always be in proxy mode.
if mods["RocketCargoInsertion"] then
    data.raw["bool-setting"]["rci-silo-recipes"].hidden = true
    data.raw["bool-setting"]["rci-processing-unit"].hidden = true
    data.raw["bool-setting"]["rci-low-density-structure"].hidden = true
    data.raw["bool-setting"]["rci-rocket-fuel"].hidden = true

    data.raw["string-setting"]["rci-mode"].hidden = true
    data.raw["string-setting"]["rci-mode"].allowed_values = {"proxy"}
    data.raw["string-setting"]["rci-mode"].default_value = "proxy"
end


--For blueprint shotgun, need to hide the no-wood mode, since we are always going to change to no wood
if mods["blueprint-shotgun"] then
    data.raw["bool-setting"]["blueprint-shotgun-no-wood"].hidden = true
end

--Exotic space industries nukes trigger techs by default.
if mods["exotic-space-industries"] then
    local no_triggers = data.raw["bool-setting"]["ei-no-triggers"]
    no_triggers.forced_value = false
    no_triggers.allowed_values = {false}
    no_triggers.hidden = true

    local remove_sci = data.raw["bool-setting"]["ei-debloat"]
    remove_sci.forced_value = false
    remove_sci.allowed_values = {false}
    remove_sci.hidden = true

end