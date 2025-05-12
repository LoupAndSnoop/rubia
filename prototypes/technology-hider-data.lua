--Data stage for making hidden technologies.
--The goal here is to make the prototypes for "unknown" technology placeholders.
local tech_lib = require("__rubia__/lib/technology-hider-lib")



--Return a prototype for an unknown technology
local function make_unknown_tech_base()
return {
    type = "technology",
    name = "rubia-unknown-technology",
    localised_name = {"technology-name.rubia-unknown-technology"},
    localised_description = {"technology-description.rubia-unknown-technology"},
    icons = "__rubia-assets__/graphics/technology/unknown-technology.png",
    effects = {},
    prerequisites = {},
    enabled = false,
}
end