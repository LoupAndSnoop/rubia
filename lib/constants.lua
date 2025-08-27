local constants = {}

--constants.DISABLE_TECH_HIDING = false
constants.RUBIA_AUTO_ENTITY_PREFIX = "rubia-auto-variant-"
constants.WARNING_PRINT_SETTINGS = {color={r=0.9,g=0,b=0,a=1}}
constants.GREEN_PRINT_SETTINGS = {color={r=0.2,g=1,b=0.2,a=1}}
constants.MEGABASE_MODE = settings.startup["rubia-megabase-mode"].value

--table<string of prototype type, names of prototypes[]> tied to biofusion sci
constants.BIOFUSION_LINE = {
    technology = {"rubia-biofusion-science-pack", "rubia-nutrients-from-sludge",
        "rubia-long-stack-inserter", "rubia-biofusion-promethium-science-pack",
        "rubia-cargo-landing-pad-capacity", "rubia-biochamber-productivity-bonus",
        "rubia-nutrient-productivity"
    },
    recipe = {"rubia-biofusion-science-pack", "rubia-biofusion-promethium-science-pack",
        "rubia-long-stack-inserter", "rubia-nutrients-from-sludge"
    },
}

--string[] of mod names known to remove surface restrictions
constants.NO_SURFACE_RESTRICTION_MODS = {
    "NoCraftingSurfaceCondition", "no-cond", "no_placement_restriction", 
    "surface_restriction_removal_rubia_compat"}
--string[] of mod names known to block biofusion
constants.BIOFUSION_BLOCKING_MODS = {"delete-gleba", "FarmingInAnotherWorld"}
for _, entry in pairs(constants.NO_SURFACE_RESTRICTION_MODS) do
    table.insert(constants.BIOFUSION_BLOCKING_MODS, entry)
end

return constants