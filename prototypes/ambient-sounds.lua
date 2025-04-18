
--Accessibility options for people with a disability.
local bad_taste_mode = settings.startup["disable-ai-music"].value
local recycle_track
if bad_taste_mode then recycle_track = {filename = "__rubia__/sounds/JunkyardTribe.ogg", volume = 1}
else recycle_track = {filename = "__rubia__/sounds/RecycleThatCrap-v2.ogg", volume=0.8} end

data:extend(
{
    {
        type = "ambient-sound",
        name = "rubia-hero",
        track_type = "hero-track",
        planet = "rubia",
        sound = {filename = "__rubia__/sounds/JunkyardTribe.ogg", volume = 1},
    },
    {
        type = "ambient-sound",
        name = "rubia-1",
        track_type = "main-track",
        planet = "rubia",
        sound = {
            filename = "__rubia__/sounds/JunkyardTribe.ogg",--"__space-age__/sound/ambient/fulgora/fulgora-1.ogg",
            volume = 1,
        },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-2",
        track_type = "main-track",
        planet = "rubia",
        sound = {
            filename = "__rubia__/sounds/junkyard-jam.ogg",
            volume = 0.35,
        },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-3",
        track_type = "main-track",
        planet = "rubia",
        sound = {
            filename = "__rubia__/sounds/cathedral-of-rusted-cars-DSTechnician.ogg",
            volume = 1,
        },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-4",
        track_type = "main-track",
        planet = "rubia",
        sound = "__space-age__/sound/ambient/fulgora/fulgora-4.ogg",
        weight = 10
    },
    require("__space-age__/sound/ambient/fulgora/fulgora-5/fulgora-5"),
    {
        type = "ambient-sound",
        name = "rubia-6",
        track_type = "main-track",
        planet = "rubia",
        sound = recycle_track,
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-7",
        track_type = "main-track",
        planet = "rubia",
        sound = "__space-age__/sound/ambient/fulgora/fulgora-7.ogg",
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-8",
        track_type = "main-track",
        planet = "rubia",
        sound = "__space-age__/sound/ambient/fulgora/fulgora-8.ogg",
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-9",
        track_type = "main-track",
        planet = "rubia",
        sound = "__space-age__/sound/ambient/fulgora/fulgora-9.ogg",
        weight = 10
    },
    require("__space-age__/sound/ambient/fulgora/interlude-1/interlude-1"),
    require("__space-age__/sound/ambient/fulgora/interlude-2/interlude-2"),
    require("__space-age__/sound/ambient/fulgora/interlude-3/interlude-3"),
    require("__space-age__/sound/ambient/fulgora/interlude-4/interlude-4"),
    require("__space-age__/sound/ambient/fulgora/interlude-5/interlude-5"),
    require("__space-age__/sound/ambient/fulgora/interlude-6/interlude-6"),
    
}
)