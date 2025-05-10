
local Public = {}

function Public.add_picker_dollies_blacklists()
	if remote.interfaces["PickerDollies"] then
		remote.call("PickerDollies", "add_blacklist_name", "rubia-rocket-silo-rocket", true)
        remote.call("PickerDollies", "add_blacklist_name", "rubia-rocket-silo", true)
    end
end

return Public