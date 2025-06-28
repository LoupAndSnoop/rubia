if not mods["crushing-industry"] then return end

--Craptonite casting should not be touched.
CrushingIndustry = CrushingIndustry or {}
CrushingIndustry.concrete_recipes = CrushingIndustry.concrete_recipes or {}
CrushingIndustry.concrete_recipes["craptonite-casting"] = {ignore=true}

--Need a local recipe for concrete mix.
local concrete_mix = data.raw.fluid["concrete-mix"]
data:extend({
    {
    type = "recipe",
    name = "rubia-compat-crushing-concrete-mix",
    localised_name = {"", {"recipe-name.reconstituted-concrete-mix"}, " (", {"space-location-name.rubia"},")"},
    localised_description = {"recipe-description.reconstituted-concrete-mix"},
    icons = rubia_lib.compat.make_rubia_superscripted_icon(concrete_mix),
    subgroup = "rubia-compat-recipes", order = "g[rubia compat]-ci[crushing-industry]-a",
    category = "biorecycling",
    enabled = false,
    surface_conditions = rubia.surface_conditions(),
    energy_required = 5,
    ingredients = {
        { type = "item", name = "concrete", amount = 10},--Base amount is 10.
        { type = "fluid", name = "rubia-bacterial-sludge", amount = 25}, 
    },
    results = {{type = "fluid", name = "concrete-mix", amount = 25}},
    allow_productivity = false,
    },
})
rubia_lib.compat.add_recipe_to_technology("craptonite-processing", "rubia-compat-crushing-concrete-mix")
CrushingIndustry.concrete_recipes["rubia-compat-crushing-concrete-mix"] = {ignore=true}

--Need to ban normal concrete mix recipe, in case some mods add the ability to get water, I don't want weird loops.
rubia.ban_from_rubia(data.raw.recipe["reconstituted-concrete-mix"])