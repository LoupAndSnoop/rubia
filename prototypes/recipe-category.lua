data:extend({
    {
        type = "recipe-category",
        name = "biorecycling"
    },
    {
        type = "recipe-category",
        name = "crapapult"
    },
    {
        type = "recipe-category",
        name = "chemical-plant-only"
    },
    {
        type = "recipe-category",
        name = "organic-or-biorecycling"
    },
})

--Add categories to vanilla machines
table.insert(data.raw["assembling-machine"]["chemical-plant"].crafting_categories, "chemical-plant-only")
table.insert(data.raw["assembling-machine"]["biochamber"].crafting_categories, "organic-or-biorecycling")