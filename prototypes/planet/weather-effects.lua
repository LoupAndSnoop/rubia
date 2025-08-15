--Derrived from Celestial weather mod

rubia_effects = {}
data.extend({
{ --Based on aquilo snow smoke
    type = "trivial-smoke",
    name = "rubia-sand",
    duration = 200,
    fade_in_duration = 40,
    fade_away_duration = 60,
    spread_duration= 60,
    start_scale = 1,
    end_scale = 1,
    color = {1,1,1,1},--{0.3, 0.255, 0.424, 1},--{1, 0.855, 0.624},
    cyclic = true,
    affected_by_wind = true,
    --movement_slow_down_factor = 0.0001,
    animation =
    {
      width = 64,
      height = 64,
      line_length = 16,
      frame_count = 16,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.0001,
      filename = "__rubia-assets__/graphics/terrain/rubia-sand-particles.png",
      flags = { "smoke" }
    },
    --vertical_speed_slowdown = 0.001
  },
})

local cluster_particles = {
    type = "cluster",
    distance = 8,
    distance_deviation = 8,
    cluster_count = 10,

    action_delivery = {
        type = "instant",
        source_effects = {
            type = "create-trivial-smoke",
            initial_height = 0.6,
            speed_multiplier_deviation = 0.8,
            starting_frame = 512,
            starting_frame_deviation = 1024,
            offset_deviation = {{-96, -48}, {96, 48}},
            speed_from_center = 0,
            speed_from_center_deviation = 0,

            smoke_name= "rubia-sand",
            speed = {0.3,0},--{0.4, 0},
            speed_multiplier = 2,
            --probability = 0.5,
        }
    }
}
table.insert(rubia_effects, cluster_particles)

assert(data.raw["planet"]["rubia"], "Rubia prototype is not defined yet, or has been removed!")
data.raw["planet"]["rubia"].ticks_between_player_effects = 1
data.raw["planet"]["rubia"].player_effects = rubia_effects
