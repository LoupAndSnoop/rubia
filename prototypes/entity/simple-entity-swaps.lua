--These are rubia-specific entity versions 
-- that are supposed to look identical, but secretly aren't
local entity_swaps = {}

---Rocket swapping
local rocket = util.table.deepcopy(data.raw["rocket-silo-rocket"]["rocket-silo-rocket"])
rocket.name = "rubia-rocket-silo-rocket"
rocket.localised_name = {"entity-name.rocket-silo-rocket"}
rocket.localised_description = {"entity-description.rocket-silo-rocket"}
rocket.hidden = true
rocket.hidden_in_factoriopedia = true
rocket.rocket_sprite = {
    layers =
      {
        util.sprite_load("__rubia-assets__/graphics/entity/rocket/rubia-rocket",
      {
        dice_y = 4,
        shift = util.by_pixel( 0, 17.0+48),
        scale = 0.5
      }),
      util.sprite_load("__base__/graphics/entity/rocket-silo/rocket-static-emission",
      {
        dice_y = 4,
        shift = util.by_pixel( 0, 17+48),
        draw_as_glow = true,
        blend_mode = "additive",
        scale = 0.5
      })
    }
}

local silo = util.table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
silo.name = "rubia-rocket-silo"
silo.localised_name = {"entity-name.rocket-silo"}
silo.localised_description = {"entity-description.rocket-silo"}
silo.rocket_entity = "rubia-rocket-silo-rocket"
--silo.render_not_in_network_icon=false
silo.fixed_recipe = "rocket-part-rubia"
silo.hidden_in_factoriopedia = true
silo.disabled_when_recipe_not_researched = true
silo.placeable_by = {{item = "rocket-silo", count = 1}}
silo.flags = {"placeable-player", "player-creation", "not-in-made-in"}
silo.logistic_trash_inventory_size = 1
silo.hidden = true
silo.hidden_in_factoriopedia = true

data:extend({rocket, silo})

----Car prototypes
---
---Prototype goes in. Out comes the same prototype, but as a Rubia version
---@param prototype any
local function make_rubia_variant(prototype)
  assert(prototype, "nil prototype!")
  assert(prototype.name, "Prototype has no name! : " .. serpent.block(prototype))

  local new_prototype = util.table.deepcopy(prototype)
  new_prototype.name = rubia.RUBIA_AUTO_ENTITY_PREFIX .. prototype.name
  new_prototype.localised_name = {"",{"entity-name." .. prototype.name}, " (", {"space-location-name.rubia"},")"}
  new_prototype.localised_description =  {"entity-description." .. prototype.name}
  new_prototype.hidden = true
  new_prototype.hidden_in_factoriopedia = true

  --Need to find placeable_by
  new_prototype.placeable_by = util.table.deepcopy(prototype.placeable_by)
  if not new_prototype.placeable_by then
    for subtype in pairs(defines.prototypes.item) do
      for item_name, item in pairs(data.raw[subtype] or {}) do
        if item.place_result == prototype.name then
          new_prototype.placeable_by = {{item = item_name, count = 1}}
          goto break_loop
        end
      end
    end
    ::break_loop::
  end

  --Some things aren't placeable. Example: gunship-flying from MeteorSwarms Aircraft space age. Work out more later!
  if not new_prototype.placeable_by then --TODO: Permanent fix?
    log("WARNING: There is nothing for placeable_by for this prototype: " .. prototype.name)
  end
  return new_prototype
end

--Make an array of Problematic car prototypes
local function find_car_prototypes()
  local prototypes = {}
  for name, prototype in pairs(data.raw.car or {}) do
    assert(prototype.name, "Prototype has no name in it! " .. name)
    if prototype.trash_inventory_size and prototype.trash_inventory_size ~= 0 
      and rubia_lib.array_find(prototype.flags or {}, "player-creation") then
      table.insert(prototypes, prototype)
    end
  end
  return prototypes
end

local function make_car_prototypes()
  for i, prototype in pairs(find_car_prototypes()) do
    log("Rubia is auto-making a custom car-variant of: " .. i .. " - " .. tostring(prototype.name))
    local new_prototype = make_rubia_variant(prototype)
    new_prototype.trash_inventory_size = 0
    data:extend({new_prototype})
  end
end



------
function entity_swaps.make_auto_generated_prototypes()
  make_car_prototypes()
end

return entity_swaps