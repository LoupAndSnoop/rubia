--Helper functions for use in the data stage

--Return surface conditions for something that forces that item/recipe to Rubia only.
rubia.surface_conditions = function()
    return {{
        property = "rubia-wind-speed",
        min = 200,
        max = 200,
    }}
end

--Take in an EntityPrototype, and ADD surface conditions to it to ban it from Rubia. 
--This takes in the prototype by reference to modify it, with no return.
---@class prototype EntityPrototype
rubia.ban_from_rubia = function(prototype)
    local function rubia_condition()
        return {property = "rubia-wind-speed", min = 0, max = 100,}
    end

    if (not prototype.surface_conditions or #prototype.surface_conditions == 0) then
        prototype.surface_conditions = {rubia_condition()}

    else
        --Check if the prototype has wind speed already defined. If it does, update it
        for i, condition in pairs(prototype.surface_conditions) do
            if condition.property == "rubia-wind-speed" then
                prototype.surface_conditions[i] = rubia_condition()
                return
            end
        end
        --No dupes found, just add it in.
        table.insert(prototype.surface_conditions, rubia_condition())
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