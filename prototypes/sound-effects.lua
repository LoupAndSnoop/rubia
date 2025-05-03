--This file defines sound prototypes we might need, as well as
-- modifies prototypes from the base game.

--I need to change this sound, because otherwise trashsteroids spam this all over the planet!
data.raw["utility-sounds"]["default"].default_driving_sound.sound.volume = 0.6 * 0.1
--   /c game.print(helpers.is_valid_sound_path( ))

--Return a simple sound object with standardized settings for cutscene
local std_cutscene_sound = function(path, volume)
  return {filename = path, volume=volume or 1,
  --min_volume=0.01, 
  min_speed=0.5, max_speed = 3,}
end
--Standard sound for SFX
local std_sfx_sound = function(path, volume)
  return {filename = path, volume=volume or 1,
  min_speed=0.7, max_speed = 1.3,}
end


data:extend({

  {
    type = "sound",
    name = "rubia-wind-short1",
    variations = {
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-1.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-2.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-3.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-4.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-5.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-6.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-7.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-8.ogg"),
      std_sfx_sound("__rubia__/sounds/wind/loup-wind-9.ogg"),
    }
  },


  --#region Cutscene
  {
    type = "sound",
    name = "rubia-cutscene-crash",
    priority = 0,
    filename = "__base__/sound/car-crash.ogg",
    --min_volume=0.3, max_volume=0.7,
  },
  {
    type = "sound",
    name = "rubia-cutscene-alert",
    priority = 15,
    filename = "__core__/sound/alert-destroyed.ogg",
  },
  {
    type = "sound",
    name = "rubia-cutscene-siren1",
    priority = 5,
    filename = "__rubia__/sounds/alarm-siren-sound-effect-type-01-ribhav-agrawal-trim.ogg",
  },
  {
    type = "sound",
    name = "rubia-cutscene-siren2",
    priority = 6,
    filename = "__rubia__/sounds/alarm-siren-sound-effect-type-03-ribhav-agrawal-trim.ogg",
  },
  {
    type = "sound",
    name = "rubia-cutscene-siren3",
    priority = 7,
    filename = "__rubia__/sounds/facility-siren-loopable-freesound.ogg",
  },
  {
    type = "sound",
    name = "rubia-cutscene-fizzle",
    priority = 50,
    filename = "__base__/sound/car-engine-stop.ogg",
  },
  --[[{
    type = "sound",
    name = "rubia-cutscene-null",
    priority = 1,
    filename = "__base__/sound/bullets/bullet-impact-metal-large-1.ogg",
    speed=100, volume = 0.0001,
  },]]
  {
    type = "sound",
    name = "rubia-cutscene-metal-impact",
    variations = {
      std_cutscene_sound("__base__/sound/car-metal-impact-1.ogg",0.5),
      std_cutscene_sound("__base__/sound/car-metal-impact-2.ogg",0.8),
      std_cutscene_sound("__base__/sound/car-metal-impact-3.ogg",0.6),
      std_cutscene_sound("__base__/sound/car-metal-impact-4.ogg",0.7),
      std_cutscene_sound("__base__/sound/car-metal-impact-5.ogg",0.5),
      std_cutscene_sound("__base__/sound/car-metal-impact-6.ogg",0.5),
    }
  },
  {
    type = "sound",
    name = "rubia-cutscene-large-impact",
    variations = {
      std_cutscene_sound("__base__/sound/car-metal-large-impact-1.ogg"),
      std_cutscene_sound("__base__/sound/car-metal-large-impact-2.ogg"),
      std_cutscene_sound("__base__/sound/car-metal-large-impact-3.ogg"),
      std_cutscene_sound("__base__/sound/car-metal-large-impact-4.ogg"),
      std_cutscene_sound("__base__/sound/car-metal-large-impact-5.ogg"),
    }
  },
  {
    type = "sound",
    name = "rubia-cutscene-longer-woosh",
    variations = {
      std_cutscene_sound("__base__/sound/particles/car-debris-3.ogg"),
      std_cutscene_sound("__base__/sound/particles/car-debris-5.ogg"),
    }
  },
  {
    type = "sound",
    name = "rubia-cutscene-bullet-impact",
    variations = {
      std_cutscene_sound("__base__/sound/bullets/bullet-impact-metal-large-1.ogg"),
      std_cutscene_sound("__base__/sound/bullets/bullet-impact-metal-large-2.ogg"),
      std_cutscene_sound("__base__/sound/bullets/bullet-impact-metal-large-3.ogg"),
      std_cutscene_sound("__base__/sound/bullets/bullet-impact-metal-large-4.ogg"),
      std_cutscene_sound("__base__/sound/bullets/bullet-impact-metal-large-5.ogg"),
    }
  },
  --#endregion
})

--[[data.raw["utility-sounds"]["default"].default_driving_sound = {
  sound =
    {
      filename = "__core__/sound/vehicle-surface-default.ogg",
      volume = 0.6 * 0.2,
      advanced_volume_control = {fades = {fade_in = 
        {curve_type = "cosine", from = {control = 0.5, volume_percentage = 0.0}, to = {1.5, 100.0}}}}
    },
    fade_ticks = 6
}]]