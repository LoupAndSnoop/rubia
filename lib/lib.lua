require("util")
--Helper functions
_G.rubia_lib = _G.rubia_lib or {}

--[[require "table"
require "string"
require "defines"
require "color"
]]
if data and data.raw and not data.raw.item["iron-plate"] then
    rubia.stage = "settings"
elseif data and data.raw then
    rubia.stage = "data"
    require "__rubia__/lib/data-stage"
elseif script then
    rubia.stage = "control"
    require "__rubia__/lib/control-stage"
else
    error("Could not determine load order stage.")
end





-----Helper functions to load entity data files.

---#region Basic table manipulation

--Concatenate all the sub-arrays in a table. Return the new table as a new entity.
rubia_lib.array_concat = function(big_table)
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

---Merge 2 tables, making a new table that gives priority to entries in the new table. DOES NOT
---modify existing tables. Any values of "nil" in the new table will delete entries in the final result.
---@param old any[] Initial table
---@param new any[] Merge into old table, taking priority over existing values in old.
---@return any[] A new merged table.
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

--[[Add that entry to the array, but only if nothing in the array is already == to it.
function rubia_lib.add_nonduplicate_to_array(array, entry)
  if not rubia_lib.array_find(array, entry) then table.insert(array, entry) end
end]]

--Array goes in, out comes a hashset where hashset[value]=1 
--for all entries in the old array. Naturally combines duplicates.
rubia_lib.array_to_hashset = function(array)
  local hashset = {}
  for _, value in pairs(array) do
    hashset[value]=1
  end
  return hashset
end

--[[Array goes in, out comes a dictionary where [array_entry.key_index] is the key, The other
--parts of the sub table become part of an array of the given value.
--Example {{key=a,val=1},{key=a,val=3},{key=b,val=1}},"key" => [a] = {{val=1},{val=3}}, [b]={{val=1}}
--for all entries in the old array.
rubia_lib.array_to_dictionary = function(array, key_index)

end]]

