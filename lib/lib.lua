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

--Helper functions
_G.rubia_lib = {}



-----Helper functions to load entity data files.
--Concatenate all the subtables in a table
rubia_lib.table_concat = function(big_table)
local function table_concat_pair(t1,t2)
        for i=1,#t2 do
            t1[#t1+1] = t2[i]
        end
        return t1
    end

    local result = {}
    for i=1,#big_table do
        result = table_concat_pair(result, big_table[i])
    end
    return result
end

-- Get multiple sprites from a spritesheet.
rubia_lib.spritesheet_variations = function(count, line_length, base)
    local variations = {}
    for i = 1, count do
      local new = table.deepcopy(base)
      new.x = ((i-1) % line_length) * base.width
      new.y = math.floor((i-1) / line_length) * base.height
      table.insert(variations, new)
    end
    return variations
end
