--This file maintains a lookup table of functions for serialization purposes

_G.serializer = {}
--Dictionary of "function_name" => function
local function_register = {}

--Add a key to the table, so function_register[function_name] => function_to_invoke
-- The function should be of the form function({arguments}), where it queries that as a dictionary
---@param function_to_invoke function
---@param function_name string
serializer.register = function(function_name, function_to_invoke)
  if game then error("Cannot register a function outside the main chunk") end
  function_register[function_name] = function_to_invoke
end

--Invoke a function by name, calling it on a set of serialized arguments.
--The function should be of the form function({arguments})
serializer.invoke = function(function_name, arguments)
    assert(function_register[function_name], "Function name not found in lookup table: " .. function_name)
    function_register[function_name](arguments)
end