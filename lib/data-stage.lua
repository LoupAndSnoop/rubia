--Helper functions for use in the data stage
_G.rubia_lib = _G.rubia_lib or {}

--Return surface conditions for something that forces that item/recipe to Rubia only.
rubia.surface_conditions = function()
    return {{
        property = "rubia-wind-speed",
        min = 300,
        max = 300,
    }}
end

--Take in an EntityPrototype, and ADD surface conditions to it to ban it from Rubia. 
--This takes in the prototype by reference to modify it, with no return.
---@class prototype EntityPrototype
rubia.ban_from_rubia = function(prototype)
    local function rubia_condition()
        return {property = "rubia-wind-speed", min = 0, max = 100,}
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


--Determine if the technology is a (distant) prerequisite of the other. Return true if yes.
--Pass in as the names of technology prototype
function rubia_lib.technology_is_prerequisite(potential_parent, potential_dependent)
    --Go get the technology prototypes
    local parent = data.raw.technology[potential_parent]
    local child = data.raw.technology[potential_dependent]
    --If string, go get the technology prototype. Else, assume it is a technology prototype.
    --local parent = (type(potential_parent) == type("a")) and data.raw.technology[potential_parent] or potential_parent
    --local child = (type(potential_dependent) == type("a")) and data.raw.technology[potential_dependent] or potential_dependent
    if not parent or not child then return false end --Those techs were not found.
    if not child.prerequisites then return false end --No prerequisites
    
    for _, prereq in pairs(child.prerequisites) do
        if prereq == potential_parent then return true end --We found the prerequisite
        if rubia_lib.technology_is_prerequisite(potential_parent, prereq) then return true end
    end

    return false --No connection found
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
