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
            string = "0eNrNWtty2yAQ/ReeUUfcUV7bv8hkPLKMU6aypNElbZrxvxfZjZ0mJGK3eZBfYiM4y4o9h4XNE9nWk+t634zk5on4qm0GcnP7RAZ/35T13NaUB0duSNWXXdlN9UiOlPhm536RG3a8o8Q1ox+9Ow87/XjcNNNh6/rQgT4P983eN+FRVn13w0go6dohDGub2USAyrT8oih5DGO4yr+ok5HzkM3gxtE398PctXeH9sFtpvCsHl3vdhs/ukN4tC/rwVFybj5P5q/prm8rNwwBIZsCXrBdtdPsL89zSg7tbu5UjlntytPMrs4dj/SNSxznEvtUl8rdQ9lUbpdVvq+m//ZJXHyq23IXWiK+iH8XZ+d7V507SErGx24e3U5jN80B8saChFhgGAvqYmEfXM6GrvbjGDfEXizLK0MRYI1bcL7iGDY4l8SaY9hCIoxjIqyAWBAYCyxPD+L8RagtBzFjKHqIBGSejKwsDPkqS2NfNkPX9mO2dXUsTFXxmnlL4BIHLpLAFQDcfABuY+BIQZIrFiSGVCS1ZkViIEmSKMEAaZLCmOA5SjkSWMIZjoLzm4rBcRycegdO4DgsUzjMJQ5cJYED1Efq5Rdx1ZvtVP/IfDO4Ph4AUn0wVcZj4Eji6zWfECzOJ7NmMeMgpdEYpRE5xIRBmWCoBEsvi5m4qs/B7fx0yFwd+ve+yrq2dgsGTJx6QqC01yRMV0Knq/TydJFpj05RNaFx4CYJ3EBfhzTLr8PidPg9uAIHp+NwMkfJukmSdclQ4DoN/Eq166VUBPgqFVH/BU6l7aeq9DnM2iYE2ufotJQ4t4pPdatqu871WVVuT+T5L4cUZFewqMspDTFRoEwYlJIXy0ourypz0SzXuP7+MbAuWNiXVVTOi8sre005Gji737t+M/jfbr6UuHxi5gGq9HILsSnnaJXjNL+IS55iOLi0uUKOHxIKDjmMKCg45DDCoeCQnEBAwSE5QQ4FNwBwBgWH5AYWCg7JFAoguM5xaYiNc1IDOCmhnNS4Yo3O173Ha1zqotla93gNKQ9pVAFKQ9IIjapAaY05XOo8IY5R2YNOKW5ZzO19EnKBuo6LrG6sgJXjwFkSOC5NOM08BocUIb5uETJIERJrFSEDEiFUBdGARAhVQjQaJRUJ5ThjcJzj79DC4uDEO3AFLhzlullmc5xbaq0sswxCAVRRzHKICVRRzArUVi+XWWYlir9vtrU7Sn6G3/My3gpOFRWSqjt6O/+hwoTvoce88PMV3eVfwCipy8DB0Pb1+WbtWwiX0P4QQuIErTQvZFEok3NlCn48/gG6toOJ",
            position = {-9 + 5, 1}
            }
        ]]
    },
},

