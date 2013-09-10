-- os.loadAPI("btEvent")--<link>https://www.dropbox.com/s/lj68qkynye2zmqy/btEvent.lua</link>

-- appName    = "btEvent"
-- appVersion = "1.0a"

-- required API:  btClass

os.loadAPI("btClass")

local id = 0
local function nextId()
  id = id + 1
  return id
end

-- ignores parameters set to "" in the subset
local function eventSubset(subset, set)
  if subset.name ~= set.name then return false end
  for i=1,subset.n do
    if subset[i] ~= nil and
       subset[i] ~= set[i] then
      return false
    end
  end
  return true
end

function new(...)
  local _args = {...}
  if #_args == 0 then _args = {os.pullEvent()} end
  btClass.validate( "name", "string", _args[1], 2 )
  local self = btClass.new()
  self._newProperty   = { "id", get = nextId() }
  self._newProperty   = { "name", get = _args[1] }
  self._newProperty   = { "n", get = #_args - 1 }
  self._newProperty   = { "type", get = "event" }
  self._newMember     = { "handled", false }
  self._newProperty   = { "_index", 
                          get = function(i) return _args[i+1] end,
                          locked = true }
  self._newMetamethod = { "__tostring", function() return table.concat(_args, ",") end }
  self._newMetamethod = { "__le", eventSubset }
  self._lock()
  return self
end

local function validate(event)
  if type(event) ~= "table" or
     event.type ~= "event" then
     error("Expected event object, got "..type(event), 4)
  end
end

local function handlerAdd(list, event, callback)
  validate(event)
  btClass.validate( "callback", "function", callback, 3 )
  table.insert(list, { event=event, callback=callback } )
end

local function handlerTry(list, event)
  validate(event)
  for _,v in ipairs(list) do
    if v.event <= event then
      v.callback(list.sender, event)
      if event.handled then return true end
    end
  end
  return false
end

function newHandler(sender)
  local self = btClass.new()
  local _list = { sender = sender }
  self._newMethod = { "add",
                      handlerAdd,
                      self = _list }
  self._newMethod = { "try",
                      handlerTry,
                      self = _list }
  self._lock()
  return self
end