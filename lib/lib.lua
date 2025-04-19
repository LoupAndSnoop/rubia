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
_G.rubia_lib = _G.rubia_lib or {}



-----Helper functions to load entity data files.

---#region Basic table manipulation
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

--Merge 2 tables, making a new table that gives priority to entries in the new table.
rubia_lib.merge = function(old, new)
	old = util.table.deepcopy(old)

	for k, v in pairs(new) do
		if v == "nil" then old[k] = nil
		else old[k] = v end
	end

	return old
end

--Return an array of all keys in the table where the 
--filter_condition(the corresponding value) is true. This array may be empty
rubia_lib.get_filtered_table = function(input_table, filter_condition)
  local found_keys = {}
  for key, value in pairs(input_table) do
    if filter_condition(value) then _G.table.insert(found_keys, key) end
  end
  return found_keys
end

--If the input array contains the given value, return the index of that value (=true!)
--Otherwise, output false
rubia_lib.array_find = function(array, value)
  for index, val in pairs(array) do
    if val == value then return index end
  end
  return false
end

--If the input array contains a value such that check(value) = true, 
--then return its index (=true!) Otherwise, output false
rubia_lib.array_find_condition = function(array, condition)
  for index, val in pairs(array) do
    if condition(val) then return index end
  end
  return false
end

--Array goes in, out comes a hashset where hashset[value]=1 
--for all entries in the old array.
rubia_lib.array_to_hashset = function(array)
  local hashset = {}
  for _, value in pairs(array) do
    hashset[value]=1
  end
  return hashset
end

--[[Go through all entries in the input table OR array, and for any keys where
--filter_condtion(input_table[key]) is true, set input_table[key] = operation(input_table[key])
rubia_lib.operate_on_filtered_table = function(input_table, filter_condition, operation)
  for key, value in pairs(input_table) do
    if filter_condition(value) then input_table[key] = operation[key] end
  end
end]]
--#endregion

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

