if not mods["crushing-industry"] then return end

--Glass gets added, especially to the chem plant recipe. I could add it as a forageable,
--but then you also can't get rail signals.
if settings.startup["crushing-industry-glass"].value then
    local train_pole = data.raw["simple-entity"]["rubia-pole-remnants"].minable.results
    table.insert(train_pole, rubia_lib.tech_cost_scale(
        {type = "item", name = "glass", probability=0.4, amount_min = 5, amount_max = 10}))

    --To automate, allow crushers to make automated sand for glass
    data:extend({
        {
        type = "recipe",
        name = "rubia-compat-crushing-sand-crushing",
        icons = rubia_lib.compat.make_rubia_superscripted_icon({
            icon = "__crushing-industry__/graphics/icons/sand.png",
        }),
        localised_name = {"", {"item-name.sand"}, " (", {"space-location-name.rubia"},")"},
        localised_description = {"recipe-description.sand"},
        subgroup = "rubia-compat-recipes", order = "g[rubia compat]-ci[crushing-industry]-b",
        category = "basic-crushing",
        enabled = false,
        surface_conditions = rubia.surface_conditions(),
        energy_required = 1.25,
        ingredients = {
            { type = "item", name = "concrete", amount = 1},
        },
        results = {{type = "item", name = "sand", amount = 1}},
        allow_productivity = false,
        auto_recycle = false,
        },
    })
    rubia_lib.compat.add_recipe_to_technology("rubia-progression-stage2", "rubia-compat-crushing-sand-crushing")

    --We need electric crushers to be automated.
    local scrapapalooza = data.raw["recipe"]["biorecycle-scrapapalooza"].results
    table.insert(scrapapalooza, {type = "item", name = "electric-crusher", amount = 1, probability = 0.05})
end



--The non-default concrete-mix setting.
if settings.startup["crushing-industry-concrete-mix"].value then
    --Need a local recipe for concrete mix.
    data:extend({
        {
        type = "recipe",
        name = "rubia-compat-crushing-concrete-mix",
        localised_name = {"", {"recipe-name.reconstituted-concrete-mix"}, " (", {"space-location-name.rubia"},")"},
        localised_description = {"recipe-description.reconstituted-concrete-mix"},
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
        auto_recycle = false,
        },
    })
    rubia_lib.compat.add_recipe_to_technology("craptonite-processing", "rubia-compat-crushing-concrete-mix")

    --Custom refined concrete recipe is not needed.
    --rubia_lib.compat.remove_recipe_from_technology("craptonite-wall","rubia-refined-concrete")
    --data.raw.recipe["rubia-refined-concrete"] = nil

    --All the code to run in data-updates
    local on_data_updates = function()
        --Update Icons
        local concrete_mix_fluid = data.raw.fluid["concrete-mix"]
        assert(concrete_mix_fluid, "Some mod destroyed the data in Crushing Industry's concrete mix fluid prototype before Rubia could work with it!")
        local icons = rubia_lib.compat.make_rubia_superscripted_icon(concrete_mix_fluid)
        data.raw.recipe["rubia-compat-crushing-concrete-mix"].icons = icons

        --Craptonite casting should not be touched.
        CrushingIndustry = CrushingIndustry or {}
        CrushingIndustry.concrete_recipes = CrushingIndustry.concrete_recipes or {}
        CrushingIndustry.concrete_recipes["craptonite-casting"] = {ignore=true}
        CrushingIndustry.concrete_recipes["yeet-item-concrete"] = {ignore=true}
        CrushingIndustry.concrete_recipes["rubia-compat-crushing-concrete-mix"] = {ignore=true}
        if data.raw.recipe["rubia-compat-crushing-sand-crushing"] then --Also don't mess with the other compat recipe
            CrushingIndustry.concrete_recipes["rubia-compat-crushing-sand-crushing"] = {ignore=true}
        end

        --Need to ban normal concrete mix recipe, in case some mods add the ability to get water, I don't want weird loops.
        rubia.ban_from_rubia(data.raw.recipe["reconstituted-concrete-mix"])
        --Need to ban concrete casting to stop people from using pipes to send concrete left.
        rubia.ban_from_rubia(data.raw.recipe["concrete"])
    end

    table.insert(rubia_lib.compat.to_call_on_data_updates, on_data_updates)
end