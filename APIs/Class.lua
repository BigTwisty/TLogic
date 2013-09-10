--[[

  API Name:   Class
  Author:     BigTwisty
  
  Notes:
  
    Provides the basic class interface for all objects.
    
    Interfaces:
    
    - Basic table member
    - Member (a read writeable value that sys.asserts datatyping)
    - Method (a non-overwriteable function)
    - Property (Utilizes get and/or set methods)
        Read-only, write-only or read-write supported
    - Metamethods (any standard metamethod except __index or __newindex)
        
    Special interfaces:
    
    - _index (property that handles read/write for numeric keys of the
      class table

    Required APIs
    
    - tl
    
--]]

if not sys then os.loadAPI("TLogic/sys") end
if not sys then error("Cannot load base API (sys)", 0)

local metamethods = {
  __mode = true,
  __call = true,
  __tostring = true,
  __gc = true,
  __unm = true,
  __add = true,
  __sub = true,
  __mul = true,
  __dif = true,
  __pow = true,
  __concat = true,
  __eq = true,
  __lt = true,
  __le = true
}

local function setMetamethod( meta, value, locked, throwback )
  throwback = throwback + 1
  sys.validate( "metamethod", "table"   , value   , throwback )
  sys.validate( "name"      , "string"  , value[1], throwback )
  sys.assert  ( metamethods[value[1]] ~= nil, 
           "Metamethod not supported: "..value[1], throwback )
  sys.validate( "function"  , "function", value[2], throwback )
  meta[value[1]] = value[2]
end

local function validateInterface( interfaces, key, value, locked, throwback )
  throwback = throwback + 1
  local style = key:sub(5):lower()
  sys.assert( not locked, "Cannot add new "..style.." to a locked class.", throwback )
  sys.validate( style, "table" , value, throwback )
  sys.validate( style.." name", "string", value[1], throwback )
  sys.assert( interfaces[value[1]] == nil or not interfaces[value[1]].locked,
          "Cannot override locked "..style,
          throwback )
  sys.assert( value[1] ~= "_index" or style == "property",
          "Reserved interface '_index' must be a property",
          throwback )
end
  
local function setMember( interfaces, key, value, locked, throwback )
  throwback = throwback + 1
  sys.validateInterface( interfaces, key, value, locked, throwback )
  sys.validate( "member value", "!nil", value[2], throwback )
  interfaces[value[1]] = { style  = "member",
                           value  = value[2],
                           type   = type(value[2]),
                           locked = value.locked }
end

local function setMethod( interfaces, key, value, locked, throwback )
  throwback = throwback + 1
  sys.validateInterface( interfaces, key, value, locked, throwback )
  sys.validate( "method function", "function", value[2], throwback)
  interfaces[value[1]] = { style  = "method",
                           get    = (value.ref == nil) and value[2] or 
                                    function(...) return value[2](value.ref, ...) end,
                           locked = value.locked }
end

local function setProperty( interfaces, key, value, locked, throwback )
  throwback = throwback + 1
  sys.validateInterface( interfaces, key, value, locked, throwback )
  if value.get == nil then
    sys.validate( "property set with no get", "function", value.set, throwback )
  end
  sys.assert( value.ref == nil or
            value.get == nil or
            type(value.get) == "function",
          "Implicit properties cannot reference a ref object",
          throwback )
  if value.set ~= nil then
    sys.validate( "property set", "function", value.set, throwback )
  end
  interfaces[value[1]] = { style  = "property",
                           type   = value.type,
                           set    = value.set,
                           get    = value.get,
                           locked = value.locked }
  if value.ref ~= nil then
    if value.get ~= nil then
      interfaces[value[1]].get = function(...) return value.get(value.ref, ...) end
    end
    if value.set ~= nil then
      interfaces[value[1]].set = function(...) return value.set(value.ref, ...) end
    end
  end
end

local function setIndex( interfaces, key, value, locked, throwback )
  throwback = throwback + 1
  if interfaces._index == nil then return true end
  sys.assert( interfaces._index.set ~= nil, "Numeric keys are read-only", throwback )
  if interfaces._index.type ~= nil then
    sys.validate( "index", interfaces._index.type, value, throwback )
  end
  interfaces._index.set(key, value)
  return false
end

-- Returns true if ok to rawset new table item
local function set(interfaces, key, value, locked, meta)
  local throwback = 3
  if key == "_newMetamethod" then
    setMetamethod( meta, value, locked, throwback )
    return false
  elseif key == "_newMember" then
    setMember( interfaces, key, value, locked, throwback )
    return false
  elseif key == "_newMethod" then
    setMethod( interfaces, key, value, locked, throwback )
    return false
  elseif key == "_newProperty" then
    setProperty( interfaces, key, value, locked, throwback )
    return false
  elseif type(key) == "number" then
    return setIndex( interfaces, key, value, locked, throwback )
  end
  interface = interfaces[key]
  if interface == nil then
    sys.assert( not locked, "Cannot add to a locked class", throwback )
    return true
  end
  if interface.style == "member" then
    sys.validate( key, interface.type, value, throwback )
    interface.value = value
    return false
  end
  sys.assert( interface.style ~= "method", 
          "Cannot write to a defined method", 
          throwback )
  sys.assert( interface.set ~= nil,
          "Cannot write to a read-only property",
          throwback )
  if interface.style == "property" and interface.type ~= nil then
    sys.validate( key, interface.type, value, throwback )
  end
  interface.set(value, key)
  return false
end

local function get(interfaces, key)
  local throwback = 3
  local interface = interfaces[key]
  if interface ~= nil then
    if interface.style == "member" then
      return interface.value
    end
    sys.assert( interface.get ~= nil,
            "Cannot read from a write-only property",
            throwback )
    if interface.style == "property" and type(interface.get) == "function" then
      if interface.ref == nil then
        return interface.get(key)
      end
      return interface.get(interface.ref, key)
    end
    return interface.get
  end
  if type(key) == "number" then
    if interfaces._index == nil then return nil end
    sys.assert( interfaces._index.get ~= nil,
            "Numeric keys are write-only",
            throwback )
    return interfaces._index.get(key)
  end
end

local function interfaceList(interfaces)
  local list = {}
  for k,v in pairs(interfaces) do
    table.insert(list, string.format("%s: %s%s",v.style,k,v.locked and " (locked)" or ""))
  end
  return list
end

function new()
  local _locked = false
  local _interfaces = { }
  local _self = {}
  local function _lock()
    _locked = true
  end
  _self.getMembers = function()
    local ret = {}
    for k,v in pairs(_members) do
      table.insert(ret, string.format(" Name:%s Interface:%s Locked:%s",k,v.style,tostring(v.locked)))
    end
    return ret
  end
  meta = {
    __index = function(_, k, v) 
      return get(_interfaces, k, v, _locked) end,
    __newindex = function(_, k, v)
      if set(_interfaces, k, v, _locked, meta) then
        rawset(_self, k, v)
      end
    end,
    __metatable = {}
  }
  setmetatable(_self, meta)
  _self._newProperty = { "_interfaces",
                        get = interfaceList,
                        ref = _interfaces,
                        locked = true }
  _self._newMethod   = { "_lock",
                        _lock,
                        locked = true }
  _self._newProperty = { "_locked",
                        get = function() return _locked end,
                        locked = true }
  _self._newMetamethod = { "__tostring",
                          function() return "class" end }
  return _self
end