
--Add quality information to factoriopedia.
local function add_quality_factoriopedia_info(entity, factoriopedia_info)
  local factoriopedia_description

  for _, factoriopedia_info in pairs(factoriopedia_info or {}) do
      local header, factoriopedia_function = unpack(factoriopedia_info)
      local localised_string = {"", "[font=default-semibold]", header, "[/font]"}

      local qualities_shown = 0
      for _, quality in pairs(data.raw.quality) do
          if quality.hidden then goto continue end
          
          local quality_buff = factoriopedia_function(entity, quality)
          if type(quality_buff) ~= "table" then quality_buff = tostring(quality_buff) end
          table.insert(localised_string, {"", "\n[img=quality." .. quality.name .. "] ", {"quality-name." .. quality.name}, ": [font=default-semibold]", quality_buff, "[/font]"})
          qualities_shown = qualities_shown + 1
          if qualities_shown > 25 then break end --Infinite quality tiers etc will lag the game if we don't break.
          ::continue::
      end

      if factoriopedia_description then
          factoriopedia_description[#factoriopedia_description + 1] = "\n\n"
          factoriopedia_description[#factoriopedia_description + 1] = rubia.shorten_localised_string(localised_string)
      else
          factoriopedia_description = localised_string
      end
  end
  entity.factoriopedia_description = rubia.shorten_localised_string(factoriopedia_description)
end

--Add quality info for the wind turbine. Janky but functional.
local turbine_prototype = data.raw["electric-energy-interface"]["rubia-wind-turbine"]
add_quality_factoriopedia_info(turbine_prototype, {
  {{"entity-description.rubia-wind-turbine"}, function(entity, quality_level)
      local base_wind_turbine_power = util.parse_energy(data.raw["electric-energy-interface"]["rubia-wind-turbine"].energy_production)
      local quality_mult = 1 + 0.3 * quality_level.level
      local power_kW_per_nondim = 100/ util.parse_energy("100 kW") --constant to convert between kW and nondimensional power
      return tostring(base_wind_turbine_power * power_kW_per_nondim * quality_mult) .. "kW" --empirically, 50/3 nondimensional power = 1 kW
  end}
})
turbine_prototype.localised_description = turbine_prototype.factoriopedia_description
