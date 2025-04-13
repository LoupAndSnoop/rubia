--Helper functions for use in the data stage

rubia.surface_conditions = function()
    return {{
        property = "wind-speed",
        min = 200,
        max = 200,
    }}
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