{
    type = "tips-and-tricks-item",
    name = "rubia-rocketizer-tips",
    category = "space-age",
    tag = "[entity=rci-rocketizer]",
    indent = 1,
    order = "g-a-g",
    trigger = {
      type = "research",
      technology = "rubia-project-trashdragon",
    },
    dependencies = {"rubia-briefing"},
    localised_description = {"entity-description.rci-rocketizer"},
    simulation =
    {
        init_update_count = 100,
        mods = {"RocketCargoInsertion"},
        init =
        [[
            game.simulation.camera_position = {0, 0.5}

            for _, force in pairs(game.forces) do
                force.inserter_stack_size_bonus = 7
                force.bulk_inserter_capacity_bonus = 7
            end

            --game.surfaces[1].create_entity{ name = "rci-rocketizer", position = {1,1}, raise_built = true, }
            --Need to make a demo sprite on top of an infinity chest, because the scripts won't work in a sim.
            rendering.draw_sprite{
                sprite="rubia-rocketizer-demo-sprite",
                target={1.5,1.4},
                surface=game.surfaces[1],
                render_layer = "cargo-hatch",
                x_scale = 1, y_scale = 1,
            } 

            game.surfaces[1].create_entities_from_blueprint_string
            {
            string = "0eNrNWdty2yAQ/ReepYxuSODnfkFfOx2PLK9TJjJSAaV1M/73IiuxHAc8yJvONG9BcM6eXZZd8AvZtAP0SkhDVi9ENJ3UZPXthWjxKOt2HJP1HsiKqEbEqmuewIg/oMgxIkJu4TdZpcfvEQFphBEwrT39c1jLYb+xM1dp9IYh5E5I+ylufoA2JCJ9p+2yTo48Fiqm1QONyMGuyar0gZ5IpiVrDcYI+ajHqQr23TOsB/utNaBguxYG9vbTrm41RGQanox5pW67X/EWpB7ZtVFDYwYF1oKmG0bpNInIvtuOM2sTt1CfzJsVHo/RB13ZWdfOTo/brt7aYYeo8r2krVDQTBOKiJhDP0J0g+kHQxw0+Xsao2qp+06ZeAOt04fFtQ8vCR0ExZnA+mTTBTDkNxiYg4EulZDdIEgzB0MZGov0Bm5AMKrwvVzwf7WXpzSMdwO08w7O7tjBbGlcLgKfhwSeIwIfRJAmV5tX960wxh37/A06C4Kezy09bLSpT1MdcWZnWJeP0/mYgNbyKdHEIEE9HmJ76ILa1Q24UMsZNSKbYbcDtdb26B01n/9cfDkiqEWQYwoEAw1iwBwYYRpKBEOYhgrhpTKIAZO+VRADJn+DNGQJgiFIQzan8WZon2zSaVCeA+KicvKQyplliAiwIOtzhH/CGAoEAw9ioAgvhTGU4TFOb2A7W4tsTuTXwqtF27mg54LPpgpjgUV/sbCv1ah3Gl7/HGpbq+x8Iju1t822i5yFK5vjwvIwZfz+wJwoXN1qsqDbT68tXtYh2TYenDakgRErys+PWJ7dc94wGnLe5IjazgpPwBD5f7LahYnIeC/mXTn+0a/OTMgRxZpVHoMZwrE+TERBZqUbs0gQ2n2YKQKTezARxZYxDyaivHoxMQnl045oiHniwUS0wDz1YCLyyGsnos312skXVKm5SPD8U+/xvS0yoLVFiAeLN9/l7Q1v+WWeJqFvIFdyFr5H0RSxbzJ3PCgit72YiNzmnu6GIq6+Xkwa9s5wfrrizncGWt71zkDfXi94seydgVb3pVDxP6cQW5xCxV0phCjj3NPHlYgy7lAxPuqP3h/brfMvBBFpa4tmx76efwn4YoNmPzzbwJxW0tLCcU6rJKPVuFX/Ap1g86w=",
            position = {0, 1}
            }
        ]]
    },
},
{
    type = "sprite",
    name = "rubia-rocketizer-demo-sprite",
    layers = util.table.deepcopy(data.raw["proxy-container"]["rci-rocketizer"].picture.layers),
},


