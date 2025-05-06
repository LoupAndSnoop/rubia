local recycler_animation_speed = 4
local biorecycler_path = "__rubia-assets__/graphics/entity/biorecycling-plant/biorecycler-"
local recycler_path = "__quality__/graphics/entity/recycler/recycler-"

local function recycler_direction(key, path)
  return
  {
    layers =
    {
      util.sprite_load(path..key,
      {
        priority = "high",
        frame_count = 64,
        animation_speed = recycler_animation_speed,
        scale = 0.5,
      }),
      util.sprite_load(recycler_path..key.."-shadow",
      {
        draw_as_shadow = true,
        priority = "high",
        frame_count = 64,
        animation_speed = recycler_animation_speed,
        scale = 0.5,
      })
    }
  }
end

local function recycler_direction_frozen(key)
  return util.sprite_load("__quality__/graphics/entity/recycler/recycler-"..key.."-frozen",
  {
    priority = "high",
    scale = 0.5
  })
end

local function recycler_lights(key)
  return util.sprite_load("__quality__/graphics/entity/recycler/recycler-"..key.."-lights",
  {
    draw_as_glow = true,
    priority = "high",
    frame_count = 64,
    blend_mode = "additive",
    animation_speed = recycler_animation_speed,
    scale = 0.5
  })
end


local function recycler_smoke()
  return {
    apply_recipe_tint = "tertiary",
    fadeout = true,
    constant_speed = true,
    north_position = util.by_pixel_hr(35, -160),
    east_position = util.by_pixel_hr(84, -52),
    south_position = util.by_pixel_hr(-32, 18),
    west_position = util.by_pixel_hr(-86, -52 -48),
    render_layer = "wires",
    animation =
    {
      filename = "__quality__/graphics/entity/recycler/recycler-smoke-outer.png",
      frame_count = 47,
      line_length = 16,
      width = 90,
      height = 188,
      animation_speed = 0.5,
      shift = util.by_pixel(-2, -40),
      scale = 0.5
    }
  },
  {
    apply_recipe_tint = "quaternary",
    fadeout = true,
    constant_speed = true,
    north_position = util.by_pixel_hr(35, -160),
    east_position = util.by_pixel_hr(84, -52),
    south_position = util.by_pixel_hr(-32, 18),
    west_position = util.by_pixel_hr(-86, -52 -48),
    render_layer = "wires",
    animation =
    {
      filename = "__quality__/graphics/entity/recycler/recycler-smoke-inner.png",
      frame_count = 47,
      line_length = 16,
      width = 40,
      height = 84,
      animation_speed = 0.5,
      shift = util.by_pixel(0, -14),
      scale = 0.5
    }
  }
end

local function recycler_flipped_smoke()
  return {
    apply_recipe_tint = "tertiary",
    fadeout = true,
    constant_speed = true,
    north_position = util.by_pixel_hr(-35, -160),
    east_position = util.by_pixel_hr(84, -52 -48),
    south_position = util.by_pixel_hr(31, 18),
    west_position = util.by_pixel_hr(-86, -52),
    render_layer = "wires",
    animation =
    {
      filename = "__quality__/graphics/entity/recycler/recycler-smoke-outer.png",
      frame_count = 47,
      line_length = 16,
      width = 90,
      height = 188,
      animation_speed = 0.5,
      shift = util.by_pixel(-2, -40),
      scale = 0.5
    }
  },
  {
    apply_recipe_tint = "quaternary",
    fadeout = true,
    constant_speed = true,
    north_position = util.by_pixel_hr(-35, -160),
    east_position = util.by_pixel_hr(84, -52 -48),
    south_position = util.by_pixel_hr(31, 18),
    west_position = util.by_pixel_hr(-86, -52),
    render_layer = "wires",
    animation =
    {
      filename = "__quality__/graphics/entity/recycler/recycler-smoke-inner.png",
      frame_count = 47,
      line_length = 16,
      width = 40,
      height = 84,
      animation_speed = 0.5,
      shift = util.by_pixel(0, -14),
      scale = 0.5
    }
  }
end

return {
    graphics_set =
    {
      animation =
      {
        north = recycler_direction('N',biorecycler_path),
        east  = recycler_direction('E',biorecycler_path),
        south = recycler_direction('N',biorecycler_path),
        west  = recycler_direction('E',biorecycler_path)
      },
      working_visualisations =
      {
        {
          north_animation = recycler_lights('N'),
          east_animation  = recycler_lights('E'),
          south_animation = recycler_lights('N'),
          west_animation  = recycler_lights('E')
        },
        recycler_smoke()
      },
      frozen_patch =
      {
        north = recycler_direction_frozen('N'),
        east  = recycler_direction_frozen('E'),
        south = recycler_direction_frozen('N'),
        west  = recycler_direction_frozen('E')
      }
    },
    graphics_set_flipped =
    {
      animation =
      {
        north = recycler_direction('flipped-N', biorecycler_path),
        east  = recycler_direction('flipped-E', biorecycler_path),
        south = recycler_direction('flipped-N', biorecycler_path),
        west  = recycler_direction('flipped-E', biorecycler_path)
      },
      working_visualisations =
      {
        {
          north_animation = recycler_lights('flipped-N'),
          east_animation  = recycler_lights('flipped-E'),
          south_animation = recycler_lights('flipped-N'),
          west_animation  = recycler_lights('flipped-E')
        },
        recycler_flipped_smoke()
      },
      frozen_patch =
      {
        north = recycler_direction_frozen('flipped-N'),
        east  = recycler_direction_frozen('flipped-E'),
        south = recycler_direction_frozen('flipped-N'),
        west  = recycler_direction_frozen('flipped-E')
      }
    }
  }