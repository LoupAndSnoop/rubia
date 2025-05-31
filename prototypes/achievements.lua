

data:extend(
{
    {
        --type = "change-surface-achievement",
        type = "achievement",
        name = "land-on-rubia",
        order = "a[progress]-g[visit-planet]-a[rubia]",
        --surface = "rubia",
        icon = "__rubia-assets__/graphics/achievement/achievement-rubia.png",
        icon_size = 128,
    },
    {
        type = "research-with-science-pack-achievement",
        name = "research-with-biorecycling",
        order = "e[research]-a[research-with]-j[biorecycling]",
        science_pack = "biorecycling-science-pack",
        icon = "__rubia-assets__/graphics/achievement/research-with-biorecycling.png",
        icon_size = 128
    },

    {
        --type = "change-surface-achievement",
        type = "achievement",
        name = "rubia-lore-complete",
        order = "a[progress]-r[rubia]-c",
        --surface = "rubia",
        icon = "__base__/graphics/achievement/you-are-doing-it-right.png",
        icon_size = 128,
    },
}
)
