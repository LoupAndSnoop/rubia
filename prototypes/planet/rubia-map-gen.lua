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
          ["rubia-cupric-scrap"] = {},
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
              ["rubia-cupric-scrap"] = {},--{25,0.2,5},
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


--[[
planet_map_gen.nauvis = function()
  return
  {
    aux_climate_control = true,
    moisture_climate_control = true,
    property_expression_names =
    { -- Warning: anything set here overrides any selections made in the map setup screen so the options do nothing.
      --cliff_elevation = "cliff_elevation_nauvis",
      --cliffiness = "cliffiness_nauvis",
      --elevation = "elevation_island"
    },
    cliff_settings =
    {
      name = "cliff",
      control = "nauvis_cliff",
      cliff_smoothing = 0
    },
    autoplace_controls =
    {
      ["iron-ore"] = {},
      ["copper-ore"] = {},
      ["stone"] = {},
      ["coal"] = {},
      ["uranium-ore"] = {},
      ["crude-oil"] = {},
      ["water"] = {},
      ["trees"] = {},
      ["enemy-base"] = {},
      ["rocks"] = {},
      ["starting_area_moisture"] = {},
      ["nauvis_cliff"] = {}
    },
    autoplace_settings =
    {
      ["tile"] =
      {
        settings =
        {
          ["grass-1"] = {},
          ["grass-2"] = {},
          ["grass-3"] = {},
          ["grass-4"] = {},
          ["dry-dirt"] = {},
          ["dirt-1"] = {},
          ["dirt-2"] = {},
          ["dirt-3"] = {},
          ["dirt-4"] = {},
          ["dirt-5"] = {},
          ["dirt-6"] = {},
          
          ["sand-1"] = {},
          ["sand-2"] = {},
          ["sand-3"] = {},
          ["red-desert-0"] = {},
          ["red-desert-1"] = {},
          ["red-desert-2"] = {},
          ["red-desert-3"] = {},
          ["water"] = {},
          ["deepwater"] = {}
        }
      },
      ["decorative"] =
      {
        settings =
        {
          ["brown-hairy-grass"] = {},
          ["green-hairy-grass"] = {},
          ["brown-carpet-grass"] = {},
          ["green-carpet-grass"] = {},
          ["green-small-grass"] = {},
          ["green-asterisk"] = {},
          ["brown-asterisk-mini"] = {},
          ["green-asterisk-mini"] = {},
          ["brown-asterisk"] = {},
          ["red-asterisk"] = {},
          ["dark-mud-decal"] = {},
          ["light-mud-decal"] = {},
          ["cracked-mud-decal"] = {},
          ["red-desert-decal"] = {},
          ["sand-decal"] = {},
          ["sand-dune-decal"] = {},
          ["green-pita"] = {},
          ["red-pita"] = {},
          ["green-croton"] = {},
          ["red-croton"] = {},
          ["green-pita-mini"] = {},
          ["brown-fluff"] = {},
          ["brown-fluff-dry"] = {},
          ["green-desert-bush"] = {},
          ["red-desert-bush"] = {},
          ["white-desert-bush"] = {},
          ["garballo-mini-dry"] = {},
          ["garballo"] = {},
          ["green-bush-mini"] = {},
          ["medium-rock"] = {},
          ["small-rock"] = {},
          ["tiny-rock"] = {},
          ["medium-sand-rock"] = {},
          ["small-sand-rock"] = {}
        }
      },
      ["entity"] =
      {
        settings =
        {
          ["iron-ore"] = {},
          ["copper-ore"] = {},
          ["stone"] = {},
          ["coal"] = {},
          ["crude-oil"] = {},
          ["uranium-ore"] = {},
          ["fish"] = {},
          ["big-sand-rock"] = {},
          ["huge-rock"] = {},
          ["big-rock"] = {},
        }
      }
    }
  }
end
]]