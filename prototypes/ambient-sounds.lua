
--Accessibility options for people with a disability.
local bad_taste_mode = settings.startup["disable-lyrical-music"].value
local recycle_track
if bad_taste_mode then recycle_track = {filename = "__rubia-assets__/sounds/ambient/JunkyardTribe.ogg", volume = 1}
else recycle_track = {filename = "__rubia-assets__/sounds/ambient/RecycleThatCrap-v2.ogg", volume=0.8} end

data:extend(
{
    {
        type = "ambient-sound",
        name = "rubia-hero",
        track_type = "hero-track",
        planet = "rubia",
        sound = {filename = "__rubia-assets__/sounds/ambient/JunkyardTribe.ogg", volume = 1},
    },
    {
        type = "ambient-sound",
        name = "rubia-1",
        track_type = "main-track",
        planet = "rubia",
        sound = {
            filename = "__rubia-assets__/sounds/ambient/JunkyardTribe.ogg",--"__space-age__/sound/ambient/fulgora/fulgora-1.ogg",
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
            filename = "__rubia-assets__/sounds/ambient/cyberpunk-ambient-music-SoulSerenityAmbience.ogg",
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
            filename = "__rubia-assets__/sounds/ambient/cathedral-of-rusted-cars-DSTechnician.ogg",
            volume = 1,
        },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-4",
        track_type = "main-track",
        planet = "rubia",
        sound = {filename = "__rubia-assets__/sounds/ambient/dark-ambient-background-music-highway-LFC_records.ogg",
            volume =1 },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-5",
        track_type = "main-track",
        planet = "rubia",
        sound =  {filename = "__rubia-assets__/sounds/ambient/dark-hybrid-glitch-ambient-DenElbriggs.ogg",
            volume =1 },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-6",
        track_type = "main-track",
        planet = "rubia",
        sound =  {filename = "__rubia-assets__/sounds/ambient/dark-matter-dark-space-ambient-natures_eye.ogg",
            volume =1 },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-7",
        track_type = "main-track",
        planet = "rubia",
        sound =  {filename = "__rubia-assets__/sounds/ambient/sinius-shale-and-cinder-dark-ambient-music.ogg",
            volume =1 },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-8",
        track_type = "main-track",
        planet = "rubia",
        sound =  {filename = "__rubia-assets__/sounds/ambient/iridium-granular-ambient-2049-13856-zen_man.ogg",
            volume =1 },
        weight = 10
    },
    {
        type = "ambient-sound",
        name = "rubia-9",
        track_type = "main-track",
        planet = "rubia",
        sound =  recycle_track,
        weight = 2
    },
    {
        type = "ambient-sound",
        name = "rubia-10",
        track_type = "main-track",
        planet = "rubia",
        sound =  {filename = "__rubia-assets__/sounds/ambient/dark-140112-Haletski.ogg",
            volume =1 },
        weight = 7
    },

--[[
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
    },]]
    require("__space-age__/sound/ambient/fulgora/interlude-1/interlude-1"),
    require("__space-age__/sound/ambient/fulgora/interlude-2/interlude-2"),
    require("__space-age__/sound/ambient/fulgora/interlude-3/interlude-3"),
    require("__space-age__/sound/ambient/fulgora/interlude-4/interlude-4"),
    require("__space-age__/sound/ambient/fulgora/interlude-5/interlude-5"),
    require("__space-age__/sound/ambient/fulgora/interlude-6/interlude-6"),
    
}
)