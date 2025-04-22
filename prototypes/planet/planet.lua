local planet_map_gen = require("__rubia__.prototypes.planet.rubia-map-gen")
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local planet_catalogue_rubia = require("__rubia__.prototypes.planet.procession-catalogue-rubia")

--local planet_map_gen = require("__rubia__/planet/rubia-map-gen")

----- Defining the wind speed surface condition
data:extend({
  {
    type = "surface-property",
    name = "rubia-wind-speed",
    default_value = 6.9
  }
})

--Additional wind speeds for flavor
local function set_wind_speed(planet_name,speed)
  if (data.raw["planet"][planet_name]) then 
    data.raw["planet"][planet_name].surface_properties["rubia-wind-speed"] = speed end
  end
set_wind_speed("nauvis", 15)
set_wind_speed("fulgora", 35)
set_wind_speed("vulcanus", 80)
set_wind_speed("gleba", 5)
set_wind_speed("aquilo", 30)

    --data.raw["planet-nauvis"].surface_properties["wind-speed"] = 5
--rubia.surface_conditions() = function () {}end

--------Basic Map generation

local planet = {
  {
        type = "planet",
        name = "rubia",
        icon = "__rubia__/graphics/icons/rubia-icon.png",
        starmap_icon = "__rubia__/graphics/icons/starmap-planet-rubia.png",
        starmap_icon_size = 512,
        gravity_pull = 10,
        distance = 15,
        orientation = 0.05,
        magnitude = 1.4,
        label_orientation = 0.15,
        order = "k[rubia]",
        subgroup = "planets",
        map_gen_settings = planet_map_gen.rubia(), 
        pollutant_type = nil,
        solar_power_in_space = 200,
        platform_procession_set =
        {
          arrival = {"planet-to-platform-b"},
          departure = {"platform-to-planet-a"}
        },
        planet_procession_set =
        {
          arrival = {"platform-to-planet-b"},
          departure = {"planet-to-platform-a"}
        },
        procession_graphic_catalogue = planet_catalogue_rubia,
        surface_properties =
        {
          ["day-night-cycle"] = 1.5 * minute,
          ["magnetic-field"] = 10,
          ["solar-power"] = 5,
          pressure = 50,
          gravity = 2,
          ["rubia-wind-speed"] = 200
        },

        surface_render_parameters =
        {
          clouds =
          {
            shape_noise_texture =
            {
              filename = "__core__/graphics/clouds-noise.png",
              size = 2048
            },
            detail_noise_texture =
            {
              filename = "__core__/graphics/clouds-detail-noise.png",
              size = 2048
            },
    
            warp_sample_1 = { scale = 0.8 / 16 },
            warp_sample_2 = { scale = 3.75 * 0.8 / 32, wind_speed_factor = 0 },
            warped_shape_sample = { scale = 2 * 0.18 / 32 },
            additional_density_sample = { scale = 1.5 * 0.18 / 32, wind_speed_factor = 1.77 },
            detail_sample_1 = { scale = 1.709 / 32, wind_speed_factor = 0.2 / 1.709 },
            detail_sample_2 = { scale = 2.179 / 32, wind_speed_factor = 0.33 / 2.179 },
    
            scale = 1,
            movement_speed_multiplier = 0.75,
            opacity = 0.25,
            opacity_at_night = 0.25,
            density_at_night = 1,
            detail_factor = 1.5,
            detail_factor_at_night = 2,
            shape_warp_strength = 0.06,
            shape_warp_weight = 0.4,
            detail_sample_morph_duration = 0,
          },
    
          -- Should be based on the default day/night times, ie
          -- sun starts to set at 0.25
          -- sun fully set at 0.45
          -- sun starts to rise at 0.55
          -- sun fully risen at 0.75
          -- On fulgora night looks a bit longer to look right with the lightning.
          --[[day_night_cycle_color_lookup =
          {
            {0.0, "__space-age__/graphics/lut/fulgora-1-noon.png"},
            {0.2, "__space-age__/graphics/lut/fulgora-1-noon.png"},
            {0.3, "__space-age__/graphics/lut/fulgora-2-afternoon.png"},
            {0.4, "__space-age__/graphics/lut/vulcanus-2-night.png"},
            {0.6, "__space-age__/graphics/lut/vulcanus-2-night.png"},
            {0.7, "__space-age__/graphics/lut/vulcanus-1-day.png"},
          },]]
          day_night_cycle_color_lookup =
          {
            {0.7, "__rubia__/graphics/terrain/rubia-day.png"},
            {0.4, "__rubia__/graphics/terrain/rubia-night.png"},
          },

          terrain_tint_effect =
          {
            noise_texture =
            {
              filename = "__space-age__/graphics/terrain/vulcanus/tint-noise.png",
              size = 4096
            },
    
            offset = { 0.6, 0, 0.4, 0.8 },--{ 0.2, 0, 0.4, 0.8 },
            intensity = { 0.2, 0.4, 0.3, 0.25 },
            scale_u = { 1.85, 1.85, 1.85, 1.85 },
            scale_v = { 1, 1, 1, 1 },
    
            global_intensity = 0.3,
            global_scale = 0.25,
            zoom_factor = 3.8,
            zoom_intensity = 0.75
          }
        },
        asteroid_spawn_influence = 1,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_fulgora, 0.9),
        persistent_ambient_sounds =
        {
          base_ambience = {filename = "__space-age__/sound/wind/base-wind-fulgora.ogg", volume = 0.5},
          wind = {filename = "__space-age__/sound/wind/wind-fulgora.ogg", volume = 0.8},
          crossfade =
          {
            order = {"wind", "base_ambience"},
            curve_type = "cosine",
            from = {control = 0.35, volume_percentage = 0.0},
            to = {control = 2, volume_percentage = 100.0}
          },
          semi_persistent =
          {
            {
              sound = {variations = sound_variations("__space-age__/sound/world/semi-persistent/distant-thunder", 4, 0.6)},
              delay_mean_seconds = 33,
              delay_variance_seconds = 7
            },
            {
              sound =
              {
                variations = sound_variations("__space-age__/sound/world/semi-persistent/sand-wind-gust", 5, 0.45),
                advanced_volume_control =
                {
                  fades = {fade_in = {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0}}}
                }
              },
              delay_mean_seconds = 15,
              delay_variance_seconds = 9,
            },
          }
        }
      },
      -------------------------------------------------------------------------- PLANET CONNECTIONS
      {
        type = "space-connection",
        name = "vulcanus-rubia",
        subgroup = "planet-connections",
        from = "vulcanus",
        to = "rubia",
        order = "d1",
        length = 10000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
      },
      {
        type = "space-connection",
        name = "gleba-rubia",
        subgroup = "planet-connections",
        from = "gleba",
        to = "rubia",
        order = "f2",
        length = 15000,
        asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
      }
}

--Add path to corrundum, if it exists
if mods["corrundum"] then
  table.insert(planet, {
    type = "space-connection",
    name = "corrundum-rubia",
    subgroup = "planet-connections",
    from = "gleba",
    to = "rubia",
    order = "f2",
    length = 5000,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
  })
end


data:extend(planet)