

rubia = rubia or {}
rubia.testing = rubia.testing or {}

--For troubleshooting. Get the character's current total shield.
local function get_character_shields(character)
    if (not character.grid or not character.grid.valid) then return 0 end --Nothing to do
    local total_shield = 0
    for _, equip in pairs(character.grid.equipment) do 
        if (equip.valid and (equip.type ~= "equipment-ghost") 
        and equip.max_shield > 0) then
            total_shield = total_shield + equip.shield
        end
    end
    return total_shield
end


--Shield value testing:
rubia.timing_manager.register("shield-value-testing", function(character, 
        shield_before_regen, start_tick, damage)
    local regen = get_character_shields(character) - shield_before_regen
    local regen_per_sec = (regen) / ((game.tick - start_tick) / 60)
    
    local string = "Shield regen test. Regen/s = " .. tostring(regen_per_sec) 
    string = string .. ". Ticks = " .. tostring(game.tick - start_tick)
    string = string .. ". Total regen = " .. tostring(regen)
    string = string .. ".   Final shield = " .. tostring(get_character_shields(character))

    if math.abs(regen - damage) < 0.1 then --Shield was maxed
        string = "\n   Regen stopped mid-test due to hitting max shield.\n"
    end

    game.print(string)
end)

---Deal damage to the player, then calculate the regenerated shield amount.
---@param damage_to_try int?
rubia.testing.test_shield_regen = function(damage_to_try)
    local character = game.players[1].character
    if not character then game.print("No character found") return end

    local pre_damage_shield = get_character_shields(character)
    if not damage_to_try then damage_to_try = pre_damage_shield * 0.9 end

    character.damage(damage_to_try, game.forces["player"])
    local shield_damage = pre_damage_shield - get_character_shields(character)
    game.print("Initial shield: Pre damage = " .. tostring(pre_damage_shield)
        .. ", Post-damage = " .. tostring(get_character_shields(character)))

    for _, test_ticks in pairs({1, 5,10,50,120}) do
        rubia.timing_manager.wait_then_do(test_ticks, "shield-value-testing",
            {character, get_character_shields(character), game.tick, shield_damage})
    end
end
--call: /c __rubia__ rubia.testing.test_shield_regen()
--Or call with a specific damage argument
