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
    }
})

--Fix the chem plant only category
table.insert(data.raw["assembling-machine"]["chemical-plant"].crafting_categories, "chemical-plant-only")