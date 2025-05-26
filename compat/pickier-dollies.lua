
local function add_picker_dollies_blacklists()
	if remote.interfaces["PickerDollies"] then
		remote.call("PickerDollies", "add_blacklist_name", "rubia-rocket-silo-rocket", true)
        remote.call("PickerDollies", "add_blacklist_name", "rubia-rocket-silo", true)
    end
end


--Event registration
local event_lib = require("__rubia__.lib.event-lib")

event_lib.on_init("pickier-dollies", add_picker_dollies_blacklists)
event_lib.on_configuration_changed("pickier-dollies", add_picker_dollies_blacklists)