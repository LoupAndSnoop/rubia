--Correct all wind turbines.
if not storage.rubia_surface then return end --Rubia has no surface yet.

local wind_turbine = require("__rubia__/script/wind-turbine-control")
wind_turbine.hard_refresh_all_turbines()