{
    type = "tips-and-tricks-item",
    name = "rubia-garbo-grabber-tips",
    category = "space-age",
    tag = "[entity=garbo-grabber]",
    indent = 1,
    order = "g-a-f",
    trigger = {
      type = "research",
      technology = "craptonite-processing",
    },
    dependencies = {"rubia-briefing"},
    simulation =
    {
        planet = "rubia",
        mods = {"rubia"},
        init_update_count = 380,
        init =
        [[
            local rubia_surface = game.surfaces[1]--game.create_surface("rubia")
            game.simulation.camera_position = {0, 0.5}
            game.simulation.camera_surface_index = rubia_surface.index

            for _, force in pairs(game.forces) do
                force.inserter_stack_size_bonus = 3
                force.bulk_inserter_capacity_bonus = 3
                force.set_turret_attack_modifier("gun-turret", 1.5)
            end

            rubia_surface.create_entities_from_blueprint_string
            {
            string = "0eNqdlttuozAQhl+l8jWusDkkcF2pD7GqIkMG1hIY5EO1aZR3XxtKjo5EzB2e8fd7ZjwaH1HVGRglFxqVR8TrQShU/jkixVvBOrcmWA+oRC2T1YBbyaoKJDpFiIs9/EMlOUUeby2ZUOMgNa6g01fu9PQVIRCaaw6z0vRz2AnTO3BJooXRMKUxFwqktoYIjYOyuwbhZCxp855F6IDK4j2z+D2XUM9WQt2R7rD0Fnt3vgd4fgX30JIzjYuGC2vC9V9QHtD25pSL906B1ly0ynlJ6Idv2Blr62yksN9xDb01aWnAp56uVsdLHCQO0G9YpyBC8/JcrCWHNttM9rhnLfvhAqxyPRh3h0gcR6gf9s6LadwBm851vixfvoCy2+J0A9v7Ko5vYrmquE2IPoxu/2D0aNx9e9DIX7sAOFkyR+7Vth76JpQer6Fvz3TorJ/kNQYBsj3Y9rClaVgNjxrxr4DFV6ZpQO4U/4GpQsvnkSrOUspUSrMJ+MCmC9tDIHFYq02p8PFIII884dHQWiVrakWSUDxdhU8Ds0GfZCML5CVPeMF9lq0KP7jR0lX47drpg+nTc3vnDyleJ6frJtul31ojsDZSgi8T5BfqqxoN7bHUfwto4LidkunjJS/FmHsZl865fcs8YJKZsvFSsrV1zJaY8nVlzANT5vDuUeWGtt18ec9FqGN2r137dPG+fc7xvn3YeW+N33amT7gsp0VaFNkmptmmoKfTf8x+VEY=",
            position = {0, -2}
            }

            --Rubia script loading
            rubia = require "__rubia__.lib.constants"
            require("__rubia__.lib.lib")
            require("__rubia__.lib.control-stage")
            local trashsteroid_lib = require("__rubia__.script.trashsteroid-spawning")
            trashsteroid_lib.hard_refresh()

            --Spawn trashsteroid
            local function spawn_trashsteroid()
                local desired_position = {-13,0}
                local x, y = desired_position[1], desired_position[2]
                --Make it
                local resulting_entity = rubia_surface.create_entity({
                    name = "medium-trashsteroid",
                    position = {x, y},
                    force = "enemy",
                    direction = defines.direction.east,
                    snap_to_grid = false,
                    create_build_effect_smoke = false
                })
                resulting_entity.speed = 0.13 * (1 + math.random(-10,10)/100)
                resulting_entity.orientation = math.random(20,30) / 100

                --Add a rendering to be able to see it, as it moves somewhat independently
                local trasteroid_render_no = tostring(math.random(1,6))
                local render = rendering.draw_animation({
                    animation = "medium-trashsteroid-animation" .. trasteroid_render_no,
                    orientation=math.random(1,100) / 100,
                    render_layer="air-object",
                    xscale = 1.5, yscale = 1.5,
                    target=resulting_entity,
                    surface=rubia_surface,
                })
            end

            script.on_nth_tick(120, spawn_trashsteroid)
            script.on_event(defines.events.on_entity_died, function(event)
                trashsteroid_lib.on_med_trashsteroid_killed(event.entity, event.damage_type)
            end, {{filter = "name", name = "medium-trashsteroid"}})
        ]]
    },
},

