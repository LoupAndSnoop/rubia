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


--Make rotated variants from a sprite sheet. Sheet should look like this:
--[[{filename = "__base__/graphics/entity/remnants/small-remnants.png",
      line_length = 1,
      width = 112,
      height = 110,
      direction_count = 1,
      shift = util.by_pixel(0, 3.5),
      scale = 0.5
    }]]
rubia_lib.make_rotated_animation_variations_from_sheet = function(variation_count, sheet) --makes remnants work with more than 1 variation
    local result = {}
  
    local function set_y_offset(variation, i)
      local frame_count = variation.frame_count or 1
      local line_length = variation.line_length or frame_count
      if (line_length < 1) then
        line_length = frame_count
      end
  
      local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
      -- if (height_in_frames ~= 1) then
      --   log("maybe broken sheet: h=" .. height_in_frames .. ", vc=" .. variation_count .. ", " .. variation.filename)
      -- end
      variation.y = variation.height * (i - 1) * height_in_frames
    end
  
    for i = 1,variation_count do
      local variation = util.table.deepcopy(sheet)
  
      if variation.layers then
        for _, layer in pairs(variation.layers) do
          set_y_offset(layer, i)
        end
      else
        set_y_offset(variation, i)
      end
  
      table.insert(result, variation)
    end
   return result
end

