--Made by Code green. Modified to be worse by Loup :)

local lib = {}
---@type table<defines.events, fun(event: EventData)[]>
local events = {}
---@type function[]
local inits = {}
---@type function[]
local configs = {}
---@type function[]
local loads = {}
---@type table<int, function[]>
local nths = {}

---@param id LuaEventType
---@param fun fun(event: EventData)
local function on_event(id, fun)
    local handlers = events[id] or {} --[[@as fun(event: EventData)[] ]]
    events[id] = handlers
    handlers[#handlers+1] = fun
    script.on_event(id, function(event)
        for _, handler in pairs(handlers) do
            handler(event)
        end
    end)
end

---@param event LuaEventType|LuaEventType[]
---@param fun fun(event: EventData)
function lib.on_event(event, fun)
    local event_type = type(event)
    if event_type == "number" then
        ---@cast event defines.events
        on_event(event, fun)
    elseif type(event) == "userdata" then
        ---@cast event LuaCustomEventPrototype|LuaCustomInputPrototype
        on_event(event.event_id, fun)
    elseif type(event) == "string" then
        local ci = prototypes.custom_input[event]
        on_event(ci.event_id, fun)
    else
        for _, id in pairs(event) do
            lib.on_event(id, fun)
        end
    end
end

---@param fun function
function lib.on_init(fun)
    inits[#inits+1] = fun
    script.on_init(function()
        for _, init in pairs(inits) do
            init()
        end
    end)
end

---@param fun function
function lib.on_configuration_changed(fun)
    configs[#configs+1] = fun
    script.on_configuration_changed(function(event)
        for _, config in pairs(configs) do
            config(event)
        end
    end)
end

---@param fun function
function lib.on_load(fun)
    loads[#loads+1] = fun
    script.on_load(function()
        for _, load in pairs(loads) do
            load()
        end
    end)
end

---@param n uint
---@param fun function
function lib.on_nth_tick(n, fun)
    tick_handlers = nths[n] or {}
    tick_handlers[#tick_handlers+1] = fun
    nths[n] = tick_handlers
    script.on_nth_tick(n, function(e)
        for _, handler in pairs(tick_handlers) do
            handler(e)
        end
    end)
end

return lib