{
    type = "tips-and-tricks-item",
    name = "rubia-craptonite-wall-tips",
    category = "space-age",
    tag = "[entity=craptonite-wall]",
    indent = 1,
    order = "g-a-h",
    trigger = {
      type = "research",
      technology = "craptonite-wall",
    },
    dependencies = {"rubia-briefing"},
    simulation =
    {
        planet = "rubia",
        mods = {"rubia"},
        init_update_count = 0,
        init =
        [[
            local rubia_surface = game.surfaces[1]--game.create_surface("rubia")
            game.simulation.camera_position = {0, 0.5}
            game.simulation.camera_surface_index = rubia_surface.index

            rubia_surface.create_entities_from_blueprint_string
            {
            string = "0eNqd0kEOgyAQBdC7zBqNRVHhKk3TqCUNiQ4GsK0x3L1oF12UbljOZP6bzd+gHxc5G4UOxAZq0GhBnDew6o7duO+wmyQIGEw3O43KyezZjSN4Agpv8gXi5C8EJDrllPyEj2G94jL10oQD8g8hMGsbchr3T8HKipwRWEHQMmfekx+Lplg0bpUpFotbVYpVxS2WYjVxq06x6rjVpFg8brUpVrtboWzhdgrJb3UJPKSxR4TVlFecs6agrOHU+zc36PGk",
            position = {0, -2}
            }

            --Rubia script loading
            rubia = require "__rubia__.lib.constants"
            require("__rubia__.lib.lib")
            require("__rubia__.lib.control-stage")
            local trashsteroid_lib = require("__rubia__.script.trashsteroid-spawning")
            trashsteroid_lib.hard_refresh()

            --Spawn trashsteroid
            local active_trashsteroids = {}
            local function spawn_trashsteroid(desired_position)
                local x, y = desired_position[1], desired_position[2]
                --Make it
                local resulting_entity = rubia_surface.create_entity({
                    name = "medium-trashsteroid",
                    position = {x, y},
                    force = "enemy",
                    direction = defines.direction.east,
                    snap_to_grid = false,
                    create_build_effect_smoke = false
                })
                resulting_entity.speed = 0.13 * (1 + math.random(-10,10)/100)
                resulting_entity.orientation = math.random(23,27) / 100

                --Add a rendering to be able to see it, as it moves somewhat independently
                local trasteroid_render_no = tostring(math.random(1,6))
                local render = rendering.draw_animation({
                    animation = "medium-trashsteroid-animation" .. trasteroid_render_no,
                    orientation=math.random(1,100) / 100,
                    render_layer="air-object",
                    xscale = 1, yscale = 1,
                    target=resulting_entity,
                    surface=rubia_surface,
                })

                table.insert(active_trashsteroids, resulting_entity)
            end

            local desired_positions = {{-13,0},{-13,5}, {-16,3}, {-13,-2}, {-17, -3}}
            local function trashsteroid_update()
                for _, entry in pairs(active_trashsteroids) do
                    if entry.valid then entry.die() end
                end
                active_trashsteroids = {}

                for _, entry in pairs(desired_positions) do
                    spawn_trashsteroid(entry)
                end
            end

            script.on_nth_tick(300, trashsteroid_update)
        ]]
    },
},

}

--string = "0eNqd0kEOgyAQBdC7zBqNRVHhKk3TqCUNiQ4GsK0x3L1oF12UbljOZP6bzd+gHxc5G4UOxAZq0GhBnDew6o7duO+wmyQIGEw3O43KyezZjSN4Agpv8gXi5C8EJDrllPyEj2G94jL10oQD8g8hMGsbchr3T8HKipwRWEHQMmfekx+Lplg0bpUpFotbVYpVxS2WYjVxq06x6rjVpFg8brUpVrtboWzhdgrJb3UJPKSxR4TVlFecs6agrOHU+zc36PGk",