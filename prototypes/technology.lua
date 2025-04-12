require("util")

--Infinite braking force
--[[data:extend({
    {
        type = "technology",
        name = "braking-force-8",
        icons = util.technology_icon_constant_braking_force("__base__/graphics/technology/braking-force.png"),
        effects =
        {
          {
            type = "train-braking-force-bonus",
            modifier = 0.2
          }
        },
        prerequisites = {"braking-force-7","metallurgic-science-pack"},
        unit =
        {
          count_formula = "2^(L-7)*500",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"metallurgic-science-pack", 1}
          },
          time = 60
        },
        max_level = "infinite",
        upgrade = true
      },
    })
    ]]


data:extend({
    --BASICS
    {
        type = "technology",
        name = "planet-discovery-rubia",
        icons = util.technology_icon_constant_planet("__rubia__/graphics/technology/rubia-discovery.png"),
        icon_size = 256,
        essential = true,
        effects =
        {
            {
                type = "unlock-space-location",
                space_location = "rubia",
                use_icon_overlay_constant = true
            },
            {
                type = "unlock-recipe",
                recipe = "rubia-wind-turbine",
            },
        },
        prerequisites = { "space-platform-thruster", "energy-shield-equipment", "electric-energy-distribution-1"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "space-science-pack",           1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "platinum-processing-rubia",
        icon_size = 256,
        icon = "__rubia__/graphics/technology/platinum-processing.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "platinum-plate-production-alt"
            },
            {
                type = "unlock-recipe",
                recipe = "platinum-plate"
            },
            {
                type = "unlock-recipe",
                recipe = "pressurized-acid-neutralization-alt"
            },
            {
                type = "unlock-recipe",
                recipe = "pressurized-acid-neutralization"
            }
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "platinum-ore"
        },
        prerequisites = { "planet-discovery-rubia" }
    },
    {
        type = "technology",
        name = "chalcopyrite-processing-rubia",
        icon_size = 64,
        icon = "__rubia__/graphics/icons/chalcopyrite-ore.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "chalcopyrite-refining"
            },
            {
                type = "unlock-recipe",
                recipe = "reactive-displacement"
            },
            {
                type = "unlock-recipe",
                recipe = "force-reduction-iron"
            },
            {
                type = "unlock-recipe",
                recipe = "force-reduction-copper"
            },
            {
                type = "unlock-recipe",
                recipe = "super-saturated-displacement"
            },
            {
                type = "unlock-recipe",
                recipe = "destructive-dilute-acid-neutralization"
            },
            {
                type = "give-item",
                item = "iron-plate",
                count = 200
            },
            {
                type = "give-item",
                item = "copper-plate",
                count = 200
            },
            {
                type = "give-item",
                item = "steel-plate",
                count = 200
            },
            {
                type = "give-item",
                item = "pipe",
                count = 200
            }
        },
        research_trigger =
        {
            type = "mine-entity",
            entity = "chalcopyrite-ore"
        },
        prerequisites = { "planet-discovery-rubia" }
    },
    {
        type = "technology",
        name = "biorecycling-plant",
        icon_size = 64,
        icon = "__rubia__/graphics/icons/catalytic-chemical-plant.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "catalytic-chemical-plant-recipe"
            }
        },
        research_trigger =
        {
            type = "craft-item",
            item = "platinum-plate",
            count = 1
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing-rubia" }
    },
    {
        type = "technology",
        name = "biorecycling-science-pack",
        icon_size = 256,
        icon = "__rubia__/graphics/technology/biorecycling-science-pack.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "biorecycling-science-pack"
            },
            {
                type = "unlock-recipe",
                recipe = "sulfur-combustion"
            },

        },
        research_trigger =
        {
            type = "craft-item",
            item = "catalytic-chemical-plant",
            count = 1
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant" }
    },

