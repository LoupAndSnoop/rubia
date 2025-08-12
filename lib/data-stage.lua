--Helper functions for use in the data stage
_G.rubia_lib = _G.rubia_lib or {}

--Return surface conditions for something that forces that item/recipe to Rubia only.
rubia.surface_conditions = function()
    return {{property = "rubia-wind-speed", min = 300, max = 300,}}
end
---Surface condition for NOT Rubia.
---@return table<uint,data.SurfaceCondition>
local function surface_conditions_not_rubia()
    return {{property = "rubia-wind-speed", max = 100,}}
end
---Give a table of surface conditions to denote: Rubia OR space (or other places with rocks)
rubia.surface_conditions_any_asteroids = function()
    return {{property = "rubia-asteroid-density", min = 10}}--, max = 300,}}
end


---Take in an EntityPrototype, and ADD surface conditions to it to ban it from Rubia. 
---This takes in the prototype by reference to modify it, with no return.
---@param prototype data.EntityPrototype | data.RecipePrototype
rubia.ban_from_rubia = function(prototype)
    assert(prototype, "Trying to ban nil from Rubia!")

    local function rubia_condition()
        return surface_conditions_not_rubia()[1]
    end
    --log("Banning from Rubia: " .. prototype.name)
    --This needs to be made separately, because different prototypes might refer to the same object.

    if (not prototype.surface_conditions or #prototype.surface_conditions == 0) then
        prototype.surface_conditions = {rubia_condition()}
    else
        --We need to make a brand new object this because some prototypes all refer to one common object.
        prototype.surface_conditions = util.table.deepcopy(prototype.surface_conditions)

        --Check if the prototype has wind speed already defined. If it does, update it
        for i, condition in pairs(prototype.surface_conditions) do
            if condition.property == "rubia-wind-speed" then
                prototype.surface_conditions[i] = rubia_condition()
                return
            end
        end
        --No dupes found, just add it in.
        prototype.surface_conditions[#prototype.surface_conditions + 1] = rubia_condition()
        --table.insert(prototype.surface_conditions, rubia_condition())
        --log("added manually" .. prototype.name)
    end
end

-- Recursive function to ensure all strings are within 20 units.
-- Factorio crashes if a localised string is greater than 20 units
-- Credit to notnotmelon from maraxsis
rubia.shorten_localised_string = function(localised_string)
    if table_size(localised_string) <= 20 then return localised_string end

    local first_half = {}
    local second_half = {}
    local midway_point = math.ceil(table_size(localised_string) / 2)

    for i, v in ipairs(localised_string) do
        if i <= midway_point then
            if not next(first_half) and v ~= "" then first_half[#first_half + 1] = "" end
            first_half[#first_half + 1] = v
        else
            if not next(second_half) and v ~= "" then second_half[#second_half + 1] = "" end
            second_half[#second_half + 1] = v
        end
    end

    return {"", rubia.shorten_localised_string(first_half), rubia.shorten_localised_string(second_half)}
end



local function get_prototype(base_type, name)
    for type_name in pairs(defines.prototypes[base_type]) do
      local prototypes = data.raw[type_name]
      if prototypes and prototypes[name] then
        return prototypes[name]
      end
    end
  end
--Lifted from recycler code. Get the localised name of a given item
rubia.get_item_localised_name = function(name)
    local item = get_prototype("item", name)
    if not item then return end
    if item.localised_name then
        return item.localised_name
    end
    local prototype
    local type_name = "item"
    if item.place_result then
        prototype = get_prototype("entity", item.place_result)
        type_name = "entity"
    elseif item.place_as_equipment_result then
        prototype = get_prototype("equipment", item.place_as_equipment_result)
        type_name = "equipment"
    elseif item.place_as_tile then
        -- Tiles with variations don't have a localised name
        local tile_prototype = data.raw.tile[item.place_as_tile.result]
        if tile_prototype and tile_prototype.localised_name then
        prototype = tile_prototype
        type_name = "tile"
        end
    end
    return prototype and prototype.localised_name or {type_name.."-name."..name}
end



local tech_search_blacklist = {}
--Determine if the technology is a (distant) prerequisite of the other. Return true if yes.
--Pass in as the names of technology prototype.
local function technology_is_prerequisite_internal(potential_parent, potential_dependent, recursion_depth)
    --Go get the technology prototypes
    local parent = data.raw.technology[potential_parent]
    local child = data.raw.technology[potential_dependent]
    --If string, go get the technology prototype. Else, assume it is a technology prototype.
    --local parent = (type(potential_parent) == type("a")) and data.raw.technology[potential_parent] or potential_parent
    --local child = (type(potential_dependent) == type("a")) and data.raw.technology[potential_dependent] or potential_dependent
    if not parent or not child then return false end --Those techs were not found.
    if not child.prerequisites then return false end --No prerequisites
    
    if recursion_depth == 0 then tech_search_blacklist = {} end --Clear the blacklist for a new search
    if tech_search_blacklist[potential_dependent] then return false end --This prereq actually leads to an infinite loop!

    for _, prereq in pairs(child.prerequisites) do
        if prereq == potential_parent then return true end --We found the prerequisite
        
        --Safeguard against stack overflow
        if recursion_depth > 50000 then
            log("WARNING: Technology tree depth is way too long on this technology: " .. potential_dependent)
            tech_search_blacklist[prereq] = true --This is in the loop, we need to block it.
            if recursion_depth > 55000 then return false end --Emergency failsafe break.
        end
        if technology_is_prerequisite_internal(potential_parent, prereq, recursion_depth + 1) then return true end
    end

    return false --No connection found
end
--Determine if the technology is a (distant) prerequisite of the other. Return true if yes.
--Pass in as the names of technology prototype
function rubia_lib.technology_is_prerequisite(potential_parent, potential_dependent)
    return technology_is_prerequisite_internal(potential_parent, potential_dependent, 0)
end 


---Technology name goes in. Out comes an array of technology names that currently list that tech as a prerequisite.
---@param tech_name string
---@return string[] children
function rubia_lib.get_child_technologies(tech_name)
    assert(data.raw.technology[tech_name], "Invalid technology name: " .. tech_name)

	local children = {}
	for _, tech in pairs(data.raw.technology) do
        --log("Checking to hide: " .. tech.name)--serpent.block(tech))
        if tech.prerequisites and (type(tech.prerequisites) == type("s")) then return {} end --RJDunlap didn't fix his Tapatrion mod >:(

        if tech.prerequisites then
			for _, prereq in ipairs(tech.prerequisites or {}) do
				if prereq == tech_name then
					table.insert(children, tech.name)
					break
				end
			end
		end
	end
	return children
end


--#region Quick recipe/tech alterations for compatibility
rubia_lib.compat = rubia_lib.compat or {}

---Given a specific recipe name, set the given input item to the desired input count. 
---Set 0 to remove the item, if it is there.
---@param recipe_name string name of a recipe prototype
---@param input_item string name of an item prototype (or related recipe input)
---@param new_input_count int final quantity
---@param is_fluid boolean? if true, then input this as a fluid. Optional
function rubia_lib.compat.set_recipe_input_count(recipe_name, input_item, new_input_count, is_fluid)
    local recipe = data.raw.recipe[recipe_name]
    assert(recipe, "No recipe prototype found under the name: " .. recipe_name)

    local found_index
    for index, entry in pairs(recipe.ingredients) do
        if entry.name == input_item then
            found_index = index
            break
        end
    end

    --We need to remove it, AND it is there.
    if new_input_count == 0 and found_index then 
        table.remove(recipe.ingredients, found_index)
    --Need to remove, but already absent
    elseif new_input_count == 0 and not found_index then return 
    --We found it, and it has a non-zero amount
    elseif found_index then recipe.ingredients[found_index].amount = new_input_count
    --We did not find it, and non-zero amount, so add it
    else 
        local type = is_fluid and "fluid" or "item"
        table.insert(recipe.ingredients, {type = type, name = input_item, amount = new_input_count})
    end
end

---Given a specific list of entries, find the index of the entry where the name matches the input item.
---@param list any[] array of entries, where each entry has a .name field
---@param input_item string name of an item prototype (or related recipe input)
---@return int? index Index where that entry resides. nil = not found
---@return any[]? entry The entry where the item was found
function rubia_lib.compat.find_item_in_list(list, input_item)
    local found_index
    for index, entry in pairs(list) do
        if entry.name == input_item then
            return index, entry
        end
    end
    return nil, nil
end


---Remove the effect of unlocking this recipe to the technology. Do not throw error if it is not already there.
---@param technology_name string name of technology prototype
---@param recipe_name string name of recipe prototype
function rubia_lib.compat.remove_recipe_from_technology(technology_name, recipe_name)
    local tech = data.raw["technology"][technology_name]
    assert(tech, "Technology prototype not found: " .. technology_name)

    for index, entry in pairs(tech.effects) do
        if entry.type == "unlock-recipe" and entry.recipe and entry.recipe == recipe_name then
            table.remove(tech.effects, index)
            return
        end
    end
end

---Add the effect of unlocking this recipe to the technology. If it is already there, do not add it.
---@param technology_name string name of technology prototype
---@param recipe_name string name of recipe prototype
function rubia_lib.compat.add_recipe_to_technology(technology_name, recipe_name)
    local tech = data.raw["technology"][technology_name]
    assert(tech, "Technology prototype not found: " .. technology_name)

    for index, entry in pairs(tech.effects) do
        if entry.type == "unlock-recipe" and entry.recipe and entry.recipe == recipe_name then
            return --It is already there
        end
    end
    --It is not already there
    table.insert(tech.effects, {type = "unlock-recipe", recipe = recipe_name})
end

---Get a relevant IconData[] from a prototype OR IconData OR IconData[]
---Usage:
---icons = rubia_lib.compat.get_icon_data(prototype.icons)
---icons = rubia_lib.compat.get_icon_data(prototype)
---icons = rubia_lib.compat.get_icon_data({icon = "__base__/graphics/icons/electronic-circuit.png"})
---@param icondata_source data.IconData | data.IconData[] | data.ItemPrototype | data.RecipePrototype
---@return data.IconData[] icons the full array of icon data to pass in for {icons}
function rubia_lib.compat.get_icon_data(icondata_source)
    assert(icondata_source, "No icon data source!")
    --If this is a recipe prototype, we may need to infer the item prototype.
    local icondata_actual_source = icondata_source
    if icondata_actual_source.type == "recipe"
        and not icondata_actual_source.icon
        and not icondata_actual_source.icons then
        
        local item_name
        if icondata_source.main_product then item_name = icondata_source.main_product
        else
            assert(icondata_source.results, "This recipe has no results: " .. icondata_source.name)
            assert(table_size(icondata_source.results) == 1, "This recipe has an ambiguous number of results: " .. icondata_source.name)
            item_name = icondata_source.results[1].name
            assert(item_name, "No name found in the results for this recipe: " .. icondata_source.name)
        end

        local item
        for category in pairs(defines.prototypes.item) do
            item = data.raw[category][item_name]
            if item then break end
        end
        if not item then item = data.raw["fluid"][item_name] end
        assert(item, "This recipe has invalid icon data: " .. icondata_actual_source.name)
        icondata_actual_source = item
    end

    --icondata_actual_source is now either a valid prototype with icon data in it, an IconData[], or one IconData
    local icondata = {}
    if icondata_actual_source.type then --This is a full prototype
        if icondata_actual_source.icon then -- One icon
            icondata = {icon = icondata_actual_source.icon,
                        icon_size = icondata.icon_size} --Could be nil
        else
            icondata = util.table.deepcopy(icondata.icons)
        end
    else icondata = icondata_actual_source
    end

    --Right now, it is an IconData or IconData[]
    if icondata.icon then return {icondata}
    else return icondata
    end
end


---Make an icon for an item/recipe that has a small Rubia superscript.
---Usage:
---icons = rubia_lib.compat.make_rubia_superscripted_icon(prototype.icons)
---icons = rubia_lib.compat.make_rubia_superscripted_icon(prototype)
---icons = rubia_lib.compat.make_rubia_superscripted_icon({icon = "__base__/graphics/icons/electronic-circuit.png"})
---@param icondata_source data.IconData | data.IconData[] | data.ItemPrototype | data.RecipePrototype
---@return data.IconData[] icons the full array of icon data to pass in for {icons}
function rubia_lib.compat.make_rubia_superscripted_icon(icondata_source)
    assert(icondata_source, "No icon data!")
    --For Rubia planet Icon
    local subicon_scale = 0.7
    local base_icon_size = 64
    local rubia_subicon = {
        icon = "__rubia-assets__/graphics/planet/rubia-icon.png",
        icon_size = 64,
        scale = (0.5 * defines.default_icon_size / (64 or defines.default_icon_size)) * subicon_scale,
        shift = {x=base_icon_size * subicon_scale/4, y =-base_icon_size * subicon_scale/4},
    }

    local icondata = util.table.deepcopy(rubia_lib.compat.get_icon_data(icondata_source))
    table.insert(icondata, rubia_subicon)
    return icondata
end


---Make a list of functions to call in data-updates, which is general for compat.
---@type function[]
rubia_lib.compat.to_call_on_data_updates = rubia_lib.compat.to_call_on_data_updates or {}
---Make a list of functions to call in data-final-fixes, which is general for compat.
---@type function[]
rubia_lib.compat.to_call_on_data_final_fixes = rubia_lib.compat.to_call_on_data_final_fixes or {}

--#endregion