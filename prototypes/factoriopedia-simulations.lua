
require("__base__/prototypes/factoriopedia-util");
local simulations = {}

-----------////////////////////////////////////////////////////////////// INTERMEDIATE PRODUCTS

--simulations.factoriopedia_sulfur_ore= { init = make_resource("sulfur-ore") }
--simulations.factoriopedia_platinum_ore = { init = make_resource("platinum-ore") }
--simulations.factoriopedia_chalcopyrite_ore = { init = make_resource("chalcopyrite_ore") }

--------

require("__base__/prototypes/factoriopedia-util");
local make_asteroid_simulation = function(name, wait)
    return
    [[
      require("__core__/lualib/story")
      game.simulation.camera_position = {0, 0}
  
      for x = -8, 8, 1 do
        for y = -3, 3 do
          game.surfaces[1].set_tiles{{position = {x, y}, name = "empty-space"}}
        end
      end
  
      for x = -1, 0, 1 do
        for y = -1, 0 do
          game.surfaces[1].set_chunk_generated_status({x, y}, defines.chunk_generated_status.entities)
        end
      end
  
      local story_table =
      {
        {
          {
            name = "start",
            action = function() game.surfaces[1].create_entity{name="]]..name..[[", position = {0, 0}, velocity = {0, 0.011}} end
          },
          {
            condition = story_elapsed_check(]]..wait..[[),
            action = function() story_jump_to(storage.story, "start") end
          }
        }
      }
      tip_story_init(story_table)
   ]]
  end
  
  --To add the simulation for an asteroid.
 -- simulations.factoriopedia_small_metallic_asteroid = { hide_factoriopedia_gradient = true, init = make_asteroid_simulation("small-metallic-asteroid", "7") }



return simulations