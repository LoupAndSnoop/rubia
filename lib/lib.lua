--[[require "table"
require "string"
require "defines"
require "color"
]]
if data and data.raw and not data.raw.item["iron-plate"] then
    rubia.stage = "settings"
elseif data and data.raw then
    rubia.stage = "data"
    require "data-stage"
elseif script then
    rubia.stage = "control"
    require "control-stage"
else
    error("Could not determine load order stage.")
end
