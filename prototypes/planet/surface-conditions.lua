
----- Defining the wind speed surface condition
data:extend({
  {
    type = "surface-property",
    name = "rubia-wind-speed",
    default_value = 6.9,
    order = "r[rubia]-a",
  }
})

--Additional wind speeds for flavor
local function set_wind_speed(planet_name,speed)
  if (data.raw["planet"][planet_name]) then 
    data.raw["planet"][planet_name].surface_properties["rubia-wind-speed"] = speed end
end
set_wind_speed("rubia", 300)
set_wind_speed("nauvis", 15)
set_wind_speed("fulgora", 35)
set_wind_speed("vulcanus", 80)
set_wind_speed("gleba", 5)
set_wind_speed("aquilo", 30)

--Others
set_wind_speed("maraxsis", 0)
set_wind_speed("corrundum", 30)
set_wind_speed("moshine", 40)
set_wind_speed("cubium", 10)
set_wind_speed("muluna", 0)
set_wind_speed("cerys", 5)
set_wind_speed("jahtra", 25)
set_wind_speed("tenebris", 60)


-- Asteroid surface condition
----- Defining the wind speed surface condition
data:extend({
  {
    type = "surface-property",
    name = "rubia-asteroid-density",
    default_value = 0,
    order = "r[rubia]-b",
  }
})
local function set_asteroid_density(planet_name, asteroid_density)
  if (data.raw["planet"][planet_name]) then 
    data.raw["planet"][planet_name].surface_properties["rubia-asteroid-density"] = asteroid_density end
end
data.raw["surface"]["space-platform"].surface_properties["rubia-asteroid-density"] = 10
set_asteroid_density("cerys", 5)
set_asteroid_density("rubia", 30)