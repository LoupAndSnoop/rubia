data:extend {{
    type = "tips-and-tricks-item",
    name = "rubia-briefing",
    category = "space-age",
    tag = "[planet=rubia]",
    indent = 0,
    order = "g-a-a",
    trigger = {
        type = "research",
        technology = "planet-discovery-rubia"
    },
    skip_trigger = {
        type = "or",
        triggers = {
            {
                type = "change-surface",
                surface = "rubia"
            },
            {
                type = "sequence",
                triggers =
                {
                    {
                        type = "research",
                        technology = "planet-discovery-rubia"
                    },
                    {
                        type = "time-elapsed",
                        ticks = 15 * minute
                    },
                    {
                        type = "time-since-last-tip-activation",
                        ticks = 15 * minute
                    }
                }
            }
        }
    },
    simulation = {
        planet = "rubia",
        generate_map = false,
        init = [[
            game.simulation.camera_position = {0, 1.5}

            for x = -12, 12, 1 do
                for y = -6, 6 do
                    game.surfaces[1].set_tiles{{position = {x, y}, name = "highland-yellow-rock"}}
                end
            end


            game.surfaces[1].create_entity {
                name = "rubia-spidertron-remnants",
                position = {-5, 3},
                create_build_effect_smoke = false
            }

            game.surfaces[1].create_entity {
                name = "inserter",
                position = {4, -2},
                create_build_effect_smoke = false
            }

            game.surfaces[1].create_entity {
                name = "transport-belt",
                position = {1, 8},
                create_build_effect_smoke = false
            }.orientation = 0.24

            local create_list = {}
            --table.insert(create_list, { name = "waves-decal", position = {6, -6}, amount = 1})
            for k, position in pairs {{-10, -3}, {-8, -3}, {4, -3}, {8, 1}} do
                table.insert(create_list, { name = "rubia-space-platform-decorative-tiny", position = position, amount = 1})
            end
            for k, position in pairs {{-10, 2},{-8, 3}, {-7, 3}, {5, 3}, {7, 3}, {3, 4}, {6, 4}, {1, 5}} do
                table.insert(create_list, { name = "rubia-space-platform-decorative-1x1", position = position, amount = 1})
            end
            for k, position in pairs {{-1, 7}, {-2, 8}, {-3, 4}, {0, 3}, {8, 4}} do
                table.insert(create_list, { name = "pale-lettuce-lichen-cups-1x1", position = position, amount = 1})
            end
            for x = -12, -6, 1 do
                for y = -6, -2 do
                    table.insert(create_list, { name = "rubia-space-platform-decorative-pipes-1x2", position = {x, y}, amount = 1})
                end
            end
            game.surfaces[1].create_decoratives{decoratives = create_list}
        ]],
        checkboard = false,
        mute_wind_sounds = false,
    },
},

{
    type = "tips-and-tricks-item",
    name = "rubia-trashsteroid-tips",
    category = "space-age",
    tag = "[entity=medium-trashsteroid]",
    indent = 1,
    order = "g-a-c",
    trigger = {
        type = "research",
        technology = "rubia-progression-stage1"
    },
    dependencies = {"rubia-briefing"}
},

{
    type = "tips-and-tricks-item",
    name = "rubia-wind-tips",
    category = "space-age",
    tag = "[entity=rubia-wind-turbine]",
    indent = 1,
    order = "g-a-b",
    trigger = {
        type = "research",
        technology = "rubia-progression-stage1"
    },
    dependencies = {"rubia-briefing"}
},


}