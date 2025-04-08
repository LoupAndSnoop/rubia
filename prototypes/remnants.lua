--Copied from base remnants.lua.

require ("util")

function make_rotated_animation_variations_from_sheet(variation_count, sheet) --makes remnants work with more than 1 variation
    local result = {}
  
    local function set_y_offset(variation, i)
      local frame_count = variation.frame_count or 1
      local line_length = variation.line_length or frame_count
      if (line_length < 1) then
        line_length = frame_count
      end
  
      local height_in_frames = math.floor((frame_count * variation.direction_count + line_length - 1) / line_length)
      -- if (height_in_frames ~= 1) then
      --   log("maybe broken sheet: h=" .. height_in_frames .. ", vc=" .. variation_count .. ", " .. variation.filename)
      -- end
      variation.y = variation.height * (i - 1) * height_in_frames
    end
  
    for i = 1,variation_count do
      local variation = util.table.deepcopy(sheet)
  
      if variation.layers then
        for _, layer in pairs(variation.layers) do
          set_y_offset(layer, i)
        end
      else
        set_y_offset(variation, i)
      end
  
      table.insert(result, variation)
    end
   return result
  end

local remnants = 
{
    {
    type = "corpse",
    name = "catalytic-chemical-plant-remnants",
    icon = "__rubia__/graphics/icons/catalytic-chemical-plant.png",
    flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "production-machine-remnants",
    order = "a-e-a",
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    tile_width = 3,
    tile_height = 3,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation =
    {
      filename = "__rubia__/graphics/entity/catalytic-chemical-plant-remnants.png",
      line_length = 1,
      width = 366,
      height = 306,
      direction_count = 1,
      shift = util.by_pixel(16, -5.5),
      scale = 0.5
    }
  },
  {
    type = "corpse",
    name = "red-steam-engine-remnants",
    icon = "__base__/graphics/icons/steam-engine.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "energy-remnants",
    order = "a-b-a",
    selection_box = {{-1.5, -2.5}, {1.5, 2.5}},
    tile_width = 3,
    tile_height = 5,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation = make_rotated_animation_variations_from_sheet (1,
    {
      filename = "__rubia__/graphics/entity/red-steam-engine-remnants.png",
      line_length = 1,
      width = 462,
      height = 386,
      direction_count = 4,
      shift = util.by_pixel(17, 6.5),
      scale = 0.5
    })
  },
  {
    type = "corpse",
    name = "red-boiler-remnants",
    icon = "__base__/graphics/icons/boiler.png",
    flags = {"placeable-neutral", "not-on-map"},
    hidden_in_factoriopedia = true,
    subgroup = "energy-remnants",
    order = "a-a-a",
    selection_box = {{-1.5, -1}, {1.5, 1}},
    tile_width = 3,
    tile_height = 2,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation =
    {
      filename = "__rubia__/graphics/entity/red-boiler-remnants.png",
      line_length = 1,
      width = 274,
      height = 220,
      direction_count = 4,
      shift = util.by_pixel(-0.5, -3),
      scale = 0.5
    }
  },

  {
    type = "corpse",
    name = "ice-box-remnants",
    icon = "__rubia__/graphics/icons/ice-box.png",
    hidden_in_factoriopedia = true,
    flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
    subgroup = "storage-remnants",
    order = "a-a-a",
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    tile_width = 1,
    tile_height = 1,
    selectable_in_game = false,
    time_before_removed = 60 * 60 * 15, -- 15 minutes
    expires = false,
    final_render_layer = "remnants",
    remove_on_tile_placement = false,
    animation =
    {
      filename = "__rubia__/graphics/entity/ice-box-remnants.png",
      line_length = 1,
      width = 110,
      height = 74,
      direction_count = 1,
      shift = util.by_pixel(7.5, -1),
      scale = 0.5
    }
  },



}
--No idea why devs did it this way, hopefully it works.
for k, remnant in pairs (remnants) do
    if not remnant.localised_name then
      local name = remnant.name
      if name:find("%-remnants") then
        remnant.localised_name = {"remnant-name", {"entity-name."..name:gsub("%-remnants", "")}}
      end
    end
end
  
data:extend(remnants)