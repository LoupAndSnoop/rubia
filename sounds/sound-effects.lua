--This file defines sound prototypes we might need, as well as
-- modifies prototypes from the base game.

--I need to change this sound, because otherwise trashsteroids spam this all over the planet!
data.raw["utility-sounds"]["default"].default_driving_sound.sound.volume = 0.6 * 0.2

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