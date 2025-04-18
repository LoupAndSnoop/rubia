local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

--build off of space ages planet gen.


--PLANET MAP GEN
planet_map_gen.rubia = function() --TODO add all my decorations.
    return
    {
        property_expression_names =
        {
          elevation = "elevation_lakes",-- "rubia_elevation",
          temperature = "rubia_temperature",
          moisture = "rubia_moisture",
          aux = "aux_basic",
          cliffiness = "cliffiness_basic",
          cliff_elevation = "cliff_elevation_from_elevation",
          --[[["entity:platinum-ore:probability"] = "rubia_platinum_ore_probability",
          ["entity:platinum-ore:richness"] = "rubia_platinum_ore_richness",]]
          ["entity:rubia-ferric-scrap:probability"] = "rubia_ferric_scrap_probability",
          ["entity:rubia-ferric-scrap:richness"] = "rubia_ferric_scrap_richness",
          ["entity:rubia-cupric-scrap:probability"] = "rubia_cupric_scrap_probability",
          ["entity:rubia-cupric-scrap:richness"] = "rubia_cupric_scrap_richness",
          ["entity:bacterial-sludge:probability"] = "bacterial_sludge_probability",
          ["entity:bacterial-sludge:richness"] = "bacterial_sludge_richness",
        },
        cliff_settings =
        {
          name = "cliff-fulgora",
          control = "fulgora_cliff",
          cliff_elevation_interval = 40,
          cliff_elevation_0 = 80,
          cliff_smoothing = 0
        },
  
        autoplace_controls =
        {
          ["bacterial-sludge"] = {},
          ["rubia-ferric-scrap"] = {},
          ["rubia-cupric-scrap"] = {250000,0.2,5},
          --Controls now show up except we have several problems. 1 no chalcopyrite or sulfur. 2. Platium needs big mining drills.
          --[[
          ["platinum_ore"] = {},
          ["calcite"] = {},
          ["rubia-cliff"] = {},]]

          
        },
        autoplace_settings =
        {
          ["tile"] =
          {
            settings =
            {
              --["grass-4"] = {},
              --["dirt-4"] = {},
              --["dirt-7"] = {},
              --["red-desert-0"] = {},

              ["midland-turquoise-bark-2"] = {},
              ["lowland-brown-blubber"] = {},
              ["lowland-pale-green"] = {},

              ["midland-cracked-lichen-dark"] = {},
              ["midland-cracked-lichen-dull"] = {},

              ["volcanic-ash-cracks"] = {},
              ["volcanic-jagged-ground"] = {},
              ["volcanic-folds"] = {},
              ["volcanic-folds-flat"] = {},
              ["volcanic-pumice-stones"] = {},
              
              ["highland-yellow-rock"] = {}
            }
          },
          ["decorative"] =
          {
            settings =
            {
              
              ["rubia-space-platform-decorative-pipes-1x2"] = {},
              ["rubia-space-platform-decorative-pipes-1x1"] = {},
              ["rubia-space-platform-decorative-pipes-2x1"] = {},
              ["rubia-space-platform-decorative-tiny"] = {},
              ["rubia-space-platform-decorative-1x1"] = {},
              ["rubia-space-platform-decorative-2x2"] = {},
              

              ["pale-lettuce-lichen-1x1"] = {},
              ["pale-lettuce-lichen-3x3"] = {},
              ["pale-lettuce-lichen-cups-1x1"] = {},
              ["pale-lettuce-lichen-cups-3x3"] = {},
              ["mycelium"] = {},
              ["split-gill-dying-1x1"] = {},

              ["grey-cracked-mud-decal"] = {},
              --["crater-large"] = {},

              ["rubia-construction-robot-remnants"] = {},
              ["rubia-medium-junk-remnants"] = {},
              ["rubia-medium-remnants"] = {},
              ["rubia-pump-remnants"] = {},
              ["rubia-heat-exchanger-remnants"] = {},
              --[""] = {}
              --[""] = {}
            }
          },
          ["entity"] =
          {
            settings =
            {
              --Resources
              ["calcite"] = {},

              --Forage
              --["rubia-med-rock"] = {},
              ["rubia-spidertron-remnants"] = {},
              ["rubia-pole-remnants"] = {},
              ["rubia-junk-pile"] = {},
              
              --Resources
              ["bacterial-sludge"] = {},--{frequency = 60, size = 0.1, richness = 10}, --Frequency/Size/richness
              ["rubia-ferric-scrap"] = {},--{frequency = 2000,size = 0.2, richness = 5},
              ["rubia-cupric-scrap"] = {25000,0.2,5},--{25,0.2,5},
              --["chalcopyrite-ore"] = {},
              --["platinum-ore"] = {},
              --["crater-cliff"] = {},
              --["huge-rubia-rock"] = {}
            }
          }
        }
    }
end

--TODO iron chest dying explosion

return planet_map_gen

