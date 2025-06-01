--Fast-replace-groups

--[[
---Make prototype_to_match have the same fast replace group as prototype_main. If
---it has no fast replace group already, assign a new one based on that group_name
---@param prototype_main any
---@param prototype_to_match any
---@param default_group_name string
local function merge_fast_replace_groups(prototype_main, prototype_to_match, default_group_name)
  assert(prototype_main, "Prototype not found. Probably not defined yet.")
  assert(prototype_to_match, "Prototype to match not found. Probably not defined yet.")
  if (not prototype_main.fast_replaceable_group) 
    or (prototype_main.fast_replaceable_group == "") then
    prototype_main.fast_replaceable_group = default_group_name
    prototype_to_match.fast_replaceable_group = default_group_name
  else prototype_to_match.fast_replaceable_group = prototype_main.fast_replaceable_group
  end
end

merge_fast_replace_groups(data.raw["locomotive"]["locomotive"], 
  data.raw["locomotive"]["rubia-armored-locomotive"], "locomotive")
merge_fast_replace_groups(data.raw["cargo-wagon"]["cargo-wagon"], 
  data.raw["cargo-wagon"]["rubia-armored-cargo-wagon"], "cargo-wagon")
merge_fast_replace_groups(data.raw["fluid-wagon"]["fluid-wagon"], 
  data.raw["fluid-wagon"]["rubia-armored-fluid-wagon"], "fluid-wagon")
  ]]