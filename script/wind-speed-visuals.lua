--This file contains methods to control visuals for wind speed

local wind_speed_lib = {}


local base_wind_speed = 8 / 60 --Base wind speed in tile/sec
local wind_fluctuation_bound = 1 / 60 --Max wind fluctuation in tile/sec
local wind_speed_min, wind_speed_max = base_wind_speed - wind_fluctuation_bound, base_wind_speed + wind_fluctuation_bound
local wind_fluctuation_magnitude = 0.1 / 60 --Wind speed fluctuation per tick, time a uniformly distributed %

--Assign basic wind speed parameters to the surface, if possible.
wind_speed_lib.try_set_wind_speed = function()
    local surface = storage.rubia_surface
    if not surface then return end

    surface.wind_speed = base_wind_speed;
    surface.wind_orientation = 0.25;
    surface.wind_orientation_change = 0;
end

--Change the wind speed by one step. tick_period = how many ticks elapse per time we call this function
wind_speed_lib.fluctuate_wind_speed = function(tick_period)
    local surface = storage.rubia_surface
    if not surface then return end

    local target_speed = math.random(-50,50) * tick_period * wind_fluctuation_magnitude + surface.wind_speed
    --Clamp it 
    surface.wind_speed = math.min(math.max(wind_speed_min, target_speed),wind_speed_max)

    --Reorient in case try_set_wind_speed was dodged.
    surface.wind_orientation = 0.25;
    surface.wind_orientation_change = 0;
end

return wind_speed_lib