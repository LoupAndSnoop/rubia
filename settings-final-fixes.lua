

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