--Array goes in, where every entry is a table that contains field "indexing_field".
--Output a dictionary with each indexing_field as key, and the values
--are arrays of all_entries where the indexing field is that value, but with indexing field gone.
--Example: array_to_dictionary({{a=1,b=1},{a=1,b=2}},"a") gives: dic.a = {{b=1},{b=2}}
--The difference is that the entries will have value[indexing_field[
rubia_lib.array_to_dictionary = function(array, indexing_field)
  local dictionary = {}
  for _, entry in pairs(array) do
    local new_entry = util.table.deepcopy(entry)
    new_entry[indexing_field] = nil

    if not dictionary[entry[indexing_field]] then dictionary[entry[indexing_field]] = {new_entry}
    else table.insert(dictionary[entry[indexing_field]],new_entry)
    end
  end
end

--[[Go through all entries in the input table OR array, and for any keys where
--filter_condtion(input_table[key]) is true, set input_table[key] = operation(input_table[key])
rubia_lib.operate_on_filtered_table = function(input_table, filter_condition, operation)
  for key, value in pairs(input_table) do
    if filter_condition(value) then input_table[key] = operation[key] end
  end
end]]
--#endregion

--#region Version assistance
--From FLIB, thanks to raiguard and friends
rubia.flib = {}

local version_pattern = "%d+"
local version_format = "%02d"

--- Normalize version strings for easy comparison.
---
--- ### Examples
---
--- ```lua
--- migration.format_version("1.10.1234", "%04d")
--- migration.format_version("3", "%02d")
--- ```
--- @param version string
--- @param format string? default: `%02d`
--- @return string?
function rubia.flib.format_version(version, format)
  if version then
    format = format or version_format
    local tbl = {}
    for v in string.gmatch(version, version_pattern) do
      tbl[#tbl + 1] = string.format(format, v)
    end
    if next(tbl) then
      return table.concat(tbl, ".")
    end
  end
  return nil
end

--- True if current_version is strictly newer than old_version.
--- @param old_version string
--- @param current_version string
--- @param format string? default: `%02d`
--- @return boolean?
function rubia.flib.is_newer_version(old_version, current_version, format)
  local v1 = rubia.flib.format_version(old_version, format)
  local v2 = rubia.flib.format_version(current_version, format)
  if v1 and v2 then
    if v2 > v1 then
      return true
    end
    return false
  end
  return nil
end

log("RUBIA: Setting constant should be removed once version is set stable.")
rubia.DISABLE_TECH_HIDING = not rubia.flib.is_newer_version("2.0.53", 
  mods and mods["base"] or script.active_mods["base"])
--#endregion


--- Call the given function on a set number of items in a table, returning the next starting key.
---
--- Calls `callback(value, key)` over `n` items from `tbl` or until the end is reached, starting after `from_k`.
---
--- The first return value of each invocation of `callback` will be collected and returned in a table keyed by the
--- current item's key.
---
--- The second return value of `callback` is a flag requesting deletion of the current item.
---
--- The third return value of `callback` is a flag requesting that the iteration be immediately aborted. Use this flag to
--- early return on some condition in `callback`. When aborted, `for_n_of` will return the previous key as `from_k`, so
--- the next call to `for_n_of` will restart on the key that was aborted (unless it was also deleted).
---
--- **DO NOT** delete entires from `tbl` from within `callback`, this will break the iteration. Use the deletion flag
--- instead.
---
--- ### Examples
---
--- ```lua
--- local extremely_large_table = {
---   [1000] = 1,
---   [999] = 2,
---   [998] = 3,
---   ...,
---   [2] = 999,
---   [1] = 1000,
--- }
--- event.on_tick(function()
---   storage.from_k = table.for_n_of(extremely_large_table, storage.from_k, 10, function(v) game.print(v) end)
--- end)
--- ```
--- @generic K, V, C
--- @param tbl table<K, V> The table to iterate over.
--- @param from_k K The key to start iteration at, or `nil` to start at the beginning of `tbl`. If the key does not exist in `tbl`, it will be treated as `nil`, _unless_ a custom `_next` function is used.
--- @param n number The number of items to iterate.
--- @param callback fun(value: V, key: K):C,boolean,boolean Receives `value` and `key` as parameters.
--- @param _next? fun(tbl: table<K, V>, from_k: K):K,V A custom `next()` function. If not provided, the default `next()` will be used.
--- @return K? next_key Where the iteration ended. Can be any valid table key, or `nil`. Pass this as `from_k` in the next call to `for_n_of` for `tbl`.
--- @return table<K, C> results The results compiled from the first return of `callback`.
--- @return boolean reached_end Whether or not the end of the table was reached on this iteration.
function rubia.flib.for_n_of(tbl, from_k, n, callback, _next)
  -- Bypass if a custom `next` function was provided
  if not _next then
    -- Verify start key exists, else start from scratch
    if from_k and not tbl[from_k] then
      from_k = nil
    end
    -- Use default `next`
    _next = next
  end

  local delete
  local prev
  local abort
  local result = {}

  -- Run `n` times
  for _ = 1, n, 1 do
    local v
    if not delete then
      prev = from_k
    end
    from_k, v = _next(tbl, from_k)
    if delete then
      tbl[delete] = nil
    end

    if from_k then
      result[from_k], delete, abort = callback(v, from_k)
      if delete then
        delete = from_k
      end
      if abort then
        break
      end
    else
      return from_k, result, true
    end
  end

  if delete then
    tbl[delete] = nil
    from_k = prev
  elseif abort then
    from_k = prev
  end
  return from_k, result, false
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



--Technology searching

--[[Make a dictionary of: "tech name" => {names of all its children}
rubia_lib.make_child_tech_dictionary = function()
  local prototype_list = {}
  if rubia.stage == "data" then prototype_list = data.raw["technology"]
  elseif rubia.stage == "control" then prototype_list = prototypes.technology
  else error("This function should not be called outside data stage or control stage.")
  end

end]]
