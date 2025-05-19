require("__rubia__.lib.timing-manager")

--[[In control stage, determine if the given tech originated on Rubia.
rubia_lib.is_rubia_tech = function(technology_name)
    prototypes.get_history("technology", technology_name).created
prototypes.get_history("technology", technology_name).created == "rubia"
end]]