--[[

    --Step 1
    {
        type = "technology",
        name = "sulfur-redox1",
        icon_size = 256,
        icon = "__base__/graphics/technology/sulfur-processing.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "hydrogen-sulfide"
            }
        },
        research_trigger =
        {
            type = "craft-fluid",
            fluid = "sulfur-dioxide",
            count = 1
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack" }
    },
    {
        type = "technology",
        name = "sulfur-redox2",
        icon_size = 256,
        icon = "__base__/graphics/technology/sulfur-processing.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "sulfur-reduction"
            },
            {
                type = "unlock-recipe",
                recipe = "sulfurous-oxidation"
            }
        },
        research_trigger =
        {
            type = "craft-fluid",
            fluid = "hydrogen-sulfide",
            count = 1
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1" }
    },

    --Step 2 sulfates.
    {
        type = "technology",
        name = "sulfate-processing-1",
        icon_size = 256,
        icon = "__base__/graphics/technology/sulfur-processing.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "hydrogen-sulfide-combustion"
            },

        },
        research_trigger =
        {
            type = "craft-item",
            item = "sulfur",
            count = 10
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2"}
    },
    {
        type = "technology",
        name = "sulfate-processing-2",
        icon_size = 256,
        icon = "__base__/graphics/technology/sulfur-processing.png",
        essential = true,
        effects =
        {

            {
                type = "unlock-recipe",
                recipe = "sulfuric-acid-dilution"
            },
            {
                type = "unlock-recipe",
                recipe = "sulfuric-acid-concentration"
            },
            {
                type = "unlock-recipe",
                recipe = "sulfuric-acid-concentration-alt"
            },
            {
                type = "unlock-recipe",
                recipe = "dilute-acid-neutralization"
            },

            {
                type = "unlock-recipe",
                recipe = "hot-water-to-steam"
            },

        },
        research_trigger =
        {
            type = "craft-fluid",
            fluid = "sulfur-dioxide",
            count = 2000
        },
        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1" }
    },


    --Step 3 Plastics, calcium sulfate
    {
        type = "technology",
        name = "sulfonated-plastic",
        icon_size = 256,
        icon = "__space-age__/graphics/technology/plastics-productivity.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "sulfonated-plastic"
            },
            {
                type = "unlock-recipe",
                recipe = "petroleum-alkylation"
            },
            {
                type = "unlock-recipe",
                recipe = "sulfonated-plastic-production-alt"
            },
            {
                type = "unlock-recipe",
                recipe = "rocket-fuel-catalytic-chemistry"
            },

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2" },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "biorecycling-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "calcium-sulfate",
        icon_size = 64,
        icon = "__rubia__/graphics/icons/calcium-sulfate.png",
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate"
            },
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate-production-alt"
            }

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "biorecycling-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "calcium-sulfate-nutrients",
        icon_size = 256,
        icon = "__space-age__/graphics/technology/bioflux.png", --Not sure if I like bioflux image here...
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate-fish"
            },
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate-bioflux"
            },
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate-egg"
            }

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","calcium-sulfate","agricultural-science-pack" },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "biorecycling-science-pack", 1 },
                { "agricultural-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "calcium-sulfate-recovery",
        icon_size = 256,
        icon = "__base__/graphics/technology/landfill.png",
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "calcium-sulfate-recovery"
            },
        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","calcium-sulfate","calcium-sulfate-nutrients" },
        unit =
        {
            count = 750,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "production-science-pack",      1 },
                { "utility-science-pack",         1 },
                { "biorecycling-science-pack", 1 },
                { "agricultural-science-pack", 1 },
            },
            time = 60
        }
    },

    {
        type = "technology",
        name = "stone-production",
        icon_size = 256,
        icon = "__base__/graphics/technology/concrete.png", --Not sure if I like concrete image here...
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "stone-production"
            },


        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","calcium-sulfate" },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "biorecycling-science-pack", 1 },
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "recrystalization",
        icon_size = 256,
        icon = "__rubia__/graphics/technology/recrystalization.png", 
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "copper-recrystalization",
            },
            {
                type = "unlock-recipe",
                recipe = "iron-recrystalization",
            },
            {
                type = "unlock-recipe",
                recipe = "iron-recrystalization-alt",
            },
            {
                type = "unlock-recipe",
                recipe = "copper-recrystalization-alt",
            },
            {
                type = "unlock-recipe",
                recipe = "iron-stick-recrystalization",
            },


        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1"},
        unit =
        {
            count = 500,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "biorecycling-science-pack", 1 },
            },
            time = 60
        }
    },
    
    --STEP 4
    {
        type = "technology",
        name = "asphalt-and-concrete",
        icon_size = 256,
        icon = "__base__/graphics/technology/concrete.png", --Not sure if I like concrete image here...
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "asphalt-production"
            },
            {
                type = "unlock-recipe",
                recipe = "asphalt-production-alt"
            },
            {
                type = "unlock-recipe",
                recipe = "concrete-production-from-asphalt"
            },
            {
                type = "unlock-recipe",
                recipe = "light-oil-alkylation"
            },
            {
                type = "unlock-recipe",
                recipe = "carbon-dioxide-to-carbon",
            }

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","calcium-sulfate" },
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                --{ "utility-science-pack",         1 },
                --{ "production-science-pack",      1 },
                { "biorecycling-science-pack", 1 },
            },
            time = 60
        }
    },
    --Productivity

    {
        type = "technology",
        name = "pressure-laboratory",
        icon_size = 64,
        --icon = "__base__/graphics/technology/lamp.png", --PLACEHOLDER
        icon = "__rubia__/graphics/icons/pressure-lab.png", --PLACEHOLDER
        essential = true,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "pressure-laboratory-recipe"
            },


        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "production-science-pack",      1 },
                { "biorecycling-science-pack", 1 },
                { "space-science-pack", 1 },
                { "military-science-pack", 1 },
            },
            time = 60
        }
    },

    {
        type = "technology",
        name = "rocket-fuel-catalysis-productivity-infinite",
        icons = util.technology_icon_constant_recipe_productivity("__space-age__/graphics/technology/rocket-fuel-productivity.png"),
        icon_size = 256,
        effects =
        {
          {
            type = "change-recipe-productivity",
            recipe = "rocket-fuel-catalytic-chemistry",
            change = 0.10
          },
        },
        prerequisites = {"biorecycling-science-pack"},
        unit =
        {
        count_formula = "1.5^L*1000",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"biorecycling-science-pack", 1},
          },
          time = 60
        },
        max_level = "infinite",
        upgrade = true
    },

    {
        type = "technology",
        name = "steam-turbine-productivity-infinite",
        icons = util.technology_icon_constant_recipe_productivity("__base__/graphics/technology/fluid-handling.png"),
        icon_size = 256,
        effects =
        {
          {
            type = "change-recipe-productivity",
            recipe = "steam-turbine",
            change = 0.10
          },
        },
        prerequisites = {"biorecycling-science-pack"},
        unit =
        {
        count_formula = "1.5^L*1000",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"biorecycling-science-pack", 1},
          },
          time = 60
        },
        max_level = "infinite",
        upgrade = true
    },
    {
        type = "technology",
        name = "pipe-productivity-infinite",
        icons = util.technology_icon_constant_recipe_productivity("__base__/graphics/technology/fluid-handling.png"),
        icon_size = 256,
        effects =
        {
          {
            type = "change-recipe-productivity",
            recipe = "pipe",
            change = 0.025
          },
          {
            type = "change-recipe-productivity",
            recipe = "casting-pipe",
            change = 0.025
          },
        },
        prerequisites = {"biorecycling-science-pack"},
        unit =
        {
        count_formula = "1.5^L*1000",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"biorecycling-science-pack", 1},
          },
          time = 60
        },
        max_level = "infinite",
        upgrade = true
    },

    {
        type = "technology",
        name = "sulfuric-acid-productivity-infinite",
        icons = util.technology_icon_constant_recipe_productivity("__base__/graphics/technology/sulfur-processing.png"),
        icon_size = 256,
        effects =
        {
          {
            type = "change-recipe-productivity",
            recipe = "sulfurous-oxidation",
            change = 0.05
          },
          {
            type = "change-recipe-productivity",
            recipe = "sulfuric-acid",
            change = 0.05
          },
        },
        prerequisites = {"biorecycling-science-pack"},
        unit =
        {
        count_formula = "1.5^L*1000",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"biorecycling-science-pack", 1},
          },
          time = 60
        },
        max_level = "infinite",
        upgrade = true
    },


    --Other techs
    {
        type = "technology",
        name = "research-speed-infinite",
        icons = util.technology_icon_constant_recipe_productivity("__space-age__/graphics/technology/research-productivity.png"),
        icon_size = 256,

        effects =
        {
          {
            type = "laboratory-speed",
            modifier = 0.10
          },
        },
        prerequisites = {"promethium-science-pack","research-speed-6"},
        unit =
        {
          count_formula = "1.25^L*1000",
          ingredients =
          {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"military-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1},
            {"space-science-pack", 1},
            {"metallurgic-science-pack", 1},
            {"electromagnetic-science-pack", 1},
            {"agricultural-science-pack", 1},
            {"cryogenic-science-pack", 1},
            {"biorecycling-science-pack", 1},
            {"promethium-science-pack", 1}
          },
          time = 90
        },
        max_level = "infinite",
        upgrade = true
    },
    {
        type = "technology",
        name = "space-steam-production",
        icon_size = 256,
        icon = "__space-age__/graphics/technology/space-platform-thruster.png", 
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "thruster-fuel-oxidizer-to-steam"
            },


        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","pressure-laboratory"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "production-science-pack",      1 },
                { "biorecycling-science-pack", 1 },
                { "space-science-pack", 1 },
                { "military-science-pack", 1 },
                
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "dry-ice-production",
        icon_size = 256,
        icon = "__space-age__/graphics/technology/health.png", 
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "dry-ice-production",
            },
            {
                type = "unlock-recipe",
                recipe = "dry-ice-production-alt",
            },
            {
                type = "unlock-recipe",
                recipe = "ice-box-production",
            },
            {
                type = "unlock-recipe",
                recipe = "controlled-petrol-combustion",
            },


        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","pressure-laboratory"},
        unit =
        {
            count = 1000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "production-science-pack",      1 },
                { "biorecycling-science-pack", 1 },
                { "space-science-pack", 1 },
                { "military-science-pack", 1 },
                
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "platinum-thruster",
        icon_size = 256,
        icon = "__rubia__/graphics/technology/platinum-thruster-tech.png", 
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "platinum-thruster",
            },

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","pressure-laboratory"},
        unit =
        {
            count = 2000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "utility-science-pack",         1 },
                { "production-science-pack",      1 },
                { "biorecycling-science-pack", 1 },
                { "space-science-pack", 1 },
                { "military-science-pack", 1 },
                { "metallurgic-science-pack", 1 },
                
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "sulfur-poison-capsule",
        icon_size = 64,
        --icon = "__base__/graphics/technology/lamp.png", --PLACEHOLDER
        icon = "__rubia__/graphics/icons/poison-capsule.png", --PLACEHOLDER
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "sulfur-poison-capsule",
            },

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","pressure-laboratory"},
        unit =
        {
            count = 2000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "biorecycling-science-pack", 1 },
                { "military-science-pack", 1 },
                
            },
            time = 60
        }
    },
    {
        type = "technology",
        name = "blue-rocket",
        icon_size = 256,
        icon = "__rubia__/graphics/technology/blue-rocket.png", 
        essential = false,
        effects =
        {
            {
                type = "unlock-recipe",
                recipe = "blue-rocket",
            },
            {
                type = "unlock-recipe",
                recipe = "explosives-from-sulfuric-oxidizer",
            },
            {
                type = "unlock-recipe",
                recipe = "sulfuric-oxidizer",
            },

        },

        prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","pressure-laboratory"},
        unit =
        {
            count = 3000,
            ingredients =
            {
                { "automation-science-pack",      1 },
                { "logistic-science-pack",        1 },
                { "chemical-science-pack",        1 },
                { "biorecycling-science-pack", 1 },
                { "military-science-pack",        1 },
                
            },
            time = 60
        }
    },
    ]]
}
)

--[[
if mods["maraxsis"] then
    data:extend(
    {
        {
            type = "technology",
            name = "petrol-dehydrogenation-and-combustion",
            icon_size = 64,
            icon = "__rubia__/graphics/icons/catalytic-chemical-plant.png",
            essential = false,
            effects =
            {
                {
                    type = "unlock-recipe",
                    recipe = "petrol-dehydrogenation-and-combustion",
                },
                {
                    type = "unlock-recipe",
                    recipe = "petrol-dehydrogenation-and-combustion-maraxsis",
                },

    
    
            },
    
            prerequisites = { "planet-discovery-rubia","platinum-processing","catalytic-chemical-plant","biorecycling-science-pack","sulfur-redox1","sulfur-redox2","sulfate-processing-1","sulfate-processing-2","hydraulic-science-pack"},
            unit =
            {
                count = 1000,
                ingredients =
                {
                    { "automation-science-pack",      1 },
                    { "logistic-science-pack",        1 },
                    { "chemical-science-pack",        1 }, 
                    { "biorecycling-science-pack", 1 },
                    { "space-science-pack", 1 },
                    {"hydraulic-science-pack", 1}
                    
                },
                time = 60
            }
        }
    }
    )
end
]]