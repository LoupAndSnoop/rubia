--This file controls functions that affect the difficulty of trashsteroids for balancing reasons.
local trashsteroid_difficulty = {}

--Trashsteroid armor scaling
local safe_range = 2 * 32 --Range where trashsteroids get no armor scaling, and range where they get intermediate scaling
local intermediate_range = 5 * 32 --Range where trashsteroids get intermediate armor scaling
local intermediate_lin_slope = 2 / 32 --Slope of how quickly armor grows per unit distance
local total_intermediate_factor = intermediate_lin_slope * (intermediate_lin_slope - safe_range)--Amount of armor factor we get accumulated over the intermediate range
assert(intermediate_range > safe_range, "Safe range should be smaller than the end of the intermediate range.")
local log_region_x_scale, log_region_y_scale = 1, 10 --Scale natural log scaling by this much in x/y

local phys_armor_rate, laser_armor_rate = 1, 1 --Scale resistance for each armor type by this much.

--Base resistances that were defined in the data stage
local base_resistances = util.table.deepcopy(prototypes.entity["medium-trashsteroid"].resistances)



--Return the amount of resist we plan to put onto the trashsteroid
local function determine_resist(position)
    local distance = math.sqrt(position.x * position.x + position.y * position.y)

    local armor_factor --Nondimensional amount by which armor gets scaled. Purely a function of position
    if distance < safe_range then armor_factor = 0
    elseif distance < intermediate_range then
        armor_factor = intermediate_lin_slope * (distance - safe_range)
    else --We are far
        armor_factor = total_intermediate_factor 
        + log_region_y_scale * math.log(1 + log_region_x_scale * (distance - intermediate_range))
    end

    --armor_factor 


end



------TODO





return trashsteroid_difficulty