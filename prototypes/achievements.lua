

data:extend(
{
    --[[{
        type = "produce-achievement",
        name = "crafting-with-efficiency-4",
        order = "a[progress]-h[crafting-tier-3-module]-b[efficiency]",
        item_product = "efficiency-module-3",
        amount = 1,
        limited_to_one_game = false,
        icon = "__base__/graphics/achievement/crafting-with-efficiency.png",
        icon_size = 128
      },]]
    {
        type = "change-surface-achievement",
        name = "visit-rubia",
        order = "a[progress]-g[visit-planet]-a[rubia]",
        surface = "rubia",
        icon = "__rubia__/graphics/achievement/visit-rubia.png",
        icon_size = 128,
    },
    --[[
    {
        type = "research-with-science-pack-achievement",
        name = "research-with-electrochemical",
        order = "e[research]-a[research-with]-j[electrochemical]",
        science_pack = "electrochemical-science-pack",
        icon = "__rubia__/graphics/achievement/research-with-electrochemical.png",
        icon_size = 128
    },   ]] 
}
)
