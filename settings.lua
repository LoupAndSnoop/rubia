
data:extend({
    {
        type = "bool-setting",
        name = "disable-lyrical-music",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "require-rubia-for-endgame-planets",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "remove-rubia-from-promethium_sci",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "rubia-rocketizer-early-unlock",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "rubia-megabase-mode",
        setting_type = "startup",
        default_value = false,
        hidden = true,
    },

    {
        type = "int-setting",
        name = "rubia-tech-cost-multiplier",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 10000,
    },

    {
        type = "bool-setting",
        name = "invert-trashsteroid-scaling",
        setting_type = "runtime-global",
        default_value = false
    },

    --[[{
        type = "int-setting",
        name = "rubia-megabasing-density-mode",
        setting_type = "startup",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 20,
    },]]
    {
        type = "string-setting",
        name = "rubia-difficulty-setting",
        setting_type = "runtime-global",
        default_value = "normal",
        allowed_values = {"easy","normal","hard","very-hard","very-very-hard"},
        --hidden = true,
    },
})

--data:extend({
    --[[
    {
        type = "bool-setting",
        name = "automatically-populate-pressure-lab",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "automatically-populate-labs-with-biorecycling-science",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "ignore-everything-brute-force-science-into-pressure-lab",
        setting_type = "startup",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "require-vulcanus-before-rubia",
        setting_type = "startup",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "force-reduction-requires-plates",
        setting_type = "startup",
        default_value = false
    },]]
--})