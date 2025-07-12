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
                name = "rubia-junk-pile",
                position = {4, -2},
                create_build_effect_smoke = false
            }
            game.surfaces[1].create_entity {
                name = "rubia-junk-pile",
                position = {7, 6},
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

{
    type = "tips-and-tricks-item",
    name = "rubia-crapapult-tips",
    category = "space-age",
    tag = "[entity=crapapult]",
    indent = 1,
    order = "g-a-d",
    trigger = {
      type = "build-entity",
      entity = "crapapult",
    },
    dependencies = {"rubia-briefing"},
    simulation =
    {
        planet = "rubia",
        init_update_count = 620,
        init =
        [[
            game.simulation.camera_position = {0+5, 0.5}

            for _, force in pairs(game.forces) do
                force.inserter_stack_size_bonus = 15
                force.bulk_inserter_capacity_bonus = 15
            end

            game.surfaces[1].create_entities_from_blueprint_string
            {
            string = "0eNrNWttymzAQ/Rc9Q0d3iby2f5HJeDCWU02xYLikTTP+9wq7sdsGau0mD/jFNqCzF+2elVa8kG09urbzYSB3L8RXTejJ3f0L6f1jKOvpWigPjtyRqivbsh3rgRwz4sPO/SB37PiQERcGP3h3Hnb687wJ42HruvhA9jrch70P8VZefXX9QDLSNn0c1oRJRITKGRWfVEae40/9SZ1knEdsejcMPjz205OdOzRPbjPGe/XgOrfb+MEd4q19WfcuI+fLZ11+Sy53T2Wo3C6vfFeNfpJdNeNkL6c0I4dmd3pqyGtXnjS7Gnc8Zm9M4iiTzIea1HZN5fo+IuRjeLdF4mLRPj6e923thyhx1iB6MSias/Odq8735QyuvODWTblbAOR/TvmfgBkZnttpcDMO7ThF3RsBCiDAYARo1FzLNYevQZmkVhy+FhO+6nb4FoDokpjoYhQgQaEkXPl36MrQt0035FtXz812Yf+O3xveYTzZ7UVxIfYEXIFRWSWpLAHQetEbdg5apXvDAGKQ4RiIr5mBGI6CxIopiFlAJnNUJhcYlhO3I4xDSEhgVOcoEpq8NAfGMWBiAUxgCIGnEAJHcY1Igr5yzXasv+U+9K6bDwUrF5VmfA5ap2tt1a2pwuU5XfXi36JsYivmLg5Z51AMAQiK4S52m7sEA6jOUKpf6ebgdn485K6O4ztf5W1Tu/8uduh8WgiBWDjxBGegGIemMI5QGGiWBK3BDla3HGygkNbcgrQIymVJlCsKBDRNgpYUw+Zs3gWSYcAW/CmvaXVtK83gvKbuLIbAUPHHMnHVtK3r8qrcnuLqPTQsJcacjy2W5zxpQsyUjymXEtChQfGz1IjSklBZpElXHFUT5ZVRLuzkgusenyMDRAP2ZTVLfvYs8t/szyJ57Peu2/T+p5s6C5fPnOwCQec0ZYetKAJ5gXAUZNsgQVpC9hAKhAzZUHAQMqS6CxAypLhTEDJgN1EwELIBFKMChGwByBaEDMg6C8o6DanzBoSMKfoLNV+jDk7EWuu1Ri0/+LrrtQYc2aB6QVoh6nVCF0vrdMVR/TdtEH0nkZRjFoHMk5AL+E4zYaNpMEV+oUdkGLxvnhAOBsU1aq1cY1BcI9fNNUYiqCAh6g1gz4E6VDMArkGdCxoM16iFBMOwi1zAKjBhaNaaVZZizNHrzirLEFmV8C6H5elBj3rVwop0AaiXRayEV8M359UPGfke/09zeC94pjKhM/WQ3U9fmTDxd3ximvWpnXd5sSojdRlzLl77/Nrt+hJjJV5/ivFwglaaF7IolKFcmYIfj78AXFhfkw==",
            position = {-9 + 5, 1}
            }
        ]]
    },
},
}