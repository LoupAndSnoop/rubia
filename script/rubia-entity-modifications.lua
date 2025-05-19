--This file has scripts to set up specific entity modifications.
local entity_modifier = require("__rubia__.lib.entity_modifier")

local entity_modifications = {}


--WIP






--Specific functions



--Register functions
entity_modifier.register_function("train_power", function(entity)
    if not entity.valid or not entity.burner then return end

    --TODO: Currently a test value
    local tech_level = 10--entity.force.technologies["rubia-train-power"].level or 0
    local power_multiplier = 1 + tech_level * 0.1

    --entity.burner = 


end)





--#region General modification to expose.






--Go register all specific modifications that are defined in the file.
entity_modifications.register_all = function()
    --Register 


end




--#endregion


return entity